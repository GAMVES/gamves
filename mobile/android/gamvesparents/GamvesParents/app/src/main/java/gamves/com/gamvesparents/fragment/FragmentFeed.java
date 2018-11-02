package gamves.com.gamvesparents.fragment;

import android.app.ProgressDialog;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TimePicker;

import com.getbase.floatingactionbutton.FloatingActionButton;
import com.getbase.floatingactionbutton.FloatingActionsMenu;

import com.wang.avi.AVLoadingIndicatorView;

import java.util.List;

import gamves.com.gamvesparents.R;
import gamves.com.gamvesparents.adapter.RecyclerFeedAdapter;
import gamves.com.gamvesparents.model.FeedItem;
import gamves.com.gamvesparents.singleton.DataSingleton;
import gamves.com.gamvesparents.utils.Utils;

/**
 * Created by jose on 9/15/17.
 */

public class FragmentFeed extends Fragment {

    private Button btn_link_signup, btn_login;

    private ProgressDialog progressDialog;
    private AlertDialog alertDialog;

    private String Selected_From_Time;

    private Button date_time_set;

    private RecyclerView mRecyclerView;

    private RecyclerFeedAdapter fAdapter;

    private AVLoadingIndicatorView mProgress;

    private List<FeedItem> feedItems;

    public FragmentFeed() {
        // Required empty public constructor
    }

    public static final FragmentFeed newInstance() {
        FragmentFeed fragment = new FragmentFeed();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        progressDialog = new ProgressDialog(getActivity());
        progressDialog.setMessage("Please wait.");
        progressDialog.show();

        final View dialogView = View.inflate(getActivity(), R.layout.time_picker_dialod, null);

        alertDialog = new AlertDialog.Builder(getActivity()).create();
        alertDialog.setView(dialogView);

        final TimePicker timePicker = (TimePicker) dialogView.findViewById(R.id.time_picker);

        if (Build.VERSION.SDK_INT >= 23) {
            timePicker.setHour(00);
            timePicker.setMinute(00);
        } else {
            timePicker.setCurrentHour(00);
            timePicker.setCurrentMinute(00);
        }

        dialogView.findViewById(R.id.date_time_set).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {

                if (Build.VERSION.SDK_INT >= 23) {

                    Selected_From_Time = timePicker.getHour() + ":" + timePicker.getMinute() + ":" + "00";
                } else {
                    Selected_From_Time = timePicker.getCurrentHour() + ":" + timePicker.getCurrentMinute() + ":" + "00";
                }

                alertDialog.dismiss();
            }
        });

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_feed, container, false);

        date_time_set = (Button) view.findViewById(R.id.date_time_set);

        mRecyclerView = (RecyclerView) view.findViewById(R.id.feed_list);

        assert mRecyclerView != null;
        mRecyclerView.setHasFixedSize(true);

        feedItems = DataSingleton.getInstance().getFeedList();

        fAdapter = new RecyclerFeedAdapter(getContext(), feedItems);

        mRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        mRecyclerView.setAdapter(fAdapter);

        fAdapter.setOnFeedClickListener(onFeedClickListener);

        mProgress = (AVLoadingIndicatorView) view.findViewById(R.id.feed_progress_balls);
        Utils.showProgress(mProgress);

        final FloatingActionsMenu menuMultipleActions = (FloatingActionsMenu) view.findViewById(R.id.add_vigilant_task);

        final FloatingActionButton actionA = (FloatingActionButton) view.findViewById(R.id.action_a);
        actionA.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                actionA.setTitle("Action A clicked");
            }
        });

        final FloatingActionButton actionB = (FloatingActionButton) view.findViewById(R.id.action_b);
        actionB.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                actionB.setTitle("Action B clicked");
            }
        });

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    RecyclerFeedAdapter.OnFeedClickListener onFeedClickListener = new RecyclerFeedAdapter.OnFeedClickListener() {

        @Override
        public void onFeedClick(View view, int position, int mainPosition) {

            FeedItem feedIte = feedItems.get(position);

            //Intent fan = new Intent(CategoryActivity.this, FanPageActivity.class);
            //fan.putExtra("id", fanList.get(position).getId());
            //startActivity(fan);
        }

    };


}
