package gamves.com.gamvesparents.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.List;

import gamves.com.gamvesparents.model.FeedItem;

import gamves.com.gamvesparents.R;

/**
 * Created by Jose on 4/18/16.
 **/
public class RecyclerFeedAdapter extends RecyclerView.Adapter<RecyclerFeedAdapter.ViewHolder> {

    private Context context;
    private List<FeedItem> feedList;

    private OnFeedClickListener mFeedClickListener;

    private int mainPosition;

    public RecyclerFeedAdapter(Context context, List<FeedItem> feedList) {
        this.feedList = feedList;
        this.context = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.fragment_video_list, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerFeedAdapter.ViewHolder holder, int position) {

        FeedItem feedItem = feedList.get(position);

        holder.mVideoThumb = feedItem.getChatThumbnail();

        holder.mTextDescription.setText(feedItem.getText());
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public int getItemCount() {
        return feedList != null ? feedList.size() : 0;
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
            if (mFeedClickListener != null) {
                mFeedClickListener.onFeedClick(itemView, getAdapterPosition(), mainPosition);
            }
        }
    }

    public interface OnFeedClickListener {
        void onFeedClick(View view, int position, int mainPosition);
    }

    public void setOnFeedClickListener(final OnFeedClickListener mFeedClickListener, int mainPosition) {
        this.mFeedClickListener = mFeedClickListener;
        this.mainPosition = mainPosition;
    }

    public void setOnFeedClickListener(final OnFeedClickListener mItemClickListener) {
        this.mFeedClickListener = mItemClickListener;
    }
}
