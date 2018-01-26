package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.google.gson.Gson;
import com.mikhaellopez.circularimageview.CircularImageView;
import com.gamves.gamvescommunity.R;

import java.util.List;

/**
 * Created by mariano on 4/18/16.
 **/
public class RecyclerCategoryAdapter extends RecyclerView.Adapter<RecyclerCategoryAdapter.ViewHolder> {

    private Context context;
    private CategoryItem categoryItem;
    private List<FanPageListItem> fanpageItemList;
    private OnItemClickListener mItemClickListener;

    public RecyclerCategoryAdapter(Context context, CategoryItem categoryItem) {
        this.categoryItem = categoryItem;
        this.fanpageItemList = categoryItem.getFanpages();
        this.context = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_fanpage_list_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerCategoryAdapter.ViewHolder holder, int position) {

        FanPageListItem fanpageItem = this.fanpageItemList.get(position);
        holder.fanpageCover.setImageBitmap(fanpageItem.getPageCover());
        holder.fanpageThumbnail.setImageBitmap(fanpageItem.getPageIcon());
        holder.fanpageTitle.setText(fanpageItem.getPageName());
        holder.fanpageDescription.setText(fanpageItem.pageAbout);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public int getItemCount()
    {
        return fanpageItemList.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private LinearLayout mMainView;
        public ImageView fanpageCover;
        public CircularImageView fanpageThumbnail;
        public TextView fanpageTitle;
        public TextView fanpageDescription;

        public ViewHolder(View itemView) {
            super(itemView);

            mMainView = (LinearLayout) itemView.findViewById(R.id.main_holder_fanpage_list_item);
            fanpageCover = (ImageView) itemView.findViewById(R.id.fanpage_cover_list_item);
            fanpageThumbnail = (CircularImageView) itemView.findViewById(R.id.fanpage_thumbnail_list_item);
            fanpageThumbnail.setBorderWidth(0);
            fanpageTitle = (TextView) itemView.findViewById(R.id.fanpage_title_list_item);
            fanpageDescription = (TextView) itemView.findViewById(R.id.fanpage_description_list_item);

            mMainView.setOnClickListener(this);
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

    RecyclerVideosAdapter.OnItemClickListener onItemVideoClickListener = new RecyclerVideosAdapter.OnItemClickListener() {

        @Override
        public void onItemClick(View v, int position, int mainPosition) {

            Gson gson = new Gson();

            /*Intent i = new Intent(context, VideoDetail.class);
            i.putExtra("id", categoryItem.get(mainPosition).getVideos().get(position).getId());
            i.putExtra("channel", categoryItem.get(mainPosition).getId());
            i.putExtra("video_list", gson.toJson(itemList.get(mainPosition).getVideos()));
            i.putExtra("position", position);
            i.putExtra("toHide", true);
            i.putExtra("isParse", true);
            context.startActivity(i);*/
        }
    };


}
