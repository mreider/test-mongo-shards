package com.example.servicea;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;

public class ServiceA {
    public static void main(String[] args) {
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                try {
                    URL url = new URL("http://localhost:8081/insert");
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");
                    int responseCode = conn.getResponseCode();
                    System.out.println("Response Code : " + responseCode);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }, 0, 5000);
    }
}
