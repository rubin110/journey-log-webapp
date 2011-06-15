package com.thomaslotze.survivedc;

public class RunnerCheckinUploader implements Runnable {
	String runnerId;
	String checkpointId;
	Integer timestamp;
	String url;
	CheckpointScannerActivity mainApp;

	public RunnerCheckinUploader(String runnerId, String checkpointId,
			Integer timestamp, String url, CheckpointScannerActivity mainApp) {
		super();
		this.runnerId = runnerId;
		this.checkpointId = checkpointId;
		this.timestamp = timestamp;
		this.url = url;
		this.mainApp = mainApp;
	}

	@Override
	public void run() {
		mainApp.uploadCheckin(runnerId, checkpointId, timestamp, url);
	}

}
