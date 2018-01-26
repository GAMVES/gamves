package com.gamves.gamvescommunity;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

/**
 * Created by mariano on 3/7/16.
 **/
public abstract class VideoBaseActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public abstract void incomingCall();
    public abstract void finishCall();

}
