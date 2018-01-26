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
import com.gamves.gamvescommunity.model.VideosListItem;
import com.gamves.gamvescommunity.utils.Utils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import com.gamves.gamvescommunity.R;

/**
 * Created by mariano on 2/23/16.
 **/

public class RecyclerAdapter extends RecyclerView.Adapter<RecyclerAdapter.ViewHolder> {

    Context context;
    private List<VideosListItem> videoArray;

    OnItemClickListener mItemClickListener;

    private int highlightItem = 0;
    private boolean isPlaylist = false;
    private boolean isParse = false;

    private SimpleDateFormat date;

    public RecyclerAdapter(Context context, List<VideosListItem> videoArray) {
        this.context = context;
        this.videoArray = videoArray;
    }

    public void toggleSelection(int pos, boolean playlist) {
        this.highlightItem = pos;
        this.isPlaylist = playlist;
    }

    public void isParse(boolean parse) {
        this.isParse = parse;
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
                    .load("")
                    .placeholder(Utils.setDrawable(R.drawable.home_gradient_eight))
                    .into(holder.mVideoImg);
        }

        holder.mVideoDesc.setText(videoArray.get(position).getDescription());

        holder.mVideoTitle.setText(videoArray.get(position).getTitle());

        if (isParse){
            date = new SimpleDateFormat("EEE MMM dd HH:mm:ss Z yyyy", new Locale("en"));
        } else {
            date = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ssZ", new Locale("en"));
        }

        if (videoArray.get(position).isFeatured() && !isPlaylist) {
            holder.mIsFeatured.setVisibility(View.VISIBLE);
            holder.mSeparator.setVisibility(View.VISIBLE);
        } else {
            holder.mIsFeatured.setVisibility(View.GONE);
            holder.mSeparator.setVisibility(View.GONE);
        }

        try {
            Date time = date.parse(videoArray.get(position).getCreatedTime());
            long millis = time.getTime();

            holder.mVideoTime.setText(Utils.getFormatDate(millis));
            holder.mVideoTimer.setText(Utils.convertToHMmSs(videoArray.get(position).getLength()));

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (context != null) {
            Glide.with(context)
                    .load(videoArray.get(position).getThumbnail())
                    .into(holder.mVideoImg);
        }

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

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        public View mSeparator;
        public ImageView mVideoImg;
        public TextView mVideoTitle;
        public TextView mVideoDesc;
        public TextView mVideoTime;
        public TextView mVideoTimer;
        public TextView mIsFeatured;
        public RelativeLayout mMainView;

        public ViewHolder(View itemView) {
            super(itemView);
            mMainView = (RelativeLayout) itemView.findViewById(R.id.main_holder);
            mVideoImg = (ImageView) itemView.findViewById(R.id.video_thumb);
            mVideoTitle = (TextView) itemView.findViewById(R.id.video_title);
            mVideoDesc = (TextView) itemView.findViewById(R.id.video_description);
            mVideoTime = (TextView) itemView.findViewById(R.id.video_time_ago);
            mVideoTimer = (TextView) itemView.findViewById(R.id.timer_video);
            mIsFeatured = (TextView) itemView.findViewById(R.id.is_featured_fan_page);
            mSeparator = itemView.findViewById(R.id.is_featured_separator);
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