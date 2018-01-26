package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.gamves.gamvescommunity.model.VideosListSD;

import java.io.File;
import java.util.List;

import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.utils.Utils;

/**
 * Created by mariano on 2/23/16.
 **/

public class RecyclerOfflineAdapter extends RecyclerView.Adapter<RecyclerOfflineAdapter.ViewHolder> {

    Context context;
    private List<VideosListSD> videoArray;

    OnItemClickListener mItemClickListener;

    private int highlightItem = 0;
    private boolean isPlaylist = false;

    public RecyclerOfflineAdapter(Context context, List<VideosListSD> videoArray) {
        this.context    = context;
        this.videoArray = videoArray;
    }

    public void toggleSelection(int pos, boolean playlist) {
        this.highlightItem = pos;
        this.isPlaylist = playlist;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_video_recycler, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {

        if (context != null) {
            Glide.with(context)
                    .load(new File(videoArray.get(position)
                            .getPath()
                            .substring(0, videoArray.get(position).getPath().length() - 4) + ".png"))
                    .into(holder.mVideoImg);
        }

        holder.mVideoTitle.setText(videoArray.get(position).getTitle());

        String savedOn = (context.getResources().getString(R.string.offline_saved_on) + " " + Utils.getFormatDate(videoArray.get(position).getTimeSaved()));
        holder.mVideoTime.setText(savedOn);

        holder.mVideoTimer.setVisibility(View.GONE);

        String videoDescription = videoArray.get(position).getDescription() + context.getResources().getString(R.string.offline_dots);
        holder.mVideoDesc.setText(videoDescription);

        holder.mVideoTitle.setText(videoArray.get(position).getTitle());

        if (position == highlightItem && isPlaylist) {
            setToggleColor(holder, "#30b656", "#FFFFFF");
        } else {
            setToggleColor(holder, "#FFFFFF", "#606060");
        }

    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public int getItemCount() {
        return videoArray.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener{

        public ImageView mVideoImg;
        public TextView mVideoTitle;
        public TextView mVideoDesc;
        public TextView mVideoTime;
        public TextView mVideoTimer;
        public RelativeLayout mMainView;

        public ViewHolder(View itemView) {
            super(itemView);
            mMainView = (RelativeLayout) itemView.findViewById(R.id.main_holder);
            mVideoImg = (ImageView) itemView.findViewById(R.id.video_thumb);
            mVideoTitle = (TextView) itemView.findViewById(R.id.video_title);
            mVideoDesc = (TextView) itemView.findViewById(R.id.video_description);
            mVideoTime = (TextView) itemView.findViewById(R.id.video_time_ago);
            mVideoTimer = (TextView) itemView.findViewById(R.id.timer_video);
            mMainView.setOnClickListener(this);

            mVideoTitle.setMaxLines(1);
            mVideoDesc.setMaxLines(2);
            mVideoDesc.setEllipsize(TextUtils.TruncateAt.END);
        }

        @Override
        public void onClick(View v) {
            if (mItemClickListener != null) {
                mItemClickListener.onItemClick(itemView, getAdapterPosition());
            }
        }
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position);
    }

    public void setOnItemClickListener(final OnItemClickListener mItemClickListener) {
        this.mItemClickListener = mItemClickListener;
    }

    private void setToggleColor(ViewHolder holder, String bgColor, String textColor) {
        holder.mMainView.setBackgroundColor(Color.parseColor(bgColor));
        holder.mVideoDesc.setTextColor(Color.parseColor(textColor));
        holder.mVideoTitle.setTextColor(Color.parseColor(textColor));
        holder.mVideoTime.setTextColor(Color.parseColor(textColor));
    }
}