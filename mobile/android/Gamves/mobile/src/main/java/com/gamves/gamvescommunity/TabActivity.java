package com.gamves.gamvescommunity;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.support.design.widget.TabLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.gamves.gamvescommunity.callbacks.ParseCallback;
import com.gamves.gamvescommunity.fragment.CommunityFragment;
import com.gamves.gamvescommunity.fragment.HomeFragment;
import com.gamves.gamvescommunity.fragment.ProfileFragment;
import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.singleton.HomeDataSingleton;
import com.gamves.gamvescommunity.utils.KeySaver;
import com.gamves.gamvescommunity.utils.Utils;
import com.parse.FindCallback;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.wang.avi.AVLoadingIndicatorView;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class TabActivity extends AppCompatActivity implements
        CommunityFragment.OnFragmentInteractionListener,
        ProfileFragment.OnFragmentInteractionListener
{

    /**
     * The {@link android.support.v4.view.PagerAdapter} that will provide
     * fragments for each of the sections. We use a
     * {@link FragmentPagerAdapter} derivative, which will keep every
     * loaded fragment in memory. If this becomes too memory intensive, it
     * may be best to switch to a
     * {@link android.support.v4.app.FragmentStatePagerAdapter}.
     */
    private SectionsPagerAdapter mSectionsPagerAdapter;

    /**
     * The {@link ViewPager} that will host the section contents.
     */
    private ViewPager mViewPager;

    public String HOME = "Home";
    public String COMMUNITY = "Community";
    public String PROFILE = "Profile";

    private Context context;

    private String TAG = "TabActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_tab);

        if (!GamvesApplication.isUserLoggedIn())
        {
            Intent i = new Intent(TabActivity.this, LoginActivity.class);
            startActivity(i);
        }

        this.context = this;

        final Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setTitle(HOME);

        // Create the adapter that will return a fragment for each of the three
        // primary sections of the activity.
        mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        // Set up the ViewPager with the sections adapter.
        mViewPager = (ViewPager) findViewById(R.id.container);
        mViewPager.setAdapter(mSectionsPagerAdapter);

        mViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                String tabName = null;
                switch (position) {
                    case 0:
                        tabName = HOME;
                        break;
                    case 1:
                        tabName = COMMUNITY;
                        break;
                    case 2:
                        tabName = PROFILE;
                        break;
                }
                TabActivity.this.getSupportActionBar().setTitle(tabName);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });

        TabLayout tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(mViewPager);

        for (int i = 0; i < 3; i++) {
            int drawable = 0;
            switch (i) {
                case 0:
                    drawable = R.drawable.home;
                    break;
                case 1:
                    drawable = R.drawable.community;
                    break;
                case 2:
                    drawable = R.drawable.profile;
                    break;
            }
            tabLayout.getTabAt(i).setIcon(drawable);

        }

    }



    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_tab, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onFragmentInteraction(Uri uri) {

    }


    /**
     * A {@link FragmentPagerAdapter} that returns a fragment corresponding to
     * one of the sections/tabs/pages.
     */
    public class SectionsPagerAdapter extends FragmentPagerAdapter {

        public SectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        /*@Override
        public Fragment getItem(int position) {
            // getItem is called to instantiate the fragment for the given page.
            // Return a PlaceholderFragment (defined as a static inner class below).
            return PlaceholderFragment.newInstance(position + 1);
        }*/

        @Override
        public Fragment getItem(int position) {

            switch (position)
            {
                case 0:
                    HomeFragment homeFragment = new HomeFragment();
                    return homeFragment;
                case 1:
                    CommunityFragment communityFragment = new CommunityFragment();
                    return communityFragment;
                case 2:
                    ProfileFragment profileFragment = new ProfileFragment();
                    return profileFragment;
                default:
                    return null;
            }
        }

        @Override
        public int getCount() {
            // Show 3 total pages.
            return 3;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            /*switch (position) {
                case 0:
                    return "HOME";
                case 1:
                    return "TRENDING";
                case 2:
                    return "COMMUNITY";
                case 3:
                    return "PROFILE";
            }*/
            return null;
        }
    }
}
