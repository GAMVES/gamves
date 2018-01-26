package com.gamves.gamvescommunity;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.flaviofaria.kenburnsview.KenBurnsView;
import com.gamves.gamvescommunity.adapters.RecyclerOfflineAdapter;
import com.gamves.gamvescommunity.model.VideosListSD;
import com.gamves.gamvescommunity.utils.RippleBackground;
import com.gamves.gamvescommunity.utils.Utils;
import com.github.clans.fab.FloatingActionButton;
import com.google.gson.Gson;

import java.io.File;
import java.util.List;
import java.util.Random;



import jp.wasabeef.glide.transformations.BlurTransformation;

/**
 * Created by mariano on 4/23/16.
 **/
public class VideosOffline extends AppCompatActivity {

    private List<VideosListSD> sdVideos;
    private RecyclerView mRecyclerView;
    private FloatingActionButton fab;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Utils.setStatusBarTranslucent(true, false, this, getSupportActionBar());
        setContentView(R.layout.activity_video_profile);

        fab = (FloatingActionButton) findViewById(R.id.fab);
        RippleBackground rippleBackground = (RippleBackground) findViewById(R.id.content);

        assert fab != null;
        fab.setEnabled(false);

        fab.setOnClickListener(onFabClickListener);

        KenBurnsView mProfileImage = (KenBurnsView) findViewById(R.id.profile_main_img);
        ImageView mProfileThumb = (ImageView) findViewById(R.id.profile_main_thumb);

        assert mProfileThumb != null;
        Glide.with(this)
                .load("")
                .placeholder(Utils.setDrawable(R.drawable.no_signal))
                .into(mProfileThumb);

        sdVideos = Utils.getListOfSDVideos();

        mRecyclerView = (RecyclerView) findViewById(R.id.profile_video_list);
        RecyclerOfflineAdapter mAdapter = new RecyclerOfflineAdapter(VideosOffline.this, sdVideos);

        fab.setEnabled(true);

        assert rippleBackground != null;
        rippleBackground.startRippleAnimation();

        LinearLayoutManager mLinearLayoutManager = new LinearLayoutManager(VideosOffline.this);
        mLinearLayoutManager.setOrientation(LinearLayoutManager.VERTICAL);

        mRecyclerView.setLayoutManager(mLinearLayoutManager);
        mRecyclerView.setAdapter(mAdapter);

        mAdapter.setOnItemClickListener(onItemClickListener);

        if (sdVideos.size() > 0) {
            Random r = new Random();
            int random = r.nextInt(sdVideos.size());

            assert mProfileImage != null;
            Glide.with(this)
                    .load(new File(sdVideos.get(random)
                            .getPath()
                            .substring(0, sdVideos.get(random).getPath().length() - 4) + ".png"))
                    .bitmapTransform(new BlurTransformation(this, 5))
                    .into(mProfileImage);
        } else {
            fab.setEnabled(false);
            assert mProfileImage != null;
            Glide.with(this)
                    .load("")
                    .placeholder(Utils.setDrawable(R.drawable.bg_banner))
                    .into(mProfileImage);
        }

    }

    @Override
    public void onResume() {
        super.onResume();

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                List<VideosListSD> updateList;
                updateList = Utils.getListOfSDVideos();
                RecyclerOfflineAdapter cleanAdapter = new RecyclerOfflineAdapter(VideosOffline.this, updateList);
                mRecyclerView.setAdapter(cleanAdapter);
                cleanAdapter.notifyDataSetChanged();
                cleanAdapter.setOnItemClickListener(onItemClickListener);

                if (updateList.size() < 1) {
                    fab.setEnabled(false);
                }
            }
        });
    }

    @Override
    public void onPause() {
        Log.e("state", "Pause");
        super.onPause();
    }

    ///////////////
    // LISTENERS //
    ///////////////

    View.OnClickListener onFabClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Gson gson = new Gson();

            Intent i = new Intent(VideosOffline.this, VideoDetail.class);
            i.putExtra("id", sdVideos.get(0).getPath());
            i.putExtra("channel", "Videos Offline");
            i.putExtra("video_list", gson.toJson(sdVideos));
            i.putExtra("position", 0);
            i.putExtra("title", sdVideos.get(0).getTitle());
            i.putExtra("description", sdVideos.get(0).getDescription());
            i.putExtra("offline", true);
            startActivity(i);
        }
    };

    RecyclerOfflineAdapter.OnItemClickListener onItemClickListener = new RecyclerOfflineAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {

            Gson gson = new Gson();

            Intent i = new Intent(VideosOffline.this, VideoDetail.class);
            i.putExtra("id", sdVideos.get(position).getPath());
            i.putExtra("channel", "Videos Offline");
            i.putExtra("video_list", gson.toJson(sdVideos));
            i.putExtra("position", position);
            i.putExtra("title", sdVideos.get(position).getTitle());
            i.putExtra("description", sdVideos.get(position).getDescription());
            i.putExtra("offline", true);
            startActivity(i);
        }
    };
}
