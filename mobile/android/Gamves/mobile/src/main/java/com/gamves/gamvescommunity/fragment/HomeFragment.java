package com.gamves.gamvescommunity.fragment;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.gamves.gamvescommunity.GamvesApplication;
import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.callbacks.ParseCallback;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.gamves.gamvescommunity.utils.HomeViewPager;
import com.gamves.gamvescommunity.utils.KeySaver;
import com.gamves.gamvescommunity.utils.Utils;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link HomeFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class HomeFragment extends Fragment {

    HomeViewPager viewPager;
    ViewPagerAdapter viewPagerAdapter;

    private boolean swipeEnabled;

    private static final int NUM_ITEMS = 4;

    private int PAGE_SELETED_ACTION = 0;
    private static final int LOAD_FRAGMENT_DATA = 1;
    private static final int HIDE_SPINNER       = 2;

    private int iRow;
    //private CategoryItem categoryItem;

    private Context context;
    int countCat = 0;

    private String TAG = "HomeFragment";

    private HomeCategoryFragment catFragment;

    public HomeFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment
     * @return A new instance of fragment ViewPagerFragment.
     */
    public static HomeFragment newInstance() {
        HomeFragment fragment = new HomeFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setCategoryFanPageData();
    }


    private HomeCategoryFragment homeCategoryFragment;
    private VideoFragment videoFragment;

    private ViewPager.OnPageChangeListener onPageChangeListener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        viewPager = (HomeViewPager) view.findViewById(R.id.viewpager);

        viewPagerAdapter = new ViewPagerAdapter(getChildFragmentManager());
        viewPager.setOffscreenPageLimit(NUM_ITEMS);
        viewPager.setAdapter(viewPagerAdapter);

        onPageChangeListener = new ViewPager.OnPageChangeListener()
        {

            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels)
            {

            }

            @Override
            public void onPageSelected(int position)
            {
                Fragment frag = (Fragment) viewPagerAdapter.instantiateItem(viewPager, position);

                if (frag != null)
                {
                    if (frag instanceof HomeCategoryFragment)
                    {
                        if (PAGE_SELETED_ACTION==LOAD_FRAGMENT_DATA)
                        {
                            ((HomeCategoryFragment) frag).updateData();

                        } else if (PAGE_SELETED_ACTION==HIDE_SPINNER)
                        {
                            ((HomeCategoryFragment) frag).finishedLoad();
                        }

                    } else if (frag instanceof CategoryFragment)
                    {

                        ((CategoryFragment) frag).updateData();


                    } else if (frag instanceof FanpageFragment)
                    {

                        ((FanpageFragment) frag).updateData();


                    } else if (frag instanceof VideoFragment)
                    {

                        ((VideoFragment) frag).updateData();

                    }
                }
            }

            @Override
            public void onPageScrollStateChanged(int state)
            {

            }

        };

        viewPager.addOnPageChangeListener(onPageChangeListener);

        return view;
    }


    public class ViewPagerAdapter extends FragmentStatePagerAdapter {


        public ViewPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public int getCount()
        {
            return NUM_ITEMS;
        }

        @Override
        public Fragment getItem(int position)
        {

            if(position == 0)
            {
                return HomeCategoryFragment.newInstance();

            } else if(position==1)
            {

                return CategoryFragment.newInstance();

            } else if (position==2)
            {

                return FanpageFragment.newInstance();

            } else
            {
                return VideoFragment.newInstance();

            }
        }

        @Override
        public CharSequence getPageTitle(int position) {

            return null;
        }
    }

    public HomeViewPager getViewPager()
    {
        return viewPager;
    }

    private void setCategoryFanPageData() {

        final ParseQuery<ParseObject> queryCategorie = ParseQuery.getQuery("Categories");

        queryCategorie.orderByAscending("order");

        //queryCategorie.orderByAscending("likes");
        //if (KeySaver.isExist(getActivity(), "language") && !Utils.getSavedLanguage(KeySaver.getIntSavedShare(getActivity(), "language")).contentEquals("none"))
        //{
        //    queryCategorie.whereEqualTo("language", Utils.getSavedLanguage(KeySaver.getIntSavedShare(getActivity(), "language")));
        //}

        queryCategorie.findInBackground(new FindCallback<ParseObject>() {

            @Override
            public void done(List<ParseObject> objectsRow, ParseException e) {

                if (objectsRow != null) { // && iRow < objectsRow.size()) {

                    for (int i=0; i<objectsRow.size(); i++) {

                        try {

                            final int categoryCount = objectsRow.size();

                            final CategoryItem categoryItem = new CategoryItem(context);
                            categoryItem.setId(objectsRow.get(i).getString("objectId"));
                            categoryItem.setName(objectsRow.get(i).getString("name"));
                            categoryItem.setDescription(objectsRow.get(i).getString("description"));

                            ParseFile thumbnail = (ParseFile) objectsRow.get(i).getParseFile("thumbnail");
                            categoryItem.setThumbnailUrl(thumbnail.getUrl());

                            ParseFile backImage = (ParseFile) objectsRow.get(i).getParseFile("backImage");
                            categoryItem.setBackgroundUrl(backImage.getUrl());

                            categoryItem.setGradientId(GamvesApplication.getInstance().generateRandonGradient());

                            final List<FanPageListItem> arrayFanpages = new ArrayList<>();
                            ParseQuery<ParseObject> queryFanpage = ParseQuery.getQuery("Fanpages");
                            queryFanpage.whereEqualTo("category", objectsRow.get(i));

                            //queryFanpage.orderByDescending("date");

                            queryFanpage.findInBackground(new FindCallback<ParseObject>() {

                                @Override
                                public void done(List<ParseObject> objects, ParseException e) {

                                    int size = objects.size();

                                    for (int j = 0; j < size; j++) {

                                        FanPageListItem fanpage = new FanPageListItem();
                                        fanpage.setId(objects.get(j).getString("onjectId"));

                                        fanpage.setPageName(objects.get(j).getString("pageName"));
                                        fanpage.setPageAbout(objects.get(j).getString("pageAbout"));

                                        String icon_url = objects.get(j).getString("pageIcon");
                                        fanpage.setPageIconUrl(icon_url);

                                        String cover_url = objects.get(j).getString("pageCover");
                                        fanpage.setPageCoverUrl(cover_url);

                                        fanpage.setPageLink(objects.get(j).getString("pageLink"));
                                        fanpage.setPageLikes(objects.get(j).getString("pageLikes"));

                                        fanpage.setFanpageObject(objects.get(j));

                                        arrayFanpages.add(fanpage);

                                        if (j == objects.size() - 1) {
                                            categoryItem.setFanpages(arrayFanpages);
                                            listener.onTaskCompletedCategory(categoryItem);
                                            countCat++;
                                        }
                                    }
                                }
                            });

                        } catch (Exception e1) {

                            e1.printStackTrace();
                        }
                    }

                } else if (objectsRow != null && iRow == objectsRow.size()) {

                    PAGE_SELETED_ACTION = HIDE_SPINNER;
                    onPageChangeListener.onPageSelected(0);

                }
            }
        });

    }

    private ParseCallback listener = new ParseCallback() {

        @Override
        public void onTaskCompleted()
        {

        }

        @Override
        public void onTaskCompletedCategory(CategoryItem item) {

            //iRow++;
            String name = item.getName();
            Log.v("", name);
            LoadCategoryImages loadImages = new LoadCategoryImages();
            loadImages.execute(item);
        }

    };

    public class LoadCategoryImages extends AsyncTask<CategoryItem, Void, CategoryItem> {

        @Override
        protected CategoryItem doInBackground(CategoryItem... params) {

            CategoryItem categoryItem = (CategoryItem) params[0];

            categoryItem.setThumbnail(downloadImage(categoryItem.getThumbnailUrl()));

            categoryItem.setBackground(downloadImage(categoryItem.getBackgroundUrl()));

            return categoryItem;
        }

        private Bitmap downloadImage(String urlPAth)
        {
            try
            {

                URL url = new URL(urlPAth);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.connect();
                InputStream input = connection.getInputStream();
                Bitmap myBitmap = BitmapFactory.decodeStream(input);

                return myBitmap;

            } catch (Exception e)
            {
                Log.d(TAG,e.getMessage());
            }

            return null;
        }

        @Override
        protected void onPostExecute(CategoryItem result)
        {
            HomeDataSingleton.getInstance().addCategoryItem(result);
            PAGE_SELETED_ACTION=LOAD_FRAGMENT_DATA;
            onPageChangeListener.onPageSelected(0);
            //setCategoryFanPageData();
        }

        @Override
        protected void onPreExecute()
        {

        }

        @Override
        protected void onProgressUpdate(Void... values)
        {

        }
    }

}
