package com.gamves.gamvescommunity;

import android.app.Application;
import android.content.Context;
import android.support.multidex.MultiDex;
import android.util.Log;

import com.gamves.gamvescommunity.utils.KeySaver;
import com.google.android.libraries.cast.companionlibrary.cast.CastConfiguration;
import com.google.android.libraries.cast.companionlibrary.cast.VideoCastManager;
import com.parse.LogInCallback;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseUser;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

import tgio.parselivequery.LiveQueryClient;

/**
 * Created by jose on 6/12/17.
 */

public class GamvesApplication extends Application
{

    public static Context CONTEXT;

    public String userId;

    private static String TAG  = "GamvesApplication";

    private static GamvesApplication sInstance = null;

    List<Integer> gradientArray;

    public static final int VIEW_TYPE_USER_MESSAGE = 0;
    public static final int VIEW_TYPE_FRIEND_MESSAGE = 1;

    int[] solutionArray = {
            R.drawable.home_gradient_one,
            R.drawable.home_gradient_two,
            R.drawable.home_gradient_three,
            R.drawable.home_gradient_four,
            R.drawable.home_gradient_five,
            R.drawable.home_gradient_six,
            R.drawable.home_gradient_seven,
            R.drawable.home_gradient_eight,
            R.drawable.home_gradient_nine,
            R.drawable.home_gradient_ten
    };

    @Override
    public void onCreate () {
        super.onCreate();
        CONTEXT =  getApplicationContext();

        sInstance = this;

        String castAppId = getString(R.string.cast_app_id);

        Parse.enableLocalDatastore(this);

        Parse.initialize(new Parse.Configuration.Builder(this)
                .applicationId("0123456789")
                //.clientKey("r1FBMzUkEemRnGllhvZdkFtKknu1CMUXUUwzP6ew")
                .server("http://192.168.16.22:1337/1/").build()
        );

        /*Parse.initialize(new Parse.Configuration.Builder(this)
                .applicationId("qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU")
                .clientKey("r1FBMzUkEemRnGllhvZdkFtKknu1CMUXUUwzP6ew")
                .server("https://parseapi.back4app.com/").build()
        );*/

        /*Parse.initialize(new Parse.Configuration.Builder(this)
                .applicationId("qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU")
                .clientKey("r1FBMzUkEemRnGllhvZdkFtKknu1CMUXUUwzP6ew")
                .server("https://parseapi.back4app.com/").build()
        );*/

        //LiveQueryClient.init("wss://gamves.back4app.io", "qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU", true);
        //LiveQueryClient.connect();

        if (!isUserLoggedIn())
        {

            if (KeySaver.isExist(this, "username") && KeySaver.isExist(this, "password"))
            {

                String username = KeySaver.getStringSavedShare(this, "username");
                String password = KeySaver.getStringSavedShare(this, "password");

                ParseUser.logInInBackground(username, password, new LogInCallback() {

                    @Override
                    public void done(ParseUser parseUser, ParseException e)
                    {
                        if (parseUser==null)
                        {
                            Log.v("","ERROR: " + e.getMessage());
                        }
                    }

                });

            }

        }

        CastConfiguration options = new CastConfiguration.Builder(castAppId)
                .enableAutoReconnect()
                .enableCaptionManagement()
                .enableDebug()
                .enableLockScreen()
                .enableNotification()
                .enableWifiReconnection()
                .setCastControllerImmersive(false)
                .setLaunchOptions(false, Locale.US)
                .setNextPrevVisibilityPolicy(CastConfiguration.NEXT_PREV_VISIBILITY_POLICY_DISABLED)
                .addNotificationAction(CastConfiguration.NOTIFICATION_ACTION_REWIND, false)
                .addNotificationAction(CastConfiguration.NOTIFICATION_ACTION_PLAY_PAUSE, true)
                .addNotificationAction(CastConfiguration.NOTIFICATION_ACTION_DISCONNECT, true)
                .setForwardStep(10)
                .build();

        VideoCastManager.initialize(this, options);

    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public static GamvesApplication getInstance()
    {
        return sInstance;
    }

    public int generateRandonGradient()
    {
        shuffleArray(solutionArray);

        Random random = new Random();

        int index = random.nextInt(solutionArray.length);

        return solutionArray[index];
    }

    // Implementing Fisher–Yates shuffle
    static void shuffleArray(int[] ar)
    {
        // If running on Java 6 or older, use `new Random()` on RHS here
        Random rnd = ThreadLocalRandom.current();
        for (int i = ar.length - 1; i > 0; i--)
        {
            int index = rnd.nextInt(i + 1);
            // Simple swap
            int a = ar[index];
            ar[index] = ar[i];
            ar[i] = a;
        }
    }

    public static boolean isUserLoggedIn() {
        ParseUser currentUser = ParseUser.getCurrentUser();
        return currentUser != null;
    }

    public static int REQUEST_CODE_REGISTER = 2000;
    public static String STR_EXTRA_ACTION_LOGIN = "login";
    public static String STR_EXTRA_ACTION_RESET = "resetpass";
    public static String STR_EXTRA_ACTION = "action";
    public static String STR_EXTRA_USERNAME = "username";
    public static String STR_EXTRA_PASSWORD = "password";
    public static String STR_DEFAULT_BASE64 = "default";
    public static String UID = "";

    //TODO only use this UID for debug mode
    //public static String UID = "6kU0SbJPF5QJKZTfvW1BqKolrx22";

    public static String INTENT_KEY_CHAT_FRIEND = "friendname";
    public static String INTENT_KEY_CHAT_AVATA = "friendavata";
    public static String INTENT_KEY_CHAT_ID = "friendid";
    public static String INTENT_KEY_CHAT_ROOM_ID = "roomid";
    public static long TIME_TO_REFRESH = 10 * 1000;
    public static long TIME_TO_OFFLINE = 2 * 60 * 1000;


}
