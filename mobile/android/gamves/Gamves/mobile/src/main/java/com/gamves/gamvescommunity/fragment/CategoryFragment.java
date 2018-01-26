package com.gamves.gamvescommunity.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.adapters.RecyclerCategoryAdapter;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.wang.avi.AVLoadingIndicatorView;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link CategoryFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class CategoryFragment extends BaseFragment {

    private HomeFragment homeFragment;

    private CategoryItem categoryItem;

    private ImageView category_arrow_back;
    private ImageView category_like;
    private ImageView category_cover;
    private TextView category_name;
    private TextView fanpages_amount;
    private AVLoadingIndicatorView category_progress_balls;

    private int cover_height;

    private int fragmentWidth, fragmentHeight;

    private RecyclerCategoryAdapter mAdapter;

    //private List<FanPageListItem> fanpageList;

    private RecyclerView categoryRecyclerView;

    private LinearLayout category_data_row;

    public CategoryFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment
     * @return A new instance of fragment FirstFragment.
     */
    public static final CategoryFragment newInstance()
    {
        CategoryFragment fragment = new CategoryFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        homeFragment = ((HomeFragment)this.getParentFragment());

        DisplayMetrics displaymetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        fragmentHeight = displaymetrics.heightPixels;
        fragmentWidth = displaymetrics.widthPixels;

        cover_height = fragmentWidth * 6 / 16;

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {

        View view = inflater.inflate(R.layout.fragment_category_list, container, false);

        category_arrow_back = (ImageView) view.findViewById(R.id.category_arrow_back);

        category_arrow_back.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v)
            {

                ViewPager pager = homeFragment.getViewPager();

                pager.setCurrentItem(0);
            }
        });

        category_like = (ImageView) view.findViewById(R.id.category_like);

        category_like.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {

            }
        });

        category_cover = (ImageView) view.findViewById(R.id.category_cover);

        category_name = (TextView) view.findViewById(R.id.category_name);

        fanpages_amount = (TextView) view.findViewById(R.id.fanpages_amount);

        categoryRecyclerView = (RecyclerView) view.findViewById(R.id.category_detail_list);

        //category_data_row.getLayoutParams().height = cover_height;
        //category_data_row.getLayoutParams().width = fragmentWidth;

        category_progress_balls = (AVLoadingIndicatorView) view.findViewById(R.id.category_progress_balls);

        return view;
    }



    @Override
    public void updateData()
    {

        CategoryItem catItem = HomeDataSingleton.getInstance().getActiveCategory();

        CategoryItem categoryItem = HomeDataSingleton.getInstance().getActiveCategory();

        category_cover.setImageBitmap(categoryItem.getBackgroundBitmap());

        category_name.setText(categoryItem.getName());

        int amount = categoryItem.getFanpages().size();

        String famount = Integer.toString(amount);

        fanpages_amount.setText(famount);

        assert categoryRecyclerView != null;
        categoryRecyclerView.setHasFixedSize(true);

        mAdapter = new RecyclerCategoryAdapter(getContext(), catItem);

        categoryRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        categoryRecyclerView.setAdapter(mAdapter);

        mAdapter.setOnItemClickListener(onItemFanPageClickListener);

        category_progress_balls.setVisibility(View.GONE);

    }

    @Override
    public void finishedLoad() {

    }

    RecyclerCategoryAdapter.OnItemClickListener onItemFanPageClickListener = new RecyclerCategoryAdapter.OnItemClickListener() {

        @Override
        public void onItemClick(View v, int position)
        {
            CategoryItem category = HomeDataSingleton.getInstance().getActiveCategory();

            category.setActive(true);

            FanPageListItem fanpg = category.getFanpages().get(position);

            fanpg.setActive(true);

            ViewPager pager = homeFragment.getViewPager();

            pager.setCurrentItem(2);
            //Intent fan = new Intent(CategoryActivity.this, FanPageActivity.class);
            //fan.putExtra("id", fanList.get(position).getId());
            //startActivity(fan);
        }
    };

}
