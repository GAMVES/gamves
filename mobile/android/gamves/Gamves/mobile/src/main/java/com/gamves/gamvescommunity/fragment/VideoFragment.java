package com.gamves.gamvescommunity.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.singleton.DataSingleton;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link VideoFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class VideoFragment extends BaseFragment {

    private HomeFragment homeFragment;

    private CategoryItem categoryItem;

    public VideoFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment
     * @return A new instance of fragment FirstFragment.
     */
    public static final VideoFragment newInstance() {
        VideoFragment fragment = new VideoFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        homeFragment = ((HomeFragment)this.getParentFragment());

        if (DataSingleton.getInstance().hasCategories())
            categoryItem = DataSingleton.getInstance().getActiveCategory();

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_video, container, false);
    }

    @Override
    public void updateData()
    {
        Log.v("","");
    }

    @Override
    public void finishedLoad() {

    }
}
