package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.gamves.gamvescommunity.R;

import com.gamves.gamvescommunity.model.VideosPlayListItem;

import java.util.List;

/**
 * Created by Jose on 2/23/16.
 **/

public class RecyclerPlaylistAdapter extends RecyclerView.Adapter<RecyclerPlaylistAdapter.ViewHolder> {

    Context context;
    private List<VideosPlayListItem> videoArray;

    OnItemClickListener mItemClickListener;

    public RecyclerPlaylistAdapter(Context context, List<VideosPlayListItem> videoArray) {
        this.context    = context;
        this.videoArray = videoArray;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_playlist, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {

        holder.mVideoTitle.setText(videoArray.get(position).getTitle());

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

        public TextView mVideoTitle;
        public LinearLayout mMainView;

        public ViewHolder(View itemView) {
            super(itemView);
            mMainView = (LinearLayout) itemView.findViewById(R.id.main_holder);
            mVideoTitle = (TextView) itemView.findViewById(R.id.playlist_item_title);
            mMainView.setOnClickListener(this);
            mVideoTitle.setMaxLines(1);
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
}