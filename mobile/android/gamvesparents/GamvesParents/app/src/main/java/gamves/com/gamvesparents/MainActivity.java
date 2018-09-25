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

import gamves.com.gamvesparents.fragment.FragmentCommunity;
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
                case R.id.navigation_community:
                    fragment = new FragmentCommunity();
                    //mToolbar.setTitle("CAMARAS");
                    getSupportActionBar().setTitle("Camaras");
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

            /*  switch (item.getItemId()) {
                case R.id.navigation_home:
                    mTextMessage.setText(R.string.title_home);
                    return true;
                case R.id.navigation_activity:
                    mTextMessage.setText(R.string.title_activity);
                    return true;
                case R.id.navigation_account:
                    mTextMessage.setText(R.string.title_account);
                    return true;
            }
            return false;
        }*/
        }

    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        mTextMessage = (TextView) findViewById(R.id.message);
        BottomNavigationView navigation = (BottomNavigationView) findViewById(R.id.navigation);
        navigation.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);
    }


}