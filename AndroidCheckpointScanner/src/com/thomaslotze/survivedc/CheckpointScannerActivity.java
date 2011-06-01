package com.thomaslotze.survivedc;

import java.io.IOException;
import java.util.Date;
import java.util.UUID;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.util.TypedValue;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class CheckpointScannerActivity extends Activity {
	String checkpointId = "";
	String deviceId = "";
	LocationManager locationManager;
	LocationListener locationListener;
	Location location = null;
	SQLiteDatabase db = null;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        setContentView(R.layout.main);

        // get unique phone id from a combination of sources
        final TelephonyManager tm = (TelephonyManager) getBaseContext().getSystemService(Context.TELEPHONY_SERVICE);
        final String tmDevice, tmSerial, androidId;
        tmDevice = "" + tm.getDeviceId();
        tmSerial = "" + tm.getSimSerialNumber();
        androidId = "" + android.provider.Settings.Secure.getString(getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
        UUID deviceUuid = new UUID(androidId.hashCode(), ((long)tmDevice.hashCode() << 32) | tmSerial.hashCode());
        deviceId = deviceUuid.toString();
        
        // Acquire a reference to the system Location Manager
        locationManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
        // location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
        // Define a listener that responds to location updates
        locationListener = new LocationListener() {
            public void onLocationChanged(Location location) {
              // Called when a new location is found by the network location provider.
              updateLocation(location);
            }

            public void onStatusChanged(String provider, int status, Bundle extras) {}

            public void onProviderEnabled(String provider) {}

            public void onProviderDisabled(String provider) {}
        };
        // Register the listener with the Location Manager to receive location updates
        locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);

        // Get a DB connection
    	RunnerOpenHelper dbOpenHelper = new RunnerOpenHelper(getApplicationContext());
    	db = dbOpenHelper.getWritableDatabase();

    	updateSummaryText();

//    	String contents = "crazyrunnerid http://monkey.test?okay/RNID23";
//		String splitContents[] = contents.split("/");
//		String runnerId = splitContents[splitContents.length-1];
//        processRunner(runnerId,"CP Banana",12345);
    }
    
    public void updateSummaryText() {
        String[] columns = {"count(*)", "sum(is_uploaded)"};
        Cursor cursor = db.query("runners", columns, null, null, null, null, null);
        Integer numScans = 0;
        Integer numUploaded = 0;
        if (cursor.moveToFirst()) {
        	do {
	        	numScans += cursor.getInt(0);        		
	        	numUploaded += cursor.getInt(1);        		
        	} while (cursor.moveToNext());
        }
        cursor.close();

        if (numScans > numUploaded) {
        	// start background job to try to upload failed scans
        	new Thread(new RetryFailedRunnerCheckinUploader(this)).start();
        }
        
        ((TextView) findViewById(R.id.checkpointInfo)).setText(numScans.toString() + " scanned, " + numUploaded.toString() + " uploaded.");    	
    }

    public Boolean hasWaitingRunners() {
        String[] columns = {"runner_id"};
        Cursor cursor = db.query("runners", columns, "is_uploaded=0", null, null, null, "1");
        Boolean retVal = (cursor.getCount() > 0);
        cursor.close();    	
        return(retVal);
    }
    
    public void uploadWaitingRunners() {
        String[] columns = {"runner_id", "checkpoint_id", "timestamp"};
        Cursor cursor = db.query("runners", columns, "is_uploaded=0", null, null, null, null);
        if (cursor.moveToFirst()) {
        	do {
	        	String rId = cursor.getString(0);
	        	String cpId = cursor.getString(1);
	        	Integer ts = cursor.getInt(2);
	        	uploadCheckin(rId, cpId, ts);
        	} while (cursor.moveToNext());
        }
        cursor.close();    	
    }
    
    public void selectCheckpoint(View view) {
        checkpointId=((Button)view).getText().toString();
//        processRunner("autoprocess",checkpointId,12345);

//        TextView tv = ((TextView) findViewById(R.id.current_checkpoint));
//        tv.setText(checkpointId);    	

        IntentIntegrator.initiateScan(CheckpointScannerActivity.this);
    }
    
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		IntentResult scan=IntentIntegrator.parseActivityResult(requestCode, resultCode, intent);
		if (scan!=null) {
			//String format = scan.getFormatName();
			String contents = scan.getContents();
			if (contents != null) {
				String splitContents[] = contents.split("/");
				String runnerId = splitContents[splitContents.length-1];

				processRunner(runnerId, checkpointId, ((Long)(new Date().getTime())).intValue());
				
				new Thread(new Runnable() {
					@Override
					public void run() {
						try {
							Thread.sleep(1500);
						} catch (InterruptedException e) {
						}
				        // restart barcode scanner
			            IntentIntegrator.initiateScan(CheckpointScannerActivity.this);
					}
					
				}).start();
	        } else  {
	            // go back to main (checkpoint selection)
	            setContentView(R.layout.main);
	        	updateSummaryText();
			}
            
        } else  {
            // go back to main (checkpoint selection)
            setContentView(R.layout.main);
        	updateSummaryText();
        }
	}

	/**
	 * Handle successful scan: store in DB and start a background job to upload to the web
	 * @param runnerId
	 * @param cpId
	 * @param timestamp
	 */
	public void processRunner(String runnerId, String cpId, int timestamp) {
    	// Store in local DB
    	ContentValues runnerValues = new ContentValues(4);
    	runnerValues.put("runner_id", runnerId);
    	runnerValues.put("checkpoint_id", cpId);
    	runnerValues.put("timestamp", timestamp);
    	runnerValues.put("is_uploaded", 0);	            	
    	db.insert("runners", null, runnerValues);
    	
    	// asynchronously upload runner check-in
    	new Thread(new RunnerCheckinUploader(runnerId, cpId, timestamp, this)).start();
    	
        setContentView(R.layout.completed_scan);
        ((TextView) findViewById(R.id.scanned_runner_id)).setText(runnerId);
        ((TextView) findViewById(R.id.scanned_runner_id)).setTextSize(TypedValue.DENSITY_DEFAULT, new Float(90.0));
	}
	
	/**
	 * Try to actually upload this runner check-in to the webserver; update the database if successful
	 * @param runnerId
	 * @param checkpointId
	 * @param timestamp
	 */
	public HttpResponse uploadCheckin(String runnerId, String checkpointId, int timestamp) {
		String latString="";
		String lonString="";
		if (location != null) {
			latString = ((Double)location.getLatitude()).toString();
			lonString = ((Double)location.getLongitude()).toString();
		}
    	String timeString = new Integer(timestamp).toString();
    	String webServer = "http://thomaslotze.com/survivedc.php";
    	//String webServer = "http://mime.starset.net/journeylog/log.php";
	    String urlString = webServer + "?station=" + java.net.URLEncoder.encode(checkpointId) + "&rid=" + java.net.URLEncoder.encode(runnerId) + "&did=" + java.net.URLEncoder.encode(deviceId) + "&lat=" + java.net.URLEncoder.encode(latString) + "&lon=" + java.net.URLEncoder.encode(lonString) + "&ts=" + java.net.URLEncoder.encode(timeString);
		HttpClient httpclient = new DefaultHttpClient();
	    HttpResponse response = null;
		try {
			response = httpclient.execute(new HttpGet(urlString));
		    StatusLine statusLine = response.getStatusLine();
		    if(statusLine.getStatusCode() == HttpStatus.SC_OK){
//		        ByteArrayOutputStream out = new ByteArrayOutputStream();
//		        response.getEntity().writeTo(out);
//		        out.close();
//		        String responseString = out.toString();
		        ContentValues successValues = new ContentValues(1);
		        successValues.put("is_uploaded", 1);	            	
		    	db.update("runners", successValues, "runner_id='" + runnerId + "'", null);
		    } else{
		        //Closes the connection.
		        response.getEntity().getContent().close();
		    }
		} catch (ClientProtocolException e) {
			// Didn't work -- will hopefully be uploaded later
		} catch (IOException e) {
			// Didn't work -- will hopefully be uploaded later
		}
		return(response);
	}

	// Helper functions for location management
	
	// We only really want an approximation of geolocation, so once we get it, stop listening
	public void updateLocation(Location updated_location) {
		location = updated_location;
		locationManager.removeUpdates(locationListener);
	}


	@Override
	protected void onStop() {
		super.onStop();
	}

	@Override
	protected void onPause() {
		locationManager.removeUpdates(locationListener);
		super.onPause();
	}

	@Override
	protected void onResume() {
		super.onResume();
		locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);
	}
	
	// Helper class for DB management
	
	public class RunnerOpenHelper extends SQLiteOpenHelper {
	    private static final int DATABASE_VERSION = 2;
	    private static final String DATABASE_NAME = "checkpoint_db";
	    private static final String RUNNER_TABLE_NAME = "runners";
	    private static final String KEY_RUNNER_ID = "runner_id";
	    private static final String KEY_CHECKPOINT_ID = "checkpoint_id";
	    private static final String KEY_TIMESTAMP = "timestamp";
	    private static final String KEY_IS_UPLOADED = "is_uploaded";
	    private static final String RUNNER_TABLE_CREATE =
	                "CREATE TABLE " + RUNNER_TABLE_NAME + " (" +
	                KEY_RUNNER_ID + " TEXT, " +
	                KEY_CHECKPOINT_ID + " TEXT, " +
	                KEY_TIMESTAMP + " INTEGER, " +
	                KEY_IS_UPLOADED + " INTEGER);";

	    RunnerOpenHelper(Context context) {
	        super(context, DATABASE_NAME, null, DATABASE_VERSION);
	    }

	    public void onCreate(SQLiteDatabase db) {
	        db.execSQL(RUNNER_TABLE_CREATE);
	    }

		@Override
		public void onUpgrade(SQLiteDatabase arg0, int arg1, int arg2) {
		}
	}
}