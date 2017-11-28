package com.gamves.gamvescommunity;

import android.app.ProgressDialog;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.ColorInt;
import android.support.annotation.IdRes;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.gamves.gamvescommunity.utils.KeySaver;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseUser;

import org.w3c.dom.Text;

import info.hoang8f.android.segmented.SegmentedGroup;

public class LoginActivity extends AppCompatActivity implements  RadioGroup.OnCheckedChangeListener,
        View.OnClickListener {

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
        loginInputUserName = (EditText) findViewById(R.id.login_input_username);
        loginInputPassword = (EditText) findViewById(R.id.login_input_password);
        register_message = (TextView) findViewById(R.id.register_message);
        btnlogin = (Button) findViewById(R.id.btn_login);
        btnlogin.setTag(new Integer(0));

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

                loginInputUserName.setVisibility(View.VISIBLE);
                loginInputPassword.setVisibility(View.VISIBLE);
                btnlogin.setVisibility(View.VISIBLE);
                register_message.setVisibility(View.GONE);

                break;
            case R.id.btn_register_segmented:

                loginInputUserName.setVisibility(View.GONE);
                loginInputPassword.setVisibility(View.GONE);
                btnlogin.setVisibility(View.GONE);
                register_message.setVisibility(View.VISIBLE);

                break;
            default:

        }

    }
}


