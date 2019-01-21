package gamves.com.gamvesparents.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.parse.ParseUser;

import java.util.List;

import gamves.com.gamvesparents.activities.LoginActivity;
import gamves.com.gamvesparents.activities.MainActivity;
import gamves.com.gamvesparents.model.School;
import gamves.com.gamvesparents.singleton.DataSingleton;

public class SplashActivity extends AppCompatActivity {

    private Activity actvity;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.actvity = this;

        if (ParseUser.getCurrentUser() != null) {
            Intent mi = new Intent(this, MainActivity.class);
            startActivity(mi);
        } else {

            DataSingleton.getInstance().querySchools();
            DataSingleton.getInstance().setOnDataCallback(new DataSingleton.OnDataCallback() {
                @Override
                public void getSchools(List<School> schools) {

                    //Intent i = new Intent(actvity, LoginActivity.class);
                    Intent i = new Intent(actvity, ImagePickerActivity.class);
                    startActivity(i);

                }
            });
        }
    }

    @Override public void onBackPressed() {
        // Must be empty, so we can't press back from the splash screen
    }

}
