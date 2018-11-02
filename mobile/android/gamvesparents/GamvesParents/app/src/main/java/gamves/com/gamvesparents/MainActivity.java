package gamves.com.gamvesparents;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.widget.TextView;

import gamves.com.gamvesparents.fragment.FragmentFeed;
import gamves.com.gamvesparents.fragment.FragmentHome;
import gamves.com.gamvesparents.fragment.FragmentProfile;

//import gamves.com.

public class MainActivity extends AppCompatActivity {

    private TextView mTextMessage;
    private FragmentManager fragmentManager;
    private Fragment fragment;

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {

            switch (item.getItemId()) {
                case R.id.navigation_home:
                    fragment = new FragmentHome();
                    //mToolbar.setTitle("HOME");
                    getSupportActionBar().setTitle("Inicio");
                    break;
                case R.id.navigation_feed:
                    fragment = new FragmentFeed();
                    //mToolbar.setTitle("CAMARAS");
                    getSupportActionBar().setTitle("Messages");
                    break;
                case R.id.navigation_profile:
                    fragment = new FragmentProfile();
                    //mToolbar.setTitle("REFLECTORES");
                    getSupportActionBar().setTitle("Reflectores");
                    break;
            }
            final FragmentTransaction transaction = fragmentManager.beginTransaction();
            transaction.replace(R.id.fragment_content, fragment).commit();

            return false;

        }

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        fragmentManager = getSupportFragmentManager();

        setContentView(R.layout.activity_main);

        mTextMessage = (TextView) findViewById(R.id.message);
        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
    }


}