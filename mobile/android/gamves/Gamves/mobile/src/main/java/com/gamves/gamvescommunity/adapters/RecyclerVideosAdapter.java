package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.gamves.gamvescommunity.model.VideosListItem;
import com.gamves.gamvescommunity.R;

import java.util.List;

/**
 * Created by mariano on 4/18/16.
 **/
public class RecyclerVideosAdapter extends RecyclerView.Adapter<RecyclerVideosAdapter.ViewHolder> {

    private Context context;
    private List<VideosListItem> itemList;

    private OnItemClickListener mItemClickListener;

    private int mainPosition;

    public RecyclerVideosAdapter(Context context, List<VideosListItem> itemList) {
        this.itemList = itemList;
        this.context = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.fragment_video_list, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerVideosAdapter.ViewHolder holder, int position) {

        VideosListItem videoItem = itemList.get(position);

        holder.mVideoThumb.setImageBitmap(itemList.get(position).getThumbnailBitmap());

        holder.mTextDescription.setText(itemList.get(position).getDescription());
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public int getItemCount() {
        return itemList != null ? itemList.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener{

        public ImageView mVideoThumb;
        public TextView mTextDescription;
        public LinearLayout mMainView;

        public ViewHolder(View itemView) {
            super(itemView);

            mMainView = (LinearLayout) itemView.findViewById(R.id.main_holder_video_list);

            mVideoThumb = (ImageView) itemView.findViewById(R.id.video_item_thumb);

            mTextDescription = (TextView) itemView.findViewById(R.id.video_description);

            mMainView.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (mItemClickListener != null) {
                mItemClickListener.onItemClick(itemView, getAdapterPosition(), mainPosition);
            }
        }
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position, int mainPosition);
    }

    public void setOnItemClickListener(final OnItemClickListener mItemClickListener, int mainPosition) {
        this.mItemClickListener = mItemClickListener;
        this.mainPosition = mainPosition;
    }

    public void setOnItemClickListener(final OnItemClickListener mItemClickListener) {
        this.mItemClickListener = mItemClickListener;
    }
}
