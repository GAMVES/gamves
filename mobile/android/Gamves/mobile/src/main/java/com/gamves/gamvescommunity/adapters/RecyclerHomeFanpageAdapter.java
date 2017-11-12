package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.BitmapImageViewTarget;
import com.bumptech.glide.request.target.SimpleTarget;
import com.gamves.gamvescommunity.fragment.HomeFragment;

import java.util.List;

import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.gamves.gamvescommunity.utils.CustomFontTextView;

/**
 * Created by mariano on 4/18/16.
 **/
public class RecyclerHomeFanpageAdapter extends RecyclerView.Adapter<RecyclerHomeFanpageAdapter.ViewHolder> {

    private Context context;
    //private List<FanpageItem> fragmentList;
    private int position;

    private OnItemClickListener mItemClickListener;

    private int mainPosition;

    private HomeFragment homeFragment;

    public RecyclerHomeFanpageAdapter(Context context, int position, HomeFragment homeFragment) {
        this.position = position;
        this.context = context;
        this.homeFragment = homeFragment;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_fanpage_horizontal, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerHomeFanpageAdapter.ViewHolder holder, int position) {

        final FanPageListItem fragmentItem = HomeDataSingleton.getInstance().getCategoryList().get(this.position).getFanpages().get(position);

        try
        {

            Glide.with(context).load(fragmentItem.getPageIconUrl()).asBitmap().transform(new com.gamves.gamvescommunity.utils.RoundedCornersTransformation(context, 5, 0)).into(new BitmapImageViewTarget(holder.mVideoThumb){

                @Override
                public void onResourceReady(Bitmap bitmap, GlideAnimation anim)
                {

                    fragmentItem.setPageIcon(bitmap);

                    super.onResourceReady(bitmap, anim);
                }

            });

            Glide.with(context).load(fragmentItem.getPageCoverUrl()).asBitmap().into(new SimpleTarget<Bitmap>() {

                @Override
                public void onResourceReady(Bitmap bitmap, GlideAnimation anim)
                {
                    fragmentItem.setPageCover(bitmap);
                }

            });



        } catch (Exception e) {
            e.printStackTrace();
        }


        holder.mFanpageText.setText(fragmentItem.getPageName());

    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public int getItemCount() {
        List<FanPageListItem> fantList = HomeDataSingleton.getInstance().getCategoryList().get(this.position).getFanpages();
        return fantList != null ? fantList.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener{

        public CustomFontTextView mFanpageText;
        public ImageView mVideoThumb;
        public LinearLayout mMainView;

        public ViewHolder(View itemView) {
            super(itemView);

            mMainView = (LinearLayout) itemView.findViewById(R.id.main_holder_fanpage_horizontal);

            mMainView.setOnClickListener(new View.OnClickListener() {

                @Override
                public void onClick(View v)
                {
                    Log.v("","");

                }
            });

            mVideoThumb = (ImageView) itemView.findViewById(R.id.item_fanpage_horizontal_thumbnail);

            mFanpageText = (CustomFontTextView) itemView.findViewById(R.id.item_fanpage_horizontal_text);

            mMainView.setOnClickListener(this);
        }

        @Override
        public void onClick(View v)
        {

            if (mItemClickListener != null)
            {
                int position = getAdapterPosition();

                FanPageListItem fanpage = HomeDataSingleton.getInstance().getCategoryList().get(mainPosition).getFanpages().get(position);

                fanpage.setActive(true);

                mItemClickListener.onItemClick(itemView, position, mainPosition);
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
}
