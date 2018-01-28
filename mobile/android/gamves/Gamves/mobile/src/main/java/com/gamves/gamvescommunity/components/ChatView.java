package com.gamves.gamvescommunity.components;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.adapters.ListMessageAdapter;
import com.gamves.gamvescommunity.model.Consersation;
import com.gamves.gamvescommunity.model.Message;
import com.gamves.gamvescommunity.model.ParseAuxiliars;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseLiveQueryClient;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.SubscriptionHandling;

import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;

/**
 * Created by Jose on 27/01/2018.
 */

public class ChatView extends ViewGroup {

    private LinearLayout video_title_group;
    private RelativeLayout editLayout;
    private RecyclerView recyclerChat;
    private EditText messageEdit;
    private ImageButton btnSend;

    private Hashtable<String, ParseAuxiliars.GamvesParseUser> userChat = new Hashtable<String, ParseAuxiliars.GamvesParseUser>();

    //LiveQueries
    private ParseLiveQueryClient chatClient = ParseLiveQueryClient.Factory.getClient();
    private ParseLiveQueryClient feedClient = ParseLiveQueryClient.Factory.getClient();
    private ParseLiveQueryClient onlineClient = ParseLiveQueryClient.Factory.getClient();

    private ParseQuery<ParseObject> videoQuery;
    private ParseQuery<ParseObject> feedQuery;

    private ListMessageAdapter adapter;
    private Consersation consersation;
    public static HashMap<String, Bitmap> bitmapAvataFriend;

    public static final int VIEW_TYPE_USER_MESSAGE = 0;
    public static final int VIEW_TYPE_FRIEND_MESSAGE = 1;

    private LinearLayoutManager mLinearLayoutManager;

    private int chatId;

    private Boolean avatarsLoaded=false, dataLoaded=false;

    private Activity activity;
    private Context context;

    public ChatView(Context context) {
        super(context);
        this.init(context);
    }

    public ChatView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.init(context);
    }

    public ChatView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.init(context);
    }

    public ChatView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        this.init(context);
    }

    private void init(Context context){

        this.context = context;

        this.activity = (Activity) context;

        this.initializeFeedSubscription();

        video_title_group = (LinearLayout) this.findViewById(R.id.video_title_group);

        editLayout = (RelativeLayout) this.findViewById(R.id.editLayout);

        recyclerChat = (RecyclerView) this.findViewById(R.id.recyclerChat);

        consersation = new Consersation();

        new Thread(new Runnable(){

            @Override
            public void run()
            {
                countUsersOnChat();
            }

        }).start();

        //Load LiveQuery
        /*new VideoDetail.LoadLiveQueryClient(new VideoDetail.OnLiveQueryCompleted() {

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

        }).execute();*/

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
                message.put("videoId", chatId);
                message.put("userId", ParseUser.getCurrentUser().getObjectId());

                message.saveInBackground(new SaveCallback() {

                    @Override
                    public void done(ParseException e) {
                        Log.i("Message", "Sent correctly");
                    }

                });

                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //Setting the text blank again
                        //UDATE RECYCLEVIEW
                        //message.setText("");
                    }
                });
            }
        });

        mLinearLayoutManager = new LinearLayoutManager(this.context);
        mLinearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);

        recyclerChat = (RecyclerView) findViewById(R.id.recyclerChat);

        assert recyclerChat != null;
        recyclerChat.setLayoutManager(mLinearLayoutManager);

        //mLinearLayoutManager.scrollToPositionWithOffset(position, 6);
    }

    private void initializeFeedSubscription() {

        videoQuery = ParseQuery.getQuery("ChatVideo");
        videoQuery.whereEqualTo("chatId", chatId);
        SubscriptionHandling<ParseObject> chatSubscription = chatClient.subscribe(videoQuery);

        chatSubscription.handleEvents(new SubscriptionHandling.HandleEventsCallback<ParseObject>() {

            @Override
            public void onEvents(ParseQuery<ParseObject> query, SubscriptionHandling.Event event, ParseObject object) {

            }

        });

        feedQuery = ParseQuery.getQuery("ChatFeed");
        feedQuery.whereEqualTo("chatId", chatId);
        SubscriptionHandling<ParseObject> feedSubscription = feedClient.subscribe(feedQuery);

        feedSubscription.handleEvents(new SubscriptionHandling.HandleEventsCallback<ParseObject>() {

            @Override
            public void onEvents(ParseQuery<ParseObject> query, SubscriptionHandling.Event event, ParseObject object) {

            }
        });

    }



    @Override
    protected void onLayout(boolean b, int i, int i1, int i2, int i3) {

    }

    public void countUsersOnChat() {

        final ParseQuery<ParseObject> queryChatVideo = ParseQuery.getQuery("ChatVideo");

        queryChatVideo.whereEqualTo("videoId", chatId);

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
                                ParseAuxiliars.GamvesParseUser gamvesUser = new ParseAuxiliars.GamvesParseUser();
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

    private int counti = 0;
    private int countPics = 1;

    private void getVideoData(final int usersCount) {

        videoQuery.findInBackground(new FindCallback<ParseObject>() {

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
                                                    ParseAuxiliars.GamvesParseUser gamvesUse = userChat.get(userId);
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
        adapter = new ListMessageAdapter(context, consersation);
        recyclerChat.setAdapter(adapter);
        adapter.notifyDataSetChanged();
        mLinearLayoutManager.scrollToPosition(consersation.getListMessageData().size() - 1);
        dataLoaded = false;
        avatarsLoaded = false;
    }

    /*class LoadLiveQueryClient extends AsyncTask<String, Void, Boolean> {

        private Exception exception;

        private VideoDetail.OnLiveQueryCompleted listener;

        public LoadLiveQueryClient(VideoDetail.OnLiveQueryCompleted listener) {
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
    }*/


}
