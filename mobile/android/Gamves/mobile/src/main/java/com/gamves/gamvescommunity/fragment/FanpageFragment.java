package com.gamves.gamvescommunity.fragment;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.gamves.gamvescommunity.GamvesApplication;
import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.VideoDetail;
import com.gamves.gamvescommunity.adapters.RecyclerVideosAdapter;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.model.VideosListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.gamves.gamvescommunity.utils.KeySaver;
import com.gamves.gamvescommunity.utils.Utils;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseRelation;
import com.wang.avi.AVLoadingIndicatorView;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link FanpageFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class FanpageFragment extends BaseFragment {

    private HomeFragment homeFragment;

    private String TAG = "FanpageFragment";

    private FanPageListItem fanpageListItem;

    private ImageView fanpage_arrow_back;
    private ImageView fanpage_like;
    private ImageView fanpage_cover;
    private TextView fanpage_name;
    private TextView fanpages_amount;
    private AVLoadingIndicatorView category_progress_balls;

    private int cover_height;

    private int fragmentWidth, fragmentHeight;

    private RecyclerVideosAdapter vAdapter;

    //private List<FanPageListItem> fanpageList;

    private RecyclerView fanpageRecyclerView;

    private LinearLayout category_data_row;

    private int iRow;

    private Context context;

    private int videosCount;

    private FanPageListItem fanpageActive;

    private List<VideosListItem> videoList;

    public FanpageFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment
     * @return A new instance of fragment FirstFragment.
     */
    public static final FanpageFragment newInstance()
    {
        FanpageFragment fragment = new FanpageFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        this.context = getContext();

        homeFragment = ((HomeFragment)this.getParentFragment());

        DisplayMetrics displaymetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        fragmentHeight = displaymetrics.heightPixels;
        fragmentWidth = displaymetrics.widthPixels;

        cover_height = fragmentWidth * 6 / 16;

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {

        View view = inflater.inflate(R.layout.fragment_category_list, container, false);

        fanpage_arrow_back = (ImageView) view.findViewById(R.id.category_arrow_back);

        fanpage_arrow_back.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v)
            {

                ViewPager pager = homeFragment.getViewPager();

                pager.setCurrentItem(0);
            }
        });

        fanpage_like = (ImageView) view.findViewById(R.id.category_like);

        fanpage_like.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {

            }
        });

        fanpage_cover = (ImageView) view.findViewById(R.id.category_cover);

        fanpage_name = (TextView) view.findViewById(R.id.category_name);

        fanpages_amount = (TextView) view.findViewById(R.id.fanpages_amount);

        fanpageRecyclerView = (RecyclerView) view.findViewById(R.id.category_detail_list);

        //category_data_row.getLayoutParams().height = cover_height;
        //category_data_row.getLayoutParams().width = fragmentWidth;

        category_progress_balls = (AVLoadingIndicatorView) view.findViewById(R.id.category_progress_balls);

        return view;
    }



    @Override
    public void updateData()
    {

        fanpageActive = HomeDataSingleton.getInstance().getActiveFanpage();

        fanpage_cover.setImageBitmap(fanpageActive.getPageCover());

        fanpage_name.setText(fanpageActive.getPageName());

        getVideoData(fanpageActive);

    }

    @Override
    public void finishedLoad() {

    }

    RecyclerVideosAdapter.OnItemClickListener onItemViedeoClickListener = new RecyclerVideosAdapter.OnItemClickListener() {

        @Override
        public void onItemClick(View view, int position, int mainPosition) {

            Intent i = new Intent(context, VideoDetail.class);

            String id = videoList.get(position).getVideoId();
            i.putExtra("videoId", id);
            startActivity(i);
        }

    };

    private void getVideoData(FanPageListItem fanItem) {

        ParseObject fanpageObject = fanItem.getFanpageObject();

        ParseRelation fanpageVideosRelation = fanpageObject.getRelation("videos");

        ParseQuery videosQuery = fanpageVideosRelation.getQuery();

        videosQuery.findInBackground(new FindCallback<ParseObject>() {

            @Override
            public void done(List<ParseObject> objectsRow, ParseException e) {

                if (objectsRow != null && iRow < objectsRow.size()) {

                    try {

                        videosCount = objectsRow.size();

                        for (int j = 0; j < videosCount; j++)
                        {
                            String source = objectsRow.get(j).getString("source");
                            String videoId = objectsRow.get(j).getString("videoId");
                            String idString  = objectsRow.get(j).getString("objectId");
                            String thumbnailUrl = objectsRow.get(j).getString("thumbnailUrl");
                            String titletitle = objectsRow.get(j).getString("title");
                            String description = objectsRow.get(j).getString("description");
                            VideosListItem video = new VideosListItem(videoId, j, thumbnailUrl, titletitle, description, source);
                            new LoadVideos().execute(video);
                        }

                    } catch (Exception e1) {

                        e1.printStackTrace();
                    }


                }
            }
        });
    }


    public class LoadVideos extends AsyncTask<VideosListItem, Void, VideosListItem> {

        private int id;

        @Override
        protected VideosListItem doInBackground(VideosListItem... params) {

            VideosListItem videoItem = (VideosListItem) params[0];

            this.id = id;

            videoItem.setThumbnailBitmap(downloadImage(videoItem.getThumbnail()));

            return videoItem;
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
        protected void onPostExecute(VideosListItem result)
        {
            HomeDataSingleton.getInstance().addVideoToFunpage(result);

            if (result.getId() == (videosCount-1))
            {
                videoList = HomeDataSingleton.getInstance().getActiveFanpage().getVideos();

                int amount = HomeDataSingleton.getInstance().getActiveFanpage().getVideos().size();

                String vamount = Integer.toString(amount);

                fanpages_amount.setText(vamount);

                assert fanpageRecyclerView != null;
                fanpageRecyclerView.setHasFixedSize(true);

                vAdapter = new RecyclerVideosAdapter(getContext(), videoList);

                fanpageRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
                fanpageRecyclerView.setAdapter(vAdapter);

                vAdapter.setOnItemClickListener(onItemViedeoClickListener);

                category_progress_balls.setVisibility(View.GONE);
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
