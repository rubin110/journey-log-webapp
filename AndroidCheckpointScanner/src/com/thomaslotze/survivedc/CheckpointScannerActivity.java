package com.thomaslotze.survivedc;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.FileEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.cookie.BasicClientCookie;

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
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.telephony.TelephonyManager;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

public class CheckpointScannerActivity extends Activity {
	String checkpointId = "";
	String deviceId = "";
	LocationManager locationManager;
	LocationListener locationListener;
	Location location = null;
	SQLiteDatabase db = null;
	Pattern cpFinder = Pattern.compile(".*\\bcid=([^&]*)");
	DefaultHttpClient httpClient = new DefaultHttpClient();
	private String cameraStoredRunnerId;
	private String cameraStoredUrl;
	
	private static final int CAMERA_CODE = 0;

	/** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.enter_checkpoint);
        
        // Get a DB connection
    	RunnerOpenHelper dbOpenHelper = new RunnerOpenHelper(getApplicationContext());
    	db = dbOpenHelper.getWritableDatabase();

        // read checkpoint Id from database, if it exists
        getLastCheckpointId();
        ((TextView) findViewById(R.id.ManualCPTextField)).setText(checkpointId);    	
        
    	updateSummaryText();

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
    	location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
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
        //locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener);
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, locationListener);

//    	String contents = "crazyrunnerid http://monkey.test?okay/RNID23";
//		String splitContents[] = contents.split("/");
//		String runnerId = splitContents[splitContents.length-1];
//        processRunner(runnerId,"CP Banana",12345);
//		HttpGet httpget = new HttpGet("http://jl.vc/_setcid.php?cid=0");
//        HttpResponse response;
//		try {
//			response = httpClient.execute(httpget);
//	        HttpEntity entity = response.getEntity();
//
//	        if (entity != null) {
//	            entity.consumeContent();
//	        }
//		} catch (ClientProtocolException e) {
//		} catch (IOException e) {
//		}
//		System.out.println("monkey");
//
//        
//		String latString="";
//		String lonString="";
//		if (location != null) {
//			latString = ((Double)location.getLatitude()).toString();
//			lonString = ((Double)location.getLongitude()).toString();
//		}
//		Integer timestamp =  ((Long)(new Date().getTime())).intValue();
//    	String timeString = new Integer(timestamp).toString();
//
//    	
//    	updateCookie();
//
//        String runnerId = "123AB";
////		String url = "http://jl.vc/123AB";
//		String url = "http://spidere.com/survivedc/log.cgi";
//
//	    String urlString = url + "?cid=" + java.net.URLEncoder.encode(checkpointId) + "&rid=" + java.net.URLEncoder.encode(runnerId) + "&did=" + java.net.URLEncoder.encode(deviceId) + "&lat=" + java.net.URLEncoder.encode(latString) + "&lon=" + java.net.URLEncoder.encode(lonString) + "&ts=" + java.net.URLEncoder.encode(timeString);
//        HttpPost httppost = new HttpPost(urlString);
//        try {
//    	    File photo = new File(Environment.getExternalStorageDirectory(), runnerId + ".jpg");
//            FileEntity entity = new FileEntity(photo,"binary/octet-stream");
//            entity.setChunked(true);
//            httppost.setEntity(entity);
//            
//            // Execute HTTP Post Request
//            response = httpClient.execute(httppost);			   
//		} catch (ClientProtocolException e) {
//			// Didn't work -- will hopefully be uploaded later
//		} catch (IOException e) {
//			// Didn't work -- will hopefully be uploaded later
//			System.out.println("monkeys.");
//		}
//		System.out.println("monkeys.");

//        checkpointId = "0";
//        updateCookie();
//		processRegistration("123AB", ((Long)(new Date().getTime())).intValue(), "http://spidere.com/survivedc/log.cgi");

//        selectCheckpoint("1");      
//        processRunner("runid","1",12345,"http://spidere.com/survivedc/log.cgi");
    }
    
    private void updateCookie() {
    	// set the cookie in the cookie store, in case the http request failed
    	BasicClientCookie checkpoint_cookie = new BasicClientCookie("jlog-cid", checkpointId);
    	checkpoint_cookie.setDomain("jl.vc");
    	checkpoint_cookie.setPath("/");
    	checkpoint_cookie.setExpiryDate(new GregorianCalendar(2099, 1, 1).getTime());
		httpClient.getCookieStore().addCookie(checkpoint_cookie);
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

    public void getLastCheckpointId() {
        String[] columns = {"checkpoint_id"};
        Cursor cursor = db.query("last_checkpoint_id", columns, null, null, null, null, null);
        if (cursor.moveToFirst()) {
        	do {
	        	checkpointId = cursor.getString(0);
        	} while (cursor.moveToNext());
        }
        cursor.close();    	    	
    }
    
    public void storeLastCheckpointId() {
    	// TODO: delete old values from the table
    	ContentValues checkpointValues = new ContentValues(4);
    	checkpointValues.put("checkpoint_id", checkpointId);
    	db.insert("last_checkpoint_id", null, checkpointValues);    	
    }
    
    public void uploadWaitingRunners() {
        String[] columns = {"runner_id", "checkpoint_id", "timestamp", "url"};
        Cursor cursor = db.query("runners", columns, "is_uploaded=0", null, null, null, null);
        if (cursor.moveToFirst()) {
        	do {
	        	String rId = cursor.getString(0);
	        	String cpId = cursor.getString(1);
	        	Integer ts = cursor.getInt(2);
	        	String url = cursor.getString(3);
	        	uploadCheckin(rId, cpId, ts, url);
        	} while (cursor.moveToNext());
        }
        cursor.close();    	
    }
    
    public void scanForCheckpointId(View view) {
    	IntentIntegrator.initiateScan(CheckpointScannerActivity.this);
    }
    
    public void submitCheckpointButton(View view) {        
        selectCheckpoint(((TextView) findViewById(R.id.ManualCPTextField)).getText().toString());
    }
    
    public void selectCheckpoint(String cpId) {        
        checkpointId = cpId;
        storeLastCheckpointId();
        
        setContentView(R.layout.ready_to_scan);
        ((TextView) findViewById(R.id.currentCheckpointConfirmationId)).setText(checkpointId);

        updateCookie();
        
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					Thread.sleep(500);
				} catch (InterruptedException e) {
				}
		        // restart barcode scanner
	            IntentIntegrator.initiateScan(CheckpointScannerActivity.this);
			}
			
		}).start();
    }
    
    public static File convertImageUriToFile (Uri imageUri, Activity activity)  {
    	Cursor cursor = null;
    	try {
    	    String [] proj={MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID, MediaStore.Images.ImageColumns.ORIENTATION};
    	    cursor = activity.managedQuery( imageUri,
    	            proj, // Which columns to return
    	            null,       // WHERE clause; which rows to return (all rows)
    	            null,       // WHERE clause selection arguments (none)
    	            null); // Order-by clause (ascending by name)
    	    int file_ColumnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
    	    int orientation_ColumnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.ImageColumns.ORIENTATION);
    	    if (cursor.moveToFirst()) {
    	        String orientation =  cursor.getString(orientation_ColumnIndex);
    	        return new File(cursor.getString(file_ColumnIndex));
    	    }
    	    return null;
    	} finally {
    	    if (cursor != null) {
    	        cursor.close();
    	    }
    	}
	}

    
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		String runnerId = cameraStoredRunnerId;
		String url = cameraStoredUrl;
		
		if (requestCode == CAMERA_CODE) {			
		    if (resultCode == RESULT_OK) {
		    	if (intent != null) {
					Bundle extras = intent.getExtras();
					runnerId = extras.getString("runner id");
					url = extras.getString("runner url");
		    	}

				String splitContents[] = url.split("\\?");
				url = splitContents[0];

				String latString="";
				String lonString="";
				if (location != null) {
					latString = ((Double)location.getLatitude()).toString();
					lonString = ((Double)location.getLongitude()).toString();
				}
				Integer timestamp =  ((Long)(new Date().getTime())).intValue();
		    	String timeString = new Integer(timestamp).toString();
			    HttpResponse response = null;
			    updateCookie();

			    String urlString = url + "?cid=" + java.net.URLEncoder.encode(checkpointId) + "&rid=" + java.net.URLEncoder.encode(runnerId) + "&did=" + java.net.URLEncoder.encode(deviceId) + "&lat=" + java.net.URLEncoder.encode(latString) + "&lon=" + java.net.URLEncoder.encode(lonString) + "&ts=" + java.net.URLEncoder.encode(timeString);
		        HttpPost httppost = new HttpPost(urlString);
		        try {
		    	    File photo = new File(Environment.getExternalStorageDirectory(), runnerId + ".jpg");
                    FileEntity entity = new FileEntity(photo,"binary/octet-stream");
                    entity.setChunked(true);
                    httppost.setEntity(entity);
                    
		            // Execute HTTP Post Request
		            response = httpClient.execute(httppost);			   
				} catch (ClientProtocolException e) {
					// Didn't work -- will hopefully be uploaded later
				} catch (IOException e) {
					// Didn't work -- will hopefully be uploaded later
				} catch (Exception e) {
					// didn't work
				}
		    } else if (resultCode == RESULT_CANCELED) {
		    } else {
		    }

	        setContentView(R.layout.completed_scan);
	        ((TextView) findViewById(R.id.scanned_runner_id)).setText(runnerId);
	        ((TextView) findViewById(R.id.scanned_runner_id)).setTextSize(TypedValue.DENSITY_DEFAULT, new Float(90.0));
	        ((TextView) findViewById(R.id.checkpoint_id)).setText("Picture Taken");
	        ((TextView) findViewById(R.id.checkpoint_id)).setTextSize(TypedValue.DENSITY_DEFAULT, new Float(90.0));
		    
			new Thread(new Runnable() {
				@Override
				public void run() {
					try {
						Thread.sleep(500);
					} catch (InterruptedException e) {
					}
			        // restart barcode scanner
		            IntentIntegrator.initiateScan(CheckpointScannerActivity.this);
				}
				
			}).start();
		} else {
			// presumably a barcode scan
			IntentResult scan=IntentIntegrator.parseActivityResult(requestCode, resultCode, intent);
			if (scan!=null) {
				//String format = scan.getFormatName();
				String contents = scan.getContents();
				if (contents != null) {
					// check to see if this is a checkpoint id; if so, set the checkpoint id
					Matcher m = cpFinder.matcher(contents);
					if (m.find()) {					
						// in the background, try to make an http request to the server (to get cookies)
						makeBackgroundRequest(contents);
						String cpId = m.group(1);
						selectCheckpoint(cpId);
					} else {				
						// otherwise, we assume it's a runner id				
						String splitContents[] = contents.split("/");
						runnerId = splitContents[splitContents.length-1];
						
						// if we're checkpoint 0, get a photo and upload it in the background
						if (checkpointId.equals("0")) {
							processRegistration(runnerId, ((Long)(new Date().getTime())).intValue(), contents);
						} else {					
							// otherwise, we're a regular checkpoint: process it as a checkin		
							processRunner(runnerId, checkpointId, ((Long)(new Date().getTime())).intValue(), contents);
							
							new Thread(new Runnable() {
								@Override
								public void run() {
									try {
										Thread.sleep(500);
									} catch (InterruptedException e) {
									}
							        // restart barcode scanner
						            IntentIntegrator.initiateScan(CheckpointScannerActivity.this);
								}
								
							}).start();
						}
					}
		        } else  {
		            // go back to main (checkpoint selection)
		            setContentView(R.layout.enter_checkpoint);
		        	updateSummaryText();
				}
	            
	        } else  {
	            // go back to main (checkpoint selection)
	            setContentView(R.layout.enter_checkpoint);
	        	updateSummaryText();
	        }
		}
	}

	private void makeBackgroundRequest(String url) {
    	new Thread(new BackgroundHttpRequester(url, httpClient)).start();
	}

	private void processRegistration(String runnerId, int timestamp, String url) {
		// in the background, process the runner's login
    	new Thread(new RunnerCheckinUploader(runnerId, "0", timestamp, url, this)).start();
		
		// Take a picture, which will upload the result to the webserver in the background; then go back to scanning
		//define the file-name to save photo taken by Camera activity
		String fileName = runnerId + ".jpg";
		//create parameters for Intent with filename
		ContentValues values = new ContentValues();
		values.put(MediaStore.Images.Media.TITLE, fileName);
		values.put(MediaStore.Images.Media.DESCRIPTION,"Runner " + runnerId);

		//create new Intent
		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
	    File photo = new File(Environment.getExternalStorageDirectory(),  runnerId + ".jpg");
	    intent.putExtra(MediaStore.EXTRA_OUTPUT,Uri.fromFile(photo));
		intent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 1);
		intent.putExtra("runner url", url);
		intent.putExtra("runner id", runnerId);
		cameraStoredRunnerId = runnerId;
		cameraStoredUrl = url;

		startActivityForResult(intent, CAMERA_CODE);
	}

	/**
	 * Handle successful scan: store in DB and start a background job to upload to the web
	 * @param runnerId
	 * @param cpId
	 * @param timestamp
	 */
	public void processRunner(String runnerId, String cpId, int timestamp, String url) {
    	// Store in local DB
    	ContentValues runnerValues = new ContentValues(4);
    	runnerValues.put("runner_id", runnerId);
    	runnerValues.put("checkpoint_id", cpId);
    	runnerValues.put("timestamp", timestamp);
    	runnerValues.put("is_uploaded", 0);	            	
    	runnerValues.put("url", url);	            	
    	db.insert("runners", null, runnerValues);
    	
    	// asynchronously upload runner check-in
    	new Thread(new RunnerCheckinUploader(runnerId, cpId, timestamp, url, this)).start();
    	
        setContentView(R.layout.completed_scan);
        ((TextView) findViewById(R.id.scanned_runner_id)).setText(runnerId);
        ((TextView) findViewById(R.id.scanned_runner_id)).setTextSize(TypedValue.DENSITY_DEFAULT, new Float(90.0));
        ((TextView) findViewById(R.id.checkpoint_id)).setText("CP: " + cpId);
        ((TextView) findViewById(R.id.checkpoint_id)).setTextSize(TypedValue.DENSITY_DEFAULT, new Float(90.0));
	}
	
	/**
	 * Try to actually upload this runner check-in to the webserver; update the database if successful
	 * @param runnerId
	 * @param checkpointId
	 * @param timestamp
	 */
	public HttpResponse uploadCheckin(String runnerId, String checkpointId, int timestamp, String url) {
		String latString="";
		String lonString="";
		if (location != null) {
			latString = ((Double)location.getLatitude()).toString();
			lonString = ((Double)location.getLongitude()).toString();
		}
    	String timeString = new Integer(timestamp).toString();
    	//url = "http://thomaslotze.com/survivedc.php";
    	//url = "http://mime.starset.net/journeylog/log.php";

    	// take out things from the url after the question mark
		String splitContents[] = url.split("\\?");
		url = splitContents[0];

	    String urlString = url + "?cid=" + java.net.URLEncoder.encode(checkpointId) + "&rid=" + java.net.URLEncoder.encode(runnerId) + "&did=" + java.net.URLEncoder.encode(deviceId) + "&lat=" + java.net.URLEncoder.encode(latString) + "&lon=" + java.net.URLEncoder.encode(lonString) + "&ts=" + java.net.URLEncoder.encode(timeString);
	    HttpResponse response = null;
		try {
			updateCookie();

			response = httpClient.execute(new HttpGet(urlString));
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
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 300000, 100, locationListener);
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
		locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 300000, 100, locationListener);
	}
	
	// Helper class for DB management
	
	public class RunnerOpenHelper extends SQLiteOpenHelper {
	    private static final int DATABASE_VERSION = 2;
	    private static final String DATABASE_NAME = "jlog_db";
	    private static final String RUNNER_TABLE_NAME = "runners";
	    private static final String KEY_RUNNER_ID = "runner_id";
	    private static final String KEY_CHECKPOINT_ID = "checkpoint_id";
	    private static final String KEY_TIMESTAMP = "timestamp";
	    private static final String KEY_IS_UPLOADED = "is_uploaded";
	    private static final String KEY_URL = "url";
	    private static final String RUNNER_TABLE_CREATE =
	                "CREATE TABLE " + RUNNER_TABLE_NAME + " (" +
	                KEY_RUNNER_ID + " TEXT, " +
	                KEY_CHECKPOINT_ID + " TEXT, " +
	                KEY_TIMESTAMP + " INTEGER, " +
	                KEY_IS_UPLOADED + " INTEGER, " +
	                KEY_URL + " TEXT);";
	    private static final String LAST_CP_TABLE_CREATE =
            "CREATE TABLE last_checkpoint_id (" +
            "checkpoint_id TEXT);";
	    RunnerOpenHelper(Context context) {
	        super(context, DATABASE_NAME, null, DATABASE_VERSION);
	    }

	    public void onCreate(SQLiteDatabase db) {
	        db.execSQL(RUNNER_TABLE_CREATE);
	        db.execSQL(LAST_CP_TABLE_CREATE);
	    }

		@Override
		public void onUpgrade(SQLiteDatabase arg0, int arg1, int arg2) {
		}
	}
}