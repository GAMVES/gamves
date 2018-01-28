package com.gamves.gamvescommunity.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.adapters.RecyclerHomeCategoryPageAdapter;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.singleton.DataSingleton;
import com.gamves.gamvescommunity.utils.RippleBackground;
import com.gamves.gamvescommunity.utils.Utils;
import com.wang.avi.AVLoadingIndicatorView;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link HomeCategoryFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class HomeCategoryFragment extends BaseFragment
{

    private RecyclerHomeCategoryPageAdapter mAdapter;

    private RippleBackground rippleBackground;

    private HomeFragment homeFragment;

    private Context context;

    private AVLoadingIndicatorView mProgress;

    private RecyclerView mRecyclerView;

    public HomeCategoryFragment() {
        // Required empty public constructor
    }

    private String TAG = "HomeCategoryFragment";

    /**
     * Use this factory method to create a new instance of
     * this fragment
     * @return A new instance of fragment FirstFragment.
     */
    public static Fragment newInstance() {
        HomeCategoryFragment fragment = new HomeCategoryFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        context = getActivity();

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        final View view = inflater.inflate(R.layout.fragment_home_category, container, false);

        mProgress = (AVLoadingIndicatorView) view.findViewById(R.id.progress_balls);
        Utils.showProgress(mProgress);

        rippleBackground = (RippleBackground) view.findViewById(R.id.content);

        mRecyclerView = (RecyclerView) view.findViewById(R.id.category_list);

        assert mRecyclerView != null;

        return view;
    }

    RecyclerHomeCategoryPageAdapter.OnItemClickListener onItemFanPageClickListener = new RecyclerHomeCategoryPageAdapter.OnItemClickListener() {

        @Override
        public void onItemClick(View v, int position)
        {
            CategoryItem category = DataSingleton.getInstance().getCategoryList().get(position);

            category.setActive(true);

            ViewPager pager = homeFragment.getViewPager();

            pager.setCurrentItem(1);
        }
    };



    @Override
    public void updateData()
    {

        homeFragment = (HomeFragment) this.getParentFragment();

        mRecyclerView.setHasFixedSize(true);

        mAdapter = new RecyclerHomeCategoryPageAdapter(getActivity(), homeFragment);

        mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false));
        mRecyclerView.setAdapter(mAdapter);

        mAdapter.setOnItemClickListener(onItemFanPageClickListener);

    }

    @Override
    public void finishedLoad()
    {
        mProgress.setVisibility(View.GONE);
        mAdapter.notifyDataSetChanged();
        rippleBackground.startRippleAnimation();
    }

}
