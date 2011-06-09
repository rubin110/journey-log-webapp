package com.thomaslotze.survivedc;

import java.io.IOException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

public class BackgroundHttpRequester implements Runnable {
	String url;
	DefaultHttpClient httpClient;

	public BackgroundHttpRequester(String url, DefaultHttpClient httpClient) {
		super();
		this.url = url;
		this.httpClient = httpClient;
	}

	@Override
	public void run() {
		HttpGet httpget = new HttpGet(url);
        HttpResponse response;
		try {
			response = httpClient.execute(httpget);
	        HttpEntity entity = response.getEntity();

	        if (entity != null) {
	            entity.consumeContent();
	        }
		} catch (ClientProtocolException e) {
		} catch (IOException e) {
		}
	}

}
