package gamves.com.gamvesparents;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.IdRes;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatSpinner;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseUser;

import java.util.ArrayList;
import java.util.List;

import gamves.com.gamvesparents.model.School;
import gamves.com.gamvesparents.singleton.DataSingleton;
import gamves.com.gamvesparents.utils.KeySaver;
import info.hoang8f.android.segmented.SegmentedGroup;

import gamves.com.gamvesparents.R;

public class LoginActivity extends AppCompatActivity implements  RadioGroup.OnCheckedChangeListener,
        View.OnClickListener, AdapterView.OnItemSelectedListener {

    private static final String TAG = "LoginActivity";

    ProgressDialog progressDialog;
    private EditText loginInputUserName, loginInputPassword;
    private Button btnlogin;
    private TextView register_message;

    SegmentedGroup segmented_login;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_login);

        LinearLayout cloginContainerView = (LinearLayout) findViewById(R.id.login_container);

        setupUI(cloginContainerView);


        loginInputUserName = (EditText) findViewById(R.id.login_input_username);
        loginInputPassword = (EditText) findViewById(R.id.login_input_password);
        register_message = (TextView) findViewById(R.id.register_message);
        btnlogin = (Button) findViewById(R.id.btn_login);
        btnlogin.setTag(new Integer(0));

        loginInputUserName.setText("Clemente");
        loginInputPassword.setText("clemen");

        // Progress dialog
        progressDialog = new ProgressDialog(this);
        progressDialog.setCancelable(false);

        btnlogin.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view) {

                int tag = (int) btnlogin.getTag();

                if (tag==0)
                {

                    loginUser(loginInputUserName.getText().toString(),
                            loginInputPassword.getText().toString());

                } else if (tag==1)
                {

                    loginInputUserName.setVisibility(View.VISIBLE);
                    loginInputPassword.setVisibility(View.VISIBLE);

                    String login_text = getResources().getString(R.string.btn_login);

                    btnlogin.setText(login_text);
                    btnlogin.setTag(new Integer(0));

                    String register_message_text = getResources().getString(R.string.register_message);

                    register_message.setText(register_message_text);
                    register_message.setVisibility(View.GONE);
                }

            }
        });

        segmented_login = (SegmentedGroup) findViewById(R.id.segmented_login);

        int background = ContextCompat.getColor(this, R.color.gamvesColor);
        int selected = ContextCompat.getColor(this, R.color.white);

        segmented_login.setTintColor(background, selected);

        RadioButton btn_login = (RadioButton) findViewById(R.id.btn_login_segmented);
        btn_login.setChecked(true);

        RadioButton btn_register = (RadioButton) findViewById(R.id.btn_register_segmented);

        btn_login.setOnClickListener(this);
        btn_register.setOnClickListener(this);

        segmented_login.setOnCheckedChangeListener(this);

        // Spinner element
        AppCompatSpinner spinner = (AppCompatSpinner) findViewById(R.id.login_spinner);

        // Spinner click listener
        spinner.setOnItemSelectedListener(this);

        // Spinner Drop down elements
        List<School> schoolsArray = DataSingleton.getInstance().getSchools();

        List<String> schools = new ArrayList<String>();

        for (int i=0; i<schoolsArray.size(); i++) {
            String name = schoolsArray.get(i).getSchoolName();

            schools.add(name);
        }

        // Creating adapter for spinner
        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, schools);

        // Drop down layout style - list view with radio button
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        // attaching data adapter to spinner
        spinner.setAdapter(dataAdapter);


    }

    private void loginUser(final String username, final String password)
    {
        String cancel_req_tag = "login";
        progressDialog.setMessage("Logging you in...");
        showDialog();

        ParseUser.logInInBackground(username, password, new LogInCallback() {

            @Override
            public void done(ParseUser parseUser, ParseException e)
            {
                hideDialog();

                if (parseUser==null)
                {
                    loginInputUserName.setVisibility(View.GONE);
                    loginInputPassword.setVisibility(View.GONE);
                    btnlogin.setText("Try again");
                    btnlogin.setTag(new Integer(1));
                    register_message.setText("Error loggin in: " + e.getMessage());
                    register_message.setVisibility(View.VISIBLE);


                } else
                {

                    KeySaver.saveShare(LoginActivity.this, "username", username);
                    KeySaver.saveShare(LoginActivity.this, "password", password);
                    finish();
                }
            }
        });
    }

    private void showDialog()
    {
        if (!progressDialog.isShowing())
            progressDialog.show();
    }

    private void hideDialog()
    {
        if (progressDialog.isShowing())
            progressDialog.dismiss();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId())
        {
            case R.id.btn_login_segmented:

                break;
            case R.id.btn_register_segmented:

                break;
            default:

        }
    }

    @Override
    public void onCheckedChanged(RadioGroup group, @IdRes int checkedId)
    {
        switch (checkedId) {
            case R.id.btn_login_segmented:

                //loginInputUserName.setVisibility(View.VISIBLE);
                //loginInputPassword.setVisibility(View.VISIBLE);
                //btnlogin.setVisibility(View.VISIBLE);
                //register_message.setVisibility(View.GONE);

                break;
            case R.id.btn_register_segmented:

                //loginInputUserName.setVisibility(View.GONE);
                //loginInputPassword.setVisibility(View.GONE);
                //btnlogin.setVisibility(View.GONE);
                //register_message.setVisibility(View.VISIBLE);

                break;
            default:

        }

    }

    public void setupUI(View view) {

        // Set up touch listener for non-text box views to hide keyboard.
        if (!(view instanceof EditText)) {
            view.setOnTouchListener(new View.OnTouchListener() {
                public boolean onTouch(View v, MotionEvent event) {
                    hideSoftKeyboard(LoginActivity.this);
                    return false;
                }
            });
        }

        //If a layout container, iterate over children and seed recursion.
        if (view instanceof ViewGroup) {
            for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
                View innerView = ((ViewGroup) view).getChildAt(i);
                setupUI(innerView);
            }
        }
    }

    public static void hideSoftKeyboard(Activity activity) {
        InputMethodManager inputMethodManager =
                (InputMethodManager) activity.getSystemService(
                        Activity.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(
                activity.getCurrentFocus().getWindowToken(), 0);
    }


    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        // On selecting a spinner item
        String item = parent.getItemAtPosition(position).toString();

        // Showing selected spinner item
        Toast.makeText(parent.getContext(), "Selected: " + item, Toast.LENGTH_LONG).show();
    }
    public void onNothingSelected(AdapterView<?> arg0) {
        // TODO Auto-generated method stub
    }
}


