package com.gamves.gamvescommunity;

//import android.annotation.TargetApi;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.app.MediaRouteActionProvider;
import android.support.v7.media.MediaRouteSelector;
import android.support.v7.media.MediaRouter;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

import com.gamves.gamvescommunity.adapters.ListMessageAdapter;
import com.gamves.gamvescommunity.adapters.RecyclerAdapter;
import com.gamves.gamvescommunity.adapters.RecyclerOfflineAdapter;
import com.gamves.gamvescommunity.model.Consersation;
import com.gamves.gamvescommunity.model.Message;
import com.gamves.gamvescommunity.model.VideosListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.gamves.gamvescommunity.utils.CheckConnection;
import com.gamves.gamvescommunity.utils.Utils;
import com.gamves.gamvescommunity.utils.VideoControllerView;
import com.google.android.gms.cast.ApplicationMetadata;
import com.google.android.gms.cast.Cast;
import com.google.android.gms.cast.CastDevice;
import com.google.android.gms.cast.CastMediaControlIntent;
import com.google.android.gms.cast.MediaInfo;
import com.google.android.gms.cast.MediaMetadata;
import com.google.android.gms.cast.RemoteMediaPlayer;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.libraries.cast.companionlibrary.cast.VideoCastManager;
import com.google.android.libraries.cast.companionlibrary.cast.exceptions.CastException;
import com.google.android.libraries.cast.companionlibrary.cast.exceptions.NoConnectionException;
import com.google.android.libraries.cast.companionlibrary.cast.exceptions.TransientNetworkDisconnectionException;
import com.google.gson.Gson;
import com.panframe.android.lib.PFAsset;
import com.panframe.android.lib.PFAssetObserver;
import com.panframe.android.lib.PFAssetStatus;
import com.panframe.android.lib.PFNavigationMode;
import com.panframe.android.lib.PFObjectFactory;
import com.panframe.android.lib.PFView;
import com.parse.CountCallback;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.SaveCallback;
import com.wang.avi.AVLoadingIndicatorView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import tgio.parselivequery.BaseQuery;
import tgio.parselivequery.LiveQueryClient;
import tgio.parselivequery.LiveQueryEvent;
import tgio.parselivequery.Subscription;
import tgio.parselivequery.interfaces.OnListener;

import com.gamves.gamvescommunity.model.ParseAuxiliars.GamvesParseUser;

import com.parse.ParseUser;

/**
 * Created by jose on 9/15/17.
 **/
public class VideoDetail extends VideoBaseActivity
        implements SurfaceHolder.Callback,
        MediaPlayer.OnPreparedListener,
        VideoControllerView.MediaPlayerControl,
        PFAssetObserver,
        OnSeekBarChangeListener,
        View.OnFocusChangeListener
{

    private RelativeLayout videoActivityView;

    private String url;
    private TextView title;
    private String video;

    private RelativeLayout mCollapseWhileScroll;
    private boolean isExpanded = false;
    private TextView description;

    private SurfaceHolder videoHolder;

    private RecyclerView recyclerChat;
    private LinearLayoutManager mLinearLayoutManager;
    private MediaRouter mMediaRouter;
    private MediaRouteSelector mMediaRouteSelector;
    private MediaRouterCallback mMediaRouterCallback;
    private Cast.Listener mCastClientListener;
    private RemoteMediaPlayer mRemoteMediaPlayer;
    private CastDevice mSelectedDevice;
    private GoogleApiClient mApiClient;
    private boolean mWaitingForReconnect = false;
    private boolean mApplicationStarted = false;
    private boolean mVideoIsLoaded = false;

    private String videoTitle = "";
    private String videoDescription = "";


    private VideoControllerView controller;
    private ViewGroup videoContainer;
    private ImageView fullscreenVr;
    private ImageView formatVr;
    private MediaPlayer player;
    private PFAsset vrAssets;
    private PFView vrPlayer;
    boolean updateThumb = true;
    private int formatVrSide = 1;

    private boolean isFullscreen;
    private AVLoadingIndicatorView mProgress;
    int pos = 0;
    private int position;

    private boolean phoneCallStop = false;

    private boolean isInitVideo = true;    

    private AudioManager audioManager;
    private static final double VOLUME_INCREMENT = 0.05;

    private boolean controlsVisible = true;
    private String titleIntent;
    private String descIntent;
    private VideoCastManager mCastManager;
    private View mediaControllers;
    private Timer monitorTimer;
    private SeekBar scrubber;
    private ImageButton playPause;
    private boolean isShowControls = false;

    private ListMessageAdapter adapter;
    private Consersation consersation;
    public static HashMap<String, Bitmap> bitmapAvataFriend;

    private ImageButton btnSend;

    // Subscription being made that receives every message
    private Subscription sub;

    private EditText messageEdit;

    public static final int VIEW_TYPE_USER_MESSAGE = 0;
    public static final int VIEW_TYPE_FRIEND_MESSAGE = 1;

    private String videoId;

    private int counti = 0;
    private int countPics = 1;

    private Boolean avatarsLoaded=false, dataLoaded=false;

    private Hashtable<String, GamvesParseUser> userChat = new Hashtable<String, GamvesParseUser>();

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        VideoCastManager.checkGooglePlayServices(this);
        Utils.setStatusBarTranslucent(true, true, this, getSupportActionBar());

        setContentView(R.layout.activity_video_detail);

        videoActivityView = (RelativeLayout) findViewById(R.id.videoActivityView);

        consersation = new Consersation();

        new Thread(new Runnable(){

            @Override
            public void run()
            {
                countUsersOnChat();
            }

        }).start();

        Intent intent = getIntent();
        videoId = intent.getStringExtra("videoId");        

        //Load LiveQuery
        new LoadLiveQueryClient(new OnLiveQueryCompleted() {

            @Override
            public void onLiveQueryCompleted()
            {

                // If a message is created, we add to the text field
                sub.on(LiveQueryEvent.CREATE, new OnListener()
                {
                    @Override
                    public void on(JSONObject object)
                    {
                        try
                        {

                            Message newMessage = new Message();
                            newMessage.message = (String) ((JSONObject) object.get("object")).get("message");
                            newMessage.userId = (String) ((JSONObject) object.get("object")).get("userId");
                            newMessage.videoId = (String) ((JSONObject) object.get("object")).get("videoId");
                            newMessage.fanpageId = (String) ((JSONObject) object.get("object")).get("fanpageId");

                            String time = (String) ((JSONObject) object.get("object")).get("createdAt");
                            SimpleDateFormat sd = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
                            Date date = sd.parse(time);
                            newMessage.setDateTime(date);

                            consersation.getListMessageData().add(newMessage);

                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    //ADD MESSAGE TO RECYCLEVIEW
                                    adapter.notifyDataSetChanged();
                                    mLinearLayoutManager.scrollToPosition(consersation.getListMessageData().size() - 1);
                                }
                            });

                        } catch (JSONException e)
                        {
                            e.printStackTrace();
                        } catch (java.text.ParseException e)
                        {
                            e.printStackTrace();
                        }
                    }
                });

            }

        }).execute();

        messageEdit = (EditText) findViewById(R.id.editWriteMessage);


        btnSend = (ImageButton) findViewById(R.id.btnSend);

        // Implementing the actions that our app will have
        // Starting with the sendButton functionality

        btnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View view) {

                String messageToSend = messageEdit.getText().toString();

                Log.i("Message", "created correctly, "+messageToSend);

                //Creating and sending the message
                ParseObject message = new ParseObject("ChatVideo");
                message.put("message", messageToSend);
                message.put("fanpageId", "4523453");
                message.put("videoId", videoId);
                message.put("userId", ParseUser.getCurrentUser().getObjectId());

                message.saveInBackground(new SaveCallback() {

                    @Override
                    public void done(ParseException e) {
                        Log.i("Message", "Sent correctly");
                    }

                });

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //Setting the text blank again
                        //UDATE RECYCLEVIEW
                        //message.setText("");
                    }
                });
            }
        });

        mCastManager = VideoCastManager.getInstance();

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
        audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

        final SurfaceView videoSurface = (SurfaceView) findViewById(R.id.videoview);

        assert videoSurface != null;
        videoHolder = videoSurface.getHolder();
        videoHolder.addCallback(this);

        player = new MediaPlayer();
        controller = new VideoControllerView(this, false);

        TelephonyManager TelephonyMgr = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        TelephonyMgr.listen(new PhoneListener(), PhoneStateListener.LISTEN_CALL_STATE);

        initMediaRouter();

        List<VideosListItem> videoList = HomeDataSingleton.getInstance().getActiveFanpage().getVideos();

        for (int i=0; i<videoList.size(); i++)
        {
            String video_id = videoList.get(i).getVideoId();
            if (video_id.equals(videoId))
            {

                video = videoList.get(i).getSource();
                titleIntent = videoList.get(i).getTitle();
                descIntent = videoList.get(i).getDescription();
            }
        }

        Gson gson = new Gson();        

        //if (CheckConnection.isConnected(this) && CheckConnection.isConnectedMobile(this))
        //{
        //    Utils.showTopSnackBar(this, R.id.videocontainer, "#5181e8", getResources().getString(R.string.top_snackbar_cellular), "#FFFFFF");
        //}

        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {

            @Override
            public void onCompletion(MediaPlayer mp)
            {
                if (!isInitVideo)
                {
                    pos = 0;
                    isInitVideo = true;                    
                }
            }
        });

        controller.setPrevNextListeners(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isInitVideo = true;
                pos = 0;
                reset();
                nextVideo();
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isInitVideo = true;
                pos = 0;
                reset();
                preVideo();
            }
        });

        videoContainer = (ViewGroup) findViewById(R.id.videocontainer);

        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;

        int videoHeight = width * 9 / 16; //Form factor for video playing

        RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(width, videoHeight);
        videoContainer.setLayoutParams(lp);


        fullscreenVr = (ImageView) findViewById(R.id.vr_fullscreen_toggle);

        formatVr = (ImageView) findViewById(R.id.vr_format_toggle);
        formatVr.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toggleFormatMode();
            }
        });

        assert fullscreenVr != null;
        fullscreenVr.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toggleFullscreenVr();
            }
        });

        title = (TextView) findViewById(R.id.video_title);
        description = (TextView) findViewById(R.id.video_description);

        mProgress = (AVLoadingIndicatorView) findViewById(R.id.progress_balls);

        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            isFullscreen = true;
            resetVr();
            if (vrPlayer != null) {
                vrPlayer.setMode(2, 16 / 9);
                vrPlayer.setNavigationMode(PFNavigationMode.MOTION);
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                getWindow().setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION, WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
                getWindow().getDecorView().setSystemUiVisibility(
                        View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                                | View.SYSTEM_UI_FLAG_FULLSCREEN
                                | View.SYSTEM_UI_FLAG_IMMERSIVE);
            } else {
                getWindow().getDecorView().setSystemUiVisibility(
                        View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                                | View.SYSTEM_UI_FLAG_FULLSCREEN);
            }
        } else {
            isFullscreen = false;
            resetVr();
            if (vrPlayer != null) {
                vrPlayer.setMode(0, 16 / 9);
                vrPlayer.setNavigationMode(PFNavigationMode.TOUCH);
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            }
        }

        mCollapseWhileScroll = (RelativeLayout) findViewById(R.id.videoinfo);

        assert mCollapseWhileScroll != null;
        mCollapseWhileScroll.setClickable(true);

        mediaControllers = findViewById(R.id.include_media);

        assert mediaControllers != null;
        playPause = (ImageButton) mediaControllers.findViewById(R.id.pause);

        scrubber = (SeekBar) mediaControllers.findViewById(R.id.mediacontroller_progress);
        scrubber.setOnSeekBarChangeListener(this);

        prepareVrUI();

        ImageButton prevVideoVr = (ImageButton) mediaControllers.findViewById(R.id.prev);
        ImageButton nextVideoVr = (ImageButton) mediaControllers.findViewById(R.id.next);

        prevVideoVr.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetVr();
                isInitVideo = true;
                pos = 0;
                reset();
                preVideo();
            }
        });

        nextVideoVr.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetVr();
                isInitVideo = true;
                pos = 0;
                reset();
                nextVideo();
            }
        });
      
        mLinearLayoutManager = new LinearLayoutManager(VideoDetail.this);
        mLinearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);

        recyclerChat = (RecyclerView) findViewById(R.id.recyclerChat);

        assert recyclerChat != null;
        recyclerChat.setLayoutManager(mLinearLayoutManager);
       

        if (savedInstanceState != null) {
            pos = savedInstanceState.getInt("pos");
            position = savedInstanceState.getInt("position");         
        }

    }

    @Override
    public void onFocusChange(View v, boolean hasFocus)
    {
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_UNSPECIFIED);
    }

    public interface OnLiveQueryCompleted
    {
        void onLiveQueryCompleted();
    }

    class LoadLiveQueryClient extends AsyncTask<String, Void, Boolean> {

        private Exception exception;

        private OnLiveQueryCompleted listener;

        public LoadLiveQueryClient(OnLiveQueryCompleted listener) {
            this.listener = listener;
        }

        protected Boolean doInBackground(String... urls)
        {

            try {

                ///// CHAT //////
                LiveQueryClient.init("wss://gamves.back4app.io", "qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU", true);
                LiveQueryClient.connect();

                try {

                    // Subscription being made that receives every message
                    sub = new BaseQuery.Builder("ChatVideo")
                            .addField("message")
                            .addField("videoId")
                            .addField("userId")
                            .addField("fanpageId")
                            .addField("createdAt")
                            .build()
                            .subscribe();

                } catch (Exception ex)
                {
                    Log.v("", ex.getMessage());
                    return false;
                }

                this.listener.onLiveQueryCompleted();

                return true;
            } catch (Exception e) {
                this.exception = e;

                return null;
            }

        }

    }

    private void countUsersOnChat()
    {

        final ParseQuery<ParseObject> queryChatVideo = ParseQuery.getQuery("ChatVideo");
        queryChatVideo.whereEqualTo("videoId", videoId);
        queryChatVideo.findInBackground(new FindCallback<ParseObject>()
        {
            @Override
            public void done(List<ParseObject> usersChats, ParseException e)
            {

                if (usersChats != null && e == null)
                {
                    try
                    {
                        final int chatsCount = usersChats.size();

                        for (int i = 0; i < chatsCount; i++)
                        {
                            String userId = usersChats.get(i).getString("userId");

                            if (!userChat.containsKey(userId))
                            {
                                GamvesParseUser gamvesUser = new GamvesParseUser();
                                gamvesUser.setUserId(userId);
                                userChat.put(userId, gamvesUser);
                            }

                            if (i==(chatsCount-1))
                            {
                                getVideoData(userChat.size());
                            }
                        }
                    } catch (Exception errorDownload) {

                        errorDownload.printStackTrace();
                    }
                }



            }
        });


    }



    private void getVideoData(final int usersCount)
    {

        final ParseQuery<ParseObject> queryChatVideo = ParseQuery.getQuery("ChatVideo");
        videoId = "52345234";
        queryChatVideo.whereEqualTo("videoId", videoId);
        queryChatVideo.findInBackground(new FindCallback<ParseObject>() {

            @Override
            public void done(List<ParseObject> chats, ParseException e) {

                if (chats != null && e == null)
                {
                    try
                    {
                        final int chatsCount = chats.size();

                        //ArrayList<Message> listMessageData = new ArrayList<Message>();

                        for (int i = 0; i < chatsCount; i++)
                        {

                            counti = i;

                            final Message storedMessage = new Message();
                            storedMessage.setMessage(chats.get(i).getString("message"));
                            storedMessage.setUserId(chats.get(i).getString("userId"));
                            storedMessage.setVideoId(chats.get(i).getString("videoId"));
                            storedMessage.setFanpageId(chats.get(i).getString("fanpageId"));

                            Date date = chats.get(i).getDate("createdAt");
                            //SimpleDateFormat sd = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
                            //storedMessage.setTimestamp(sd.parse(date.toString()).getTime());
                            storedMessage.setDateTime(date);

                            //listMessageData.add(storedMessage);

                            consersation.addMessage(storedMessage);

                            if (!consersation.isAvatarDownloaded(storedMessage.getUserId()))
                            {
                                ParseQuery<ParseUser> queryUser = ParseUser.getQuery();
                                final String userId = storedMessage.getUserId();
                                queryUser.whereEqualTo("objectId", userId);
                                queryUser.getFirstInBackground(new GetCallback<ParseUser>() {

                                    @Override
                                    public void done(ParseUser usersObject, ParseException errorUser) {

                                        if (errorUser == null && usersObject != null)
                                        {
                                            try
                                            {
                                                if (userChat.containsKey(userId))
                                                {
                                                    GamvesParseUser gamvesUse = userChat.get(userId);
                                                    gamvesUse.setGamvesUser(usersObject);
                                                }

                                                ParseFile picture = usersObject.getParseFile("pictureSmall");

                                                picture.getDataInBackground(new GetDataCallback() {

                                                    @Override
                                                    public void done(byte[] data, ParseException e)
                                                    {
                                                        Bitmap bitMapImage = BitmapFactory.decodeByteArray(data, 0, data.length);
                                                        consersation.addBitmapToAvatar(storedMessage.getUserId(), bitMapImage);

                                                        if (countPics == usersCount)
                                                        {
                                                            avatarsLoaded = true;
                                                            if (dataLoaded)
                                                            {
                                                                loadChats();
                                                            }
                                                        }
                                                        countPics++;
                                                    }
                                                });


                                            } catch (Exception errorParse) {
                                                errorParse.printStackTrace();
                                            }


                                        } else
                                        {
                                            errorUser.getStackTrace();
                                        }

                                    }
                                });

                            }

                            if (counti == (chatsCount - 1))
                            {
                                dataLoaded = true;
                                if (avatarsLoaded)
                                {
                                    loadChats();
                                }

                            }

                        }

                    } catch (Exception errorDownload) {

                        errorDownload.printStackTrace();
                    }
                }
            }
        });

    }

    private void loadChats()
    {
        adapter = new ListMessageAdapter(this, consersation);
        recyclerChat.setAdapter(adapter);
        adapter.notifyDataSetChanged();
        mLinearLayoutManager.scrollToPosition(consersation.getListMessageData().size() - 1);
        dataLoaded = false;
        avatarsLoaded = false;
    }

    @Override
    protected void onStart() {
        super.onStart();
      
        initVideo();
    }

    public void preVideo() {
        initVideo();
    }

    public void nextVideo() {
        initVideo();
    }

    public void autoNextVideo(MediaPlayer mp) {

        initVideo();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        controller.show();
        return false;
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        player.setDisplay(holder);
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {

    }

    @Override
    public void start() {
        player.start();
    }

    @Override
    public void pause() {
        player.pause();
    }

    @Override
    public void reset() {
        videoHolder.setFormat(PixelFormat.TRANSPARENT);
        videoHolder.setFormat(PixelFormat.OPAQUE);
        player.stop();
        player.reset();
    }

    public void resetVr() {
        if (vrAssets == null) {
            return;
        }

        try {
            vrAssets.stop();

            vrPlayer.release();
            vrAssets.release();

            vrAssets = null;

            videoContainer.removeView(vrPlayer.getView());
            vrPlayer = null;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getDuration() {
        return player.getDuration();
    }

    @Override
    public int getCurrentPosition() {
        return player.getCurrentPosition();
    }

    @Override
    public void seekTo(int pos) {
        player.seekTo(pos);
    }

    @Override
    public boolean isPlaying() {
        return player.isPlaying();
    }

    @Override
    public int getBufferPercentage() {
        return 0;
    }

    @Override
    public boolean canPause() {
        return true;
    }

    @Override
    public boolean canSeekBackward() {
        return true;
    }

    @Override
    public boolean canSeekForward() {
        return true;
    }

    @Override
    public boolean isFullScreen() {
        return isFullscreen;
    }

    @Override
    public void toggleFullScreen() {
        final int orientation = getResources().getConfiguration().orientation;

        switch (orientation) {
            case Configuration.ORIENTATION_PORTRAIT:
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                break;
            case Configuration.ORIENTATION_LANDSCAPE:
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                break;
        }
    }

    @Override
    public void hideControls() {
        title.setVisibility(View.GONE);
    }

    @Override
    public void showControls() {
        title.setVisibility(View.VISIBLE);
    }

    public void toggleFullscreenVr() {
        final int orientation = getResources().getConfiguration().orientation;

        switch (orientation) {
            case Configuration.ORIENTATION_PORTRAIT:
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                break;
            case Configuration.ORIENTATION_LANDSCAPE:
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                break;
        }
    }

    public void toggleFormatMode() {
        assert vrPlayer != null;
        if (formatVrSide == 1) {
            vrPlayer.setFormat(formatVrSide);
            formatVr.setImageResource(R.drawable.formatvrregular);
            formatVrSide = 0;
        } else {
            vrPlayer.setFormat(formatVrSide);
            formatVr.setImageResource(R.drawable.formatvr);
            formatVrSide = 1;
        }
    }

    @Override
    public void incomingCall() {
        phoneCallStop = true;
        pause();
    }

    @Override
    public void finishCall() {
        if (phoneCallStop) {
            phoneCallStop = false;
            start();
        }
    }

    @Override
    public void onPrepared(MediaPlayer mp) {

        if (mProgress != null) {
            Utils.hideProgress(mProgress);
        }

        mp.setOnInfoListener(new MediaPlayer.OnInfoListener() {
            @Override
            public boolean onInfo(MediaPlayer mp, int what, int extra) {
                if (what == MediaPlayer.MEDIA_INFO_BUFFERING_START)
                    if (!Utils.isProgressVisible(mProgress)) {
                        Utils.showProgress(mProgress);
                    }
                if (what == MediaPlayer.MEDIA_INFO_BUFFERING_END)
                    if (Utils.isProgressVisible(mProgress)) {
                        Utils.hideProgress(mProgress);
                    }
                return false;
            }
        });

        controller.setMediaPlayer(this);
        controller.setAnchorView(videoContainer);
        seekTo(pos);
        player.start();
        isInitVideo = false;
        resetVideo();
    }

    public void onPreparedVr() {

        final int orientation = getResources().getConfiguration().orientation;
        switch (orientation) {
            case Configuration.ORIENTATION_PORTRAIT:

                vrPlayer.setMode(0, 16 / 9);
                vrPlayer.setNavigationMode(PFNavigationMode.TOUCH);

                break;
            case Configuration.ORIENTATION_LANDSCAPE:

                vrPlayer.setMode(2, 16 / 9);
                vrPlayer.setNavigationMode(PFNavigationMode.MOTION);

                break;
        }



    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    private void initVideo(String uri, boolean value) {

        mediaControllers.setVisibility(View.GONE);
        fullscreenVr.setVisibility(View.GONE);
        formatVr.setVisibility(View.GONE);

        if (!controlsVisible) {
            Utils.expand(mCollapseWhileScroll);
            controlsVisible = true;
        }

        Utils.showProgress(mProgress);

        try {
            player.setAudioStreamType(AudioManager.STREAM_MUSIC);
            player.setDataSource(VideoDetail.this, Uri.parse(uri));
            player.setOnPreparedListener(VideoDetail.this);
            player.prepareAsync();
        } catch (IOException | IllegalStateException e) {
            e.printStackTrace();
        }


        mLinearLayoutManager.scrollToPositionWithOffset(position, 6);

    }

    private void initVideo() {




        formatVrSide = 1;
        formatVr.setImageResource(R.drawable.formatvr);

        if (!controlsVisible) {
            Utils.expand(mCollapseWhileScroll);
            controlsVisible = true;
        }

        if (isInitVideo && CheckConnection.isConnected(VideoDetail.this)) {

            Utils.showProgress(mProgress);        

            try
            {

                url = video; //copyArray.get(position).getSource();
                videoDescription = descIntent; //copyArray.get(position).getDescription();
                description.setText(videoDescription);

                videoTitle = titleIntent; //copyArray.get(position).getTitle();
                title.setText(videoTitle);
                String[] words = {"360", "virtual", "reality"
                        , "VR", "goggles", "Virtual", "Reality"
                        , "Cardboard", "cardboard", "GearVR"
                        , "Gear VR", "Oculus", "Spherical"};

                if (Utils.containsAny(videoTitle, words) || Utils.containsAny(videoDescription, words)) {

                    if (vrAssets == null) {

                        // INIT VR
                        isShowControls = false;
                        vrPlayer = PFObjectFactory.view(VideoDetail.this);
                        vrAssets = PFObjectFactory.assetFromUri(VideoDetail.this, Uri.parse(url), VideoDetail.this);
                        vrPlayer.displayAsset(vrAssets);
                        onPreparedVr();
                        if (vrPlayer.supportsNavigationMode(PFNavigationMode.MOTION)) {
                            fullscreenVr.setVisibility(View.VISIBLE);
                        } else {
                            fullscreenVr.setVisibility(View.GONE);
                        }
                        videoContainer.addView(vrPlayer.getView(), 0);
                        vrAssets.play();
                        isInitVideo = false;
                        playPause.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {

                                if (vrAssets.getStatus() == PFAssetStatus.PLAYING) {
                                    vrAssets.pause();
                                } else {
                                    vrAssets.play();
                                }
                            }
                        });
                        vrPlayer.getView().setOnTouchListener(new View.OnTouchListener() {
                            @Override
                            public boolean onTouch(View v, MotionEvent event) {
                                if (!isShowControls) {
                                    showController();
                                }
                                return false;
                            }
                        });
                    }

                } else {

                    mediaControllers.setVisibility(View.GONE);
                    fullscreenVr.setVisibility(View.GONE);
                    formatVr.setVisibility(View.GONE);
                    player.setAudioStreamType(AudioManager.STREAM_MUSIC);
                    player.setDataSource(VideoDetail.this, Uri.parse(url));
                    player.setOnPreparedListener(VideoDetail.this);
                    player.prepareAsync();
                }

            } catch (NullPointerException | IllegalStateException | IOException e) {
                e.printStackTrace();
            }

            mLinearLayoutManager.scrollToPositionWithOffset(position, 6);
           

        } else if (!CheckConnection.isConnected(VideoDetail.this)) {
            Utils.showTopSnackBar(VideoDetail.this, R.id.videocontainer, "#e85163", getResources().getString(R.string.top_snackbar_no_internet), "#FFFFFF");
        }
    }

    // MEDIA CONTROLLER VR
    public void showController() {
        isShowControls = true;
        formatVr.setVisibility(View.VISIBLE);
        mediaControllers.setVisibility(View.VISIBLE);
        final Handler handler = new Handler();

        Runnable run = new Runnable() {
            @Override
            public void run() {
                try {
                    Utils.setClearStatus(VideoDetail.this);
                    mediaControllers.setVisibility(View.GONE);
                    formatVr.setVisibility(View.GONE);
                    vrPlayer.getView().invalidate();
                    isShowControls = false;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };

        handler.removeCallbacks(run);
        handler.postDelayed(run, 3000);
    }

    public void prepareVrUI() {
        assert mediaControllers != null;
        mediaControllers.setVisibility(View.GONE);
        formatVr.setVisibility(View.GONE);
        View ffwd = mediaControllers.findViewById(R.id.ffwd);
        View rew = mediaControllers.findViewById(R.id.rew);
        ffwd.setVisibility(View.GONE);
        rew.setVisibility(View.GONE);
    }

    RecyclerAdapter.OnItemClickListener onItemClickListener = new RecyclerAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {
            resetVr();
            reset();
            VideoDetail.this.position = position;
            isInitVideo = true;
            //initVideo(copyArray.get(VideoDetail.this.position).getVideoId());
            initVideo();
        }
    };

    /*RecyclerOfflineAdapter.OnItemClickListener onOfflineItemClickListener = new RecyclerOfflineAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {
            reset();
            VideoDetail.this.position = position;
            isInitVideo = true;
            initVideo(offlineArray.get(VideoDetail.this.position).getPath(), true);
        }
    };*/

    // GOOGLE CAST

//    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
//    private void showOverlay() {
//        if (mOverlay != null) {
//            mOverlay.remove();
//        }
//        new Handler().postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                if (mMediaRouteMenuItem.isVisible()) {
//                    mOverlay = new IntroductoryOverlay.Builder(VideoDetail.this)
//                            .setMenuItem(mMediaRouteMenuItem)
//                            .setTitleText(R.string.intro_overlay_text)
//                            .setSingleTime()
//                            .setOnDismissed(new IntroductoryOverlay.OnOverlayDismissedListener() {
//                                @Override
//                                public void onOverlayDismissed() {
//                                    mOverlay = null;
//                                }
//                            })
//                            .build();
//                    mOverlay.show();
//                }
//            }
//        }, 1000);
//    }

    private void initMediaRouter() {
        mMediaRouter = MediaRouter.getInstance(getApplicationContext());
        mMediaRouteSelector = new MediaRouteSelector.Builder()
                .addControlCategory(
                        CastMediaControlIntent.categoryForCast(getString(R.string.cast_app_id)))
                .build();
        mMediaRouterCallback = new MediaRouterCallback();
    }

    private void startVideo(int videoPosition) {
        try {
//            MediaMetadata mediaMetadata = new MediaMetadata(MediaMetadata.MEDIA_TYPE_TV_SHOW);
//            mediaMetadata.putString(MediaMetadata.KEY_TITLE, videoTitle);
//            mediaMetadata.addImage(new WebImage(Uri.parse(FacebookUtils.getThumbnail(fanPageId))));
//            mediaMetadata.addImage(new WebImage(Uri.parse(copyArray.get(position).getThumbnail())));
//
//            final MediaInfo mediaInfo = new MediaInfo.Builder(url)
//                    .setContentType("video/mp4")
//                    .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
//                    .setMetadata(mediaMetadata)
//                    .build();

            mCastManager.startVideoCastControllerActivity(this, createMediaInfo(), videoPosition, true);
            mCastManager.play();

            //MediaQueueItem[] items = new MediaQueueItem[listOfMediaInfo().size()];

            /*for (int q = 0; q < listOfMediaInfo().size(); q++) {
                MediaQueueItem queueItem = new MediaQueueItem.Builder(listOfMediaInfo().get(q)).setAutoplay(
                        true).setPreloadTime(20).build();

                items[q] = queueItem;
            }*/

            //mCastManager.queueInsertItems(items, 1, null);

        } catch (TransientNetworkDisconnectionException | NoConnectionException | IllegalStateException | CastException e) {
            e.printStackTrace();
        }
    }

    private MediaInfo createMediaInfo() {
        MediaMetadata mediaMetadata = new MediaMetadata(MediaMetadata.MEDIA_TYPE_TV_SHOW);
        mediaMetadata.putString(MediaMetadata.KEY_TITLE, videoTitle);

        //mediaMetadata.addImage(new WebImage(Uri.parse(FacebookUtils.getThumbnail(fanPageId))));
        //mediaMetadata.addImage(new WebImage(Uri.parse(copyArray.get(position).getThumbnail())));

        return new MediaInfo.Builder(url)
                .setContentType("video/mp4")
                .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
                .setMetadata(mediaMetadata)
                .build();
    }

    private MediaInfo createMediaInfoItem(String title, String pageId, int thumb, String urlVideo) {
        MediaMetadata mediaMetadata = new MediaMetadata(MediaMetadata.MEDIA_TYPE_TV_SHOW);
        mediaMetadata.putString(MediaMetadata.KEY_TITLE, title);
        //mediaMetadata.addImage(new WebImage(Uri.parse(FacebookUtils.getThumbnail(pageId))));

        //mediaMetadata.addImage(new WebImage(Uri.parse(copyArray.get(thumb).getThumbnail())));

        return new MediaInfo.Builder(urlVideo)
                .setContentType("video/mp4")
                .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
                .setMetadata(mediaMetadata)
                .build();
    }

    /*private List<MediaInfo> listOfMediaInfo() {

        List<MediaInfo> queueList = new ArrayList<>();

        for (int c = 0; c < copyArray.size(); c++) {
            queueList.add(createMediaInfoItem(copyArray.get(c).getTitle(),
                    copyArray.get(c).getVideoId(), c, copyArray.get(c).getSource()));
        }

        return queueList;
    }*/

    private void resetVideo() {
        try {
            if (mRemoteMediaPlayer != null && mApiClient.isConnected()) {
                mRemoteMediaPlayer.stop(mApiClient).setResultCallback(new ResultCallback<RemoteMediaPlayer.MediaChannelResult>() {
                    @Override
                    public void onResult(@NonNull RemoteMediaPlayer.MediaChannelResult mediaChannelResult) {
                        Status status = mediaChannelResult.getStatus();
                        Log.w("TAG", "Unable to toggle pause: "
                                + status.getStatusCode());
                        startVideo(0);
                    }
                });
                mVideoIsLoaded = false;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);

        getMenuInflater().inflate(R.menu.main, menu);
        MenuItem mMediaRouteMenuItem = mCastManager.addMediaRouterButton(menu, R.id.media_route_menu_item);
        MediaRouteActionProvider mediaRouteActionProvider = (MediaRouteActionProvider) MenuItemCompat.getActionProvider(mMediaRouteMenuItem);
        mediaRouteActionProvider.setRouteSelector(mMediaRouteSelector);

        return true;
    }

    private void initCastClientListener() {
        mCastClientListener = new Cast.Listener() {
            @Override
            public void onApplicationStatusChanged() {

            }

            @Override
            public void onVolumeChanged() {

            }

            @Override
            public void onApplicationDisconnected(int statusCode) {
                teardown();
            }
        };
    }

    private void initRemoteMediaPlayer() {
        mRemoteMediaPlayer = new RemoteMediaPlayer();
        mRemoteMediaPlayer.setOnStatusUpdatedListener(new RemoteMediaPlayer.OnStatusUpdatedListener() {
            @Override
            public void onStatusUpdated() {
//                MediaStatus mediaStatus = mRemoteMediaPlayer.getMediaStatus();
//                if (mediaStatus != null) {
//                    // status
//                }
            }
        });

        mRemoteMediaPlayer.setOnMetadataUpdatedListener(new RemoteMediaPlayer.OnMetadataUpdatedListener() {
            @Override
            public void onMetadataUpdated() {
//                MediaInfo mediaInfo = mRemoteMediaPlayer.getMediaInfo();
//                if (mediaInfo != null) {
//                    MediaMetadata metadata = mediaInfo.getMetadata();
//                }
            }
        });

        if (mApiClient != null) {
            mRemoteMediaPlayer.requestStatus(mApiClient).setResultCallback(new ResultCallback<RemoteMediaPlayer.MediaChannelResult>() {
                @Override
                public void onResult(@NonNull RemoteMediaPlayer.MediaChannelResult mediaChannelResult) {
                    if (!mediaChannelResult.getStatus().isSuccess()) {
                        Log.e("TAG", "Failed to request status.");
                    }
                }
            });
        }
    }

    private void launchReceiver() {
        Cast.CastOptions.Builder apiOptionsBuilder = new Cast.CastOptions.Builder(mSelectedDevice, mCastClientListener);

        ConnectionCallbacks mConnectionCallbacks = new ConnectionCallbacks();
        ConnectionFailedListener mConnectionFailedListener = new ConnectionFailedListener();
        mApiClient = new GoogleApiClient.Builder(this)
                .addApi(Cast.API, apiOptionsBuilder.build())
                .addConnectionCallbacks(mConnectionCallbacks)
                .addOnConnectionFailedListener(mConnectionFailedListener)
                .build();

        mApiClient.connect();
    }

    private void reconnectChannels(Bundle hint) {
        if ((hint != null) && hint.getBoolean(Cast.EXTRA_APP_NO_LONGER_RUNNING)) {
            teardown();
        } else {
            try {
                Cast.CastApi.setMessageReceivedCallbacks(mApiClient, mRemoteMediaPlayer.getNamespace(), mRemoteMediaPlayer);
            } catch (IOException | NullPointerException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onStatusMessage(final PFAsset pfAsset, PFAssetStatus pfAssetStatus) {
        switch (pfAssetStatus) {

            case COMPLETE:
                if (monitorTimer != null) {
                    monitorTimer.cancel();
                    monitorTimer.purge();
                    monitorTimer = null;
                }
                resetVr();
                isInitVideo = true;
                pos = 0;
                nextVideo();
                break;
            case PLAYING:
                scrubber.setEnabled(true);
                playPause.setImageResource(R.drawable.ic_media_pause);
                scrubber.setMax((int) pfAsset.getDuration());
                if (monitorTimer == null) {
                    monitorTimer = new Timer();
                    final TimerTask task = new TimerTask() {
                        public void run() {
                            if (updateThumb) {
                                scrubber.setProgress((int) pfAsset.getPlaybackTime());
                            }
                        }
                    };
                    monitorTimer.schedule(task, 0, 33);
                }
                break;
            case STOPPED:
                if (monitorTimer != null) {
                    monitorTimer.cancel();
                    monitorTimer.purge();
                    monitorTimer = null;
                }
                scrubber.setProgress(0);
                scrubber.setEnabled(false);
                break;
            case PAUSED:
                playPause.setImageResource(R.drawable.ic_media_play);
                break;
        }

    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {
        updateThumb = false;
    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        vrAssets.setPLaybackTime(seekBar.getProgress());
        updateThumb = true;
    }

    private class ConnectionFailedListener implements GoogleApiClient.OnConnectionFailedListener {
        @Override
        public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
            teardown();
        }
    }

    private void teardown() {
        if (mApiClient != null) {
            if (mApplicationStarted) {
                try {
                    Cast.CastApi.stopApplication(mApiClient);
                    if (mRemoteMediaPlayer != null) {
                        Cast.CastApi.removeMessageReceivedCallbacks(mApiClient, mRemoteMediaPlayer.getNamespace());
                        mRemoteMediaPlayer = null;
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
                mApplicationStarted = false;
            }
            if (mApiClient.isConnected()) {
                mApiClient.disconnect();
            }
            mApiClient = null;
        }
        mSelectedDevice = null;
        mVideoIsLoaded = false;
    }

    private class MediaRouterCallback extends MediaRouter.Callback {

        @Override
        public void onRouteAdded(MediaRouter router, MediaRouter.RouteInfo info) {
            //Show info when is visible
//            showOverlay();
        }

        @Override
        public void onRouteSelected(MediaRouter router, MediaRouter.RouteInfo info) {
            initCastClientListener();
            initRemoteMediaPlayer();

            mSelectedDevice = CastDevice.getFromBundle(info.getExtras());

            launchReceiver();
        }

        @Override
        public void onRouteUnselected(MediaRouter router, MediaRouter.RouteInfo info) {
            teardown();
            mSelectedDevice = null;
            mVideoIsLoaded = false;
        }
    }

    @Override
    public void onBackPressed() {

        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            isFullscreen = false;
        } else {
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        mMediaRouter.addCallback(mMediaRouteSelector, mMediaRouterCallback, MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN);
    }

    @Override
    protected void onPause() {
        if (isFinishing()) {
            mMediaRouter.removeCallback(mMediaRouterCallback);
        }
        if (isPlaying()) {
            pause();
        }

        super.onPause();
    }

    @Override
    public void onDestroy() {
        resetVr();
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        super.onDestroy();
    }

    private class ConnectionCallbacks implements GoogleApiClient.ConnectionCallbacks {

        @Override
        public void onConnected(Bundle hint) {
            if (mWaitingForReconnect) {
                mWaitingForReconnect = false;
                reconnectChannels(hint);
            } else {
                try {
                    Cast.CastApi.launchApplication(mApiClient, getString(R.string.cast_app_id))
                            .setResultCallback(
                                    new ResultCallback<Cast.ApplicationConnectionResult>() {
                                        @Override
                                        public void onResult(
                                                @NonNull Cast.ApplicationConnectionResult applicationConnectionResult) {
                                            Status status = applicationConnectionResult.getStatus();
                                            if (status.isSuccess()) {
                                                //Values that can be useful for storing/logic
                                                ApplicationMetadata applicationMetadata = applicationConnectionResult.getApplicationMetadata();
                                                String sessionId = applicationConnectionResult.getSessionId();
                                                String applicationStatus = applicationConnectionResult.getApplicationStatus();
                                                boolean wasLaunched = applicationConnectionResult.getWasLaunched();

                                                mApplicationStarted = true;
                                                reconnectChannels(null);
                                                startVideo(getCurrentPosition());
                                            }
                                        }
                                    }
                            );
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void onConnectionSuspended(int i) {
            mWaitingForReconnect = true;
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt("pos", getCurrentPosition());
        outState.putInt("position", position);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    class PhoneListener extends PhoneStateListener {

        boolean resumePhoneCall = false;

        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            switch (state) {
                case TelephonyManager.CALL_STATE_OFFHOOK:
                case TelephonyManager.CALL_STATE_RINGING:
                    resumePhoneCall = isPlaying();
                    pause();
                    break;
                case TelephonyManager.CALL_STATE_IDLE:
                    if (resumePhoneCall) {
                        start();
                    }
                    break;
                default:
                    break;
            }
        }

    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        int action = event.getAction();
        int keyCode = event.getKeyCode();

        switch (keyCode) {
            case KeyEvent.KEYCODE_VOLUME_UP:
                if (action == KeyEvent.ACTION_DOWN) {
                    if (mRemoteMediaPlayer != null && mVideoIsLoaded) {
                        double currentVolume = Cast.CastApi.getVolume(mApiClient);
                        if (currentVolume < 1.0) {
                            try {
                                Cast.CastApi.setVolume(mApiClient,
                                        Math.min(currentVolume + VOLUME_INCREMENT, 1.0));
                            } catch (Exception e) {
                                Log.e("TAG", "unable to set volume", e);
                            }
                        }
                    } else {

                        int volume_level = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
                        if (volume_level < audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)) {
                            audioManager.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FLAG_SHOW_UI);
                        }
                    }
                }
                return true;
            case KeyEvent.KEYCODE_VOLUME_DOWN:
                if (action == KeyEvent.ACTION_DOWN) {
                    if (mRemoteMediaPlayer != null && mVideoIsLoaded) {
                        double currentVolume = Cast.CastApi.getVolume(mApiClient);
                        if (currentVolume > 0.0) {
                            try {
                                Cast.CastApi.setVolume(mApiClient,
                                        Math.max(currentVolume - VOLUME_INCREMENT, 0.0));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } else {
                        int volume_level = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
                        if (volume_level > 0) {
                            audioManager.adjustVolume(AudioManager.ADJUST_LOWER, AudioManager.FLAG_SHOW_UI);
                        }
                    }
                }
                return true;
            default:
                return super.dispatchKeyEvent(event);
        }
    }
}
