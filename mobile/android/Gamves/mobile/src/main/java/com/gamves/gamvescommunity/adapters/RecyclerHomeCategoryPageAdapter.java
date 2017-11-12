package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v4.view.ViewPager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.gamves.gamvescommunity.fragment.HomeFragment;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.gamves.gamvescommunity.utils.GamvesLinearLayoutManager;

import java.util.List;

import com.gamves.gamvescommunity.R;

/**
 * Created by mariano on 4/18/16.
 **/
public class RecyclerHomeCategoryPageAdapter extends RecyclerView.Adapter<RecyclerHomeCategoryPageAdapter.ViewHolder> {

    private Context context;

    private List<FanPageListItem> fanpageList;

    private OnItemClickListener mItemClickListener;

    private HomeFragment homeFragment;

    public List<FanPageListItem> getList() {
        return fanpageList;
    }

    public RecyclerHomeCategoryPageAdapter(Context context, HomeFragment homeFragment) {
        this.homeFragment = homeFragment;
        this.context = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_category, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerHomeCategoryPageAdapter.ViewHolder holder, int position)
    {

        int size = HomeDataSingleton.getInstance().getCategoryList().size();
        if (size==0)
            return;


        Bitmap thumbnailBitmap = HomeDataSingleton.getInstance().getCategoryList().get(position).getThumbnailBitmap();

        holder.mThumbImg.setImageBitmap(thumbnailBitmap);

        Bitmap backgroundBitmap = HomeDataSingleton.getInstance().getCategoryList().get(position).getBackgroundBitmap();

        holder.mBackgroundImg.setImageBitmap(backgroundBitmap);

        int gradiendId = HomeDataSingleton.getInstance().getCategoryList().get(position).getGradientId();

        Glide.with(context)
                .load("")
                .placeholder(gradiendId)
                .into(holder.mGradientImg);

        holder.mGradientImg.setImageAlpha(200);

        String name = HomeDataSingleton.getInstance().getCategoryList().get(position).getName();

        holder.mNameText.setText(name);

        RecyclerHomeFanpageAdapter fanpageAdapter = new RecyclerHomeFanpageAdapter(context, position, homeFragment);

        GamvesLinearLayoutManager mLayoutManager = new GamvesLinearLayoutManager(context);
        mLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);

        holder.mRecyclerView.setHasFixedSize(true);
        holder.mRecyclerView.setLayoutManager(mLayoutManager);
        holder.mRecyclerView.setAdapter(fanpageAdapter);

        fanpageAdapter.setOnItemClickListener(onItemFanpageClickListener, position);

        fanpageAdapter.notifyDataSetChanged();
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public int getItemCount() {
        int count = HomeDataSingleton.getInstance().getCategoryList().size();
        return count;
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        public ImageView mThumbImg;
        public ImageView mBackgroundImg;
        public ImageView mGradientImg;

        public LinearLayout mMainView;
        public TextView mNameText;
        public RecyclerView mRecyclerView;

        public ViewHolder(View itemView)
        {
            super(itemView);

            mMainView = (LinearLayout) itemView.findViewById(R.id.main_holder);

            mBackgroundImg = (ImageView) itemView.findViewById(R.id.category_item_fan_page_img_background);
            mThumbImg = (ImageView) itemView.findViewById(R.id.category_item_fan_page_img);

            mGradientImg = (ImageView) itemView.findViewById(R.id.category_item_fan_page_img_gradient);

            mNameText = (TextView) itemView.findViewById(R.id.category_item_fan_page_text);
            mRecyclerView = (RecyclerView) itemView.findViewById(R.id.category_item_fan_page_videos);

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

    RecyclerHomeFanpageAdapter.OnItemClickListener onItemFanpageClickListener = new RecyclerHomeFanpageAdapter.OnItemClickListener() {

        @Override
        public void onItemClick(View v, int position, int mainPosition)
        {

            CategoryItem category = HomeDataSingleton.getInstance().getCategoryList().get(mainPosition);

            category.setActive(true);

            FanPageListItem item = category.getFanpages().get(position);

            item.setActive(true);

            ViewPager pager = homeFragment.getViewPager();

            pager.setCurrentItem( 2 );
        }
    };


}
