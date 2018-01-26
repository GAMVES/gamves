package com.gamves.gamvescommunity.service;

import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.os.AsyncTask;
import android.os.Environment;
import android.os.IBinder;
import android.provider.MediaStore;
import android.support.v7.app.NotificationCompat;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;

import com.gamves.gamvescommunity.R;

/**
 * Created by mariano on 3/5/16.
 **/
public class DownloadService extends Service {

    private String videoUrl;
    private String videoName;
    private String videoTitle;
    private NotificationManager mNotifyManager;
    private NotificationCompat.Builder mBuilder;
    private int id = 303456;

    public DownloadService() {
        super();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        try {
            this.videoUrl = "" + intent.getStringExtra("url");
            this.videoName = intent.getStringExtra("name");
            this.videoTitle = intent.getStringExtra("title");

            new DownloadTask().execute("");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return super.onStartCommand(intent, flags, startId);
    }

    public class DownloadTask extends AsyncTask<String, Integer, String> {

        @Override
        protected void onPreExecute() {
            mNotifyManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            mBuilder = new NotificationCompat.Builder(DownloadService.this);
            mBuilder.setContentTitle(getResources().getString(R.string.download_notification_title) + " " + videoTitle)
                    .setContentText(getResources().getString(R.string.download_notification_text))
                    .setSmallIcon(android.R.drawable.stat_sys_download)
                    .setTicker("")
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setVibrate(new long[0])
                    .setProgress(100, 0, false);

            mBuilder.setOngoing(true);
            mNotifyManager.notify(id, mBuilder.build());
            startForeground(id, mBuilder.build());
        }

        @Override
        protected String doInBackground(String... params) {

            final int TIMEOUT_CONNECTION = 5000;//5sec
            final int TIMEOUT_SOCKET = 30000;//30sec

            try {
                URL url = new URL(videoUrl);

                String RootDir = Environment.getExternalStorageDirectory()
                        + File.separator + "ShallTV";

                File rootFile = new File(RootDir);
                rootFile.mkdir();

                long startTime = System.currentTimeMillis();

                //Open a connection to that URL.
                URLConnection ucon = url.openConnection();

                //this timeout affects how long it takes for the app to realize there's a connection problem
                ucon.setReadTimeout(TIMEOUT_CONNECTION);
                ucon.setConnectTimeout(TIMEOUT_SOCKET);
                ucon.connect();

                int lengthOfFile = ucon.getContentLength();

                //Define InputStreams to read from the URLConnection.
                // uses 3KB download buffer
                InputStream is = ucon.getInputStream();
                BufferedInputStream inStream = new BufferedInputStream(is, 1024 * 5);
                FileOutputStream outStream = new FileOutputStream(new File(rootFile, videoName));
                byte[] buff = new byte[5 * 1024];

                //Read bytes (and store them) until there is nothing more to read(-1)
                int len;
                long total = 0;
                while ((len = inStream.read(buff)) != -1) {
                    total += len;

                    if (Math.abs((total % (lengthOfFile / 40)) / 1000) == 0) {
                        publishProgress((int) ((total * 100) / lengthOfFile));
                    }

                    outStream.write(buff, 0, len);
                }

                //clean up
                outStream.flush();
                outStream.close();
                inStream.close();

                File toPngFile = new File(Environment.getExternalStorageDirectory() + "/ShallTV/" + videoName.substring(0, videoName.length() - 4) + ".png");
                File videoFile = new File(Environment.getExternalStorageDirectory() + "/ShallTV/" + videoName);
                OutputStream fOut = new FileOutputStream(toPngFile);

                Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(videoFile.getPath(), MediaStore.Images.Thumbnails.MINI_KIND);
                bitmap = ThumbnailUtils.extractThumbnail(bitmap, 240, 135, ThumbnailUtils.OPTIONS_RECYCLE_INPUT);

                bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
                fOut.flush();
                fOut.close();

                Log.e("TAG", "download completed in "
                        + ((System.currentTimeMillis() - startTime) / 1000)
                        + " sec");

            } catch (Exception e) {
                e.printStackTrace();
            }

            return "";
        }

        @Override
        protected void onProgressUpdate(Integer... values) {
            mBuilder.setProgress(100, values[0], false);
            mNotifyManager.notify(id, mBuilder.build());

        }

        @Override
        protected void onPostExecute(String result) {
            mNotifyManager.cancel(id);
            stopForeground(true);
        }
    }

}