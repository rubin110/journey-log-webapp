package com.thomaslotze.survivedc;

public class BackgroundPhotoUploader implements Runnable {
	CheckpointScannerActivity mainApp;
	
	public BackgroundPhotoUploader(CheckpointScannerActivity mainApp) {
		super();
		this.mainApp = mainApp;
	}

	@Override
	public void run() {
		while(true) {
			if (mainApp.isStartingCheckpoint() && mainApp.hasWaitingPhotos()) {
				mainApp.uploadWaitingPhotos();
			}
			try {
				Thread.sleep(60000);
			} catch (InterruptedException e) {
			}
		}
	}
}