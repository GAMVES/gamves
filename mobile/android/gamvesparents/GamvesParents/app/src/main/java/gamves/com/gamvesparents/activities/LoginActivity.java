package gamves.com.gamvesparents.activities;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.IdRes;
import android.support.design.widget.TextInputLayout;
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
import com.parse.SignUpCallback;

import java.util.ArrayList;
import java.util.List;

import gamves.com.gamvesparents.R;
import gamves.com.gamvesparents.model.School;
import gamves.com.gamvesparents.singleton.DataSingleton;
import gamves.com.gamvesparents.utils.KeySaver;
import info.hoang8f.android.segmented.SegmentedGroup;

public class LoginActivity extends AppCompatActivity implements  RadioGroup.OnCheckedChangeListener,
        View.OnClickListener, AdapterView.OnItemSelectedListener {

    private static final String TAG = "LoginActivity";

    ProgressDialog progressDialog;

    private TextInputLayout
            layoutUsername,
            layoutEmail,
            layoutPassword,
            layoutSpinner;

    private EditText
            loginInputUserName,
            loginInputEmail,
            loginInputPassword;

    private AppCompatSpinner loginSpinner;


    private Button btnloginRegister;
    private TextView registerMessage;

    SegmentedGroup segmented_login;

    private Activity activity;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_login);

        LinearLayout cloginContainerView = (LinearLayout) findViewById(R.id.login_container);

        setupUI(cloginContainerView);

        this.activity = this;

        layoutUsername = (TextInputLayout) findViewById(R.id.login_input_layout_username);
        layoutEmail = (TextInputLayout) findViewById(R.id.login_input_layout_email);
        layoutPassword = (TextInputLayout) findViewById(R.id.login_input_layout_password);
        layoutSpinner = (TextInputLayout) findViewById(R.id.login_input_layout_spinner);

        loginInputUserName = (EditText) findViewById(R.id.login_input_username);
        loginInputPassword = (EditText) findViewById(R.id.login_input_password);
        loginInputEmail = (EditText) findViewById(R.id.login_input_email);
        loginSpinner = (AppCompatSpinner) findViewById(R.id.login_spinner);


        registerMessage = (TextView) findViewById(R.id.register_message);
        btnloginRegister = (Button) findViewById(R.id.btn_login);
        btnloginRegister.setTag(new Integer(0));

        loginInputUserName.setText("Clemente");
        loginInputPassword.setText("clemen");

        // Progress dialog
        progressDialog = new ProgressDialog(this);
        progressDialog.setCancelable(false);

        btnloginRegister.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view) {

                int tag = (int) btnloginRegister.getTag();

                if (tag==0)
                {

                    loginUser();

                } else if (tag==1)
                {

                    registerUser();


                    /*loginInputUserName.setVisibility(View.VISIBLE);
                    loginInputPassword.setVisibility(View.VISIBLE);

                    String login_text = getResources().getString(R.string.btn_login);

                    btnloginRegister.setText(login_text);
                    btnloginRegister.setTag(new Integer(0));

                    String register_message_text = getResources().getString(R.string.register_message);

                    registerMessage.setText(register_message_text);
                    registerMessage.setVisibility(View.GONE);*/
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

        loginSpinner.setOnItemSelectedListener(this);

        List<School> schoolsArray = DataSingleton.getInstance().getSchools();
        List<String> schools = new ArrayList<String>();

        for (int i=0; i<schoolsArray.size(); i++) {
            String name = schoolsArray.get(i).getSchoolName();

            schools.add(name);
        }

        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, schools);

        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        loginSpinner.setAdapter(dataAdapter);

    }

    private void loginUser()
    {

        final String username = loginInputUserName.getText().toString();
        final String password = loginInputPassword.getText().toString();

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
                    btnloginRegister.setText("Try again");
                    btnloginRegister.setTag(new Integer(1));

                    registerMessage.setText("Error loggin in: " + e.getMessage());
                    registerMessage.setVisibility(View.VISIBLE);

                } else
                {

                    KeySaver.saveShare(LoginActivity.this, "username", username);
                    KeySaver.saveShare(LoginActivity.this, "password", password);
                    finish();
                }
            }
        });
    }

    private void registerUser()
    {

        //https://www.back4app.com/docs/pages/android/android-user-registration

        final String username = loginInputUserName.getText().toString();
        final String password = loginInputPassword.getText().toString();

        ParseUser user = new ParseUser();

        String usernameRegister = loginInputEmail.getText().toString();
        user.setUsername(usernameRegister);

        String passwordRegister = loginInputPassword.getText().toString();
        user.setPassword(passwordRegister);

        user.signUpInBackground(new SignUpCallback() {
            @Override
            public void done(ParseException e) {
                if (e == null) {

                    //alertDisplayer("Sucessful Sign Up!","Welcome" + <Insert Username Here> + "!");

                    Intent mA = new Intent(activity, MainActivity.class);
                    startActivity(mA);
                    finish();


                } else {
                    ParseUser.logOut();
                    Toast.makeText(LoginActivity.this, e.getMessage(), Toast.LENGTH_LONG).show();
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

                layoutUsername.setVisibility(View.VISIBLE);
                layoutPassword.setVisibility(View.VISIBLE);

                layoutEmail.setVisibility(View.GONE);
                layoutSpinner.setVisibility(View.GONE);

                btnloginRegister.setText("LOGIN");
                btnloginRegister.setTag(new Integer(0));

                break;
            case R.id.btn_register_segmented:

                layoutEmail.setVisibility(View.VISIBLE);
                layoutSpinner.setVisibility(View.VISIBLE);

                btnloginRegister.setText("REGISTER");
                btnloginRegister.setTag(new Integer(1));

                break;
            default:

        }

        /*
         layoutUsername = (TextInputLayout) findViewById(R.id.login_input_layout_username);
        layoutEmail = (TextInputLayout) findViewById(R.id.login_input_layout_email);
        layoutPassword = (TextInputLayout) findViewById(R.id.login_input_layout_password);
        layoutSpinner = (TextInputLayout) findViewById(R.id.login_input_layout_spinner);
         */
        /*
        loginInputUserName = (EditText) findViewById(R.id.login_input_username);
        loginInputPassword = (EditText) findViewById(R.id.login_input_password);
        loginInputEmail = (EditText) findViewById(R.id.login_input_email);
        loginSpinner = (AppCompatSpinner) findViewById(R.id.login_spinner);
         */

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


