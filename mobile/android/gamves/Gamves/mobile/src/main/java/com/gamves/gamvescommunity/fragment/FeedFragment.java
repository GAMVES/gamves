package com.gamves.gamvescommunity.fragment;

import android.app.Fragment;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.adapters.RecyclerFeedAdapter;
import com.gamves.gamvescommunity.model.FeedItem;

import com.gamves.gamvescommunity.singleton.DataSingleton;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseLiveQueryClient;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SubscriptionHandling;
import com.wang.avi.AVLoadingIndicatorView;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

/**
 * Created by Jose on 4/18/16.
 **/
public class FeedFragment extends Fragment {

    private String TAG = "FeedFragment";

    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private String mParam1;
    private String mParam2;

    private RecyclerFeedAdapter fAdapter;

    private RecyclerView feedRecyclerView;

    private OnFragmentInteractionListener mListener;

    private List<FeedItem> feedList;

    ParseLiveQueryClient parseLiveQueryClient = ParseLiveQueryClient.Factory.getClient();

    private int chatId;
    private int feedCount;

    private AVLoadingIndicatorView feed_progress_balls;

    public FeedFragment() {
        // Required empty public constructor
    }

    public static FeedFragment newInstance(String param1, String param2) {
        FeedFragment fragment = new FeedFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }

        this.initializeFeedSubscription();
    }

    private void initializeFeedSubscription() {

        ParseQuery<ParseObject> parseQuery = ParseQuery.getQuery("ChatVideo");
        parseQuery.whereEqualTo("chatId", chatId);

        SubscriptionHandling<ParseObject> subscriptionHandling = parseLiveQueryClient.subscribe(parseQuery);

        subscriptionHandling.handleEvents(new SubscriptionHandling.HandleEventsCallback<ParseObject>() {

            @Override
            public void onEvents(ParseQuery<ParseObject> query, SubscriptionHandling.Event event, ParseObject object) {
                // HANDLING all events
            }

        });

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_feed, container, false);

        feedRecyclerView = (RecyclerView) view.findViewById(R.id.recyclerFeed);

        feed_progress_balls = (AVLoadingIndicatorView) view.findViewById(R.id.category_progress_balls);

        return view;
    }

    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {

        void onFragmentInteraction(Uri uri);
    }


    public void getFeedData() {

        final ParseQuery<ParseObject> queryChatFeed = ParseQuery.getQuery("ChatFeed");
        queryChatFeed.whereContains("members", ParseUser.getCurrentUser().getObjectId());

        queryChatFeed.findInBackground(new FindCallback<ParseObject>() {

            @Override
            public void done(List<ParseObject> objectsRow, ParseException e) {

                if (objectsRow != null) {

                    try {

                        feedCount = objectsRow.size();

                        for (int j = 0; j < feedCount; j++)
                        {
                            String id = objectsRow.get(j).getObjectId();
                            String text = objectsRow.get(j).getString("lastMessage");
                            Boolean isVideoChat = objectsRow.get(j).getBoolean("isVideoChat");
                            String lasPoster = objectsRow.get(j).getString("lasPoster");
                            int chatId = objectsRow.get(j).getInt("chatId");
                            String users = objectsRow.get(j).getString("users");
                            Boolean usersLoaded = objectsRow.get(j).getBoolean("usersLoaded");
                            Boolean imagesLoaded = objectsRow.get(j).getBoolean("imagesLoaded");
                            Boolean badgeIsActive = objectsRow.get(j).getBoolean("badgeIsActive");
                            Boolean badgeNumber = objectsRow.get(j).getBoolean("badgeNumber");

                            FeedItem feed = new FeedItem(
                                    j,
                                    text,
                                    isVideoChat,
                                    lasPoster,
                                    chatId,
                                    users,
                                    usersLoaded,
                                    imagesLoaded,
                                    badgeIsActive,
                                    badgeNumber,
                                    (ParseObject) objectsRow.get(j));


                            new LoadFeeds().execute(feed);
                        }

                    } catch (Exception e1) {

                        e1.printStackTrace();
                    }
                }
            }
        });
    }

    RecyclerFeedAdapter.OnItemClickListener onItemFeedClickListener = new RecyclerFeedAdapter.OnItemClickListener() {

        @Override
        public void onItemClick(View view, int position, int mainPosition) {

            /*Intent i = new Intent(context, VideoDetail.class);

            String id = videoList.get(position).getVideoId();
            i.putExtra("videoId", id);
            startActivity(i);*/
        }

    };


    public class LoadFeeds extends AsyncTask<FeedItem, Void, FeedItem> {

        private int id;

        @Override
        protected FeedItem doInBackground(FeedItem... params) {

            FeedItem feedItem = (FeedItem) params[0];

            this.id = id;

            //feedItem.setChatThumbnail(downloadImage(feedItem.));

            //videoItem.setThumbnailBitmap(downloadImage(videoItem.getThumbnail()));

            //public ImageView chatThumbnail;
            //public ImageView userThumbnail;

            return feedItem;
        }

        private Bitmap downloadImage(String urlPAth)
        {
            try
            {

                URL url = new URL(urlPAth);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.connect();
                InputStream input = connection.getInputStream();
                Bitmap myBitmap = BitmapFactory.decodeStream(input);

                return myBitmap;

            } catch (Exception e)
            {
                Log.d(TAG,e.getMessage());
            }

            return null;
        }

        @Override
        protected void onPostExecute(FeedItem result)
        {
            DataSingleton.getInstance().addFeedToFeeList(result);

            if (result.getId() == (feedCount-1))
            {
                feedList = DataSingleton.getInstance().getFeedList();

                int amount = DataSingleton.getInstance().getFeedList().size();

                String famount = Integer.toString(amount);

                assert feedRecyclerView != null;
                feedRecyclerView.setHasFixedSize(true);

                fAdapter = new RecyclerFeedAdapter(getContext(), feedList);

                feedRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
                feedRecyclerView.setAdapter(fAdapter);

                fAdapter.setOnItemClickListener(onItemFeedClickListener);

                feed_progress_balls.setVisibility(View.GONE);
            }
        }

        @Override
        protected void onPreExecute()
        {

        }

        @Override
        protected void onProgressUpdate(Void... values)
        {

        }


    }
}
