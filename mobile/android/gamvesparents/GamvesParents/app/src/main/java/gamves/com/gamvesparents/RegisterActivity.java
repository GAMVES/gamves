package gamves.com.gamvesparents;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseRelation;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.SignUpCallback;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;

import gamves.com.gamvesparents.model.User;
import gamves.com.gamvesparents.utils.HttpParse;

/**
 * Created by jose on 14/11/2017.
 */

public class RegisterActivity extends AppCompatActivity {

    Button register, log_in;
    EditText First_Name, Last_Name, Email, Phone, Password, Address_Street, Address_Number;
    String F_Name_Holder, L_Name_Holder, EmailHolder, PhoneHolder, PasswordHolder, AddressHolder, AddressNumberHolder;
    String finalResult ;
   
    //String HttpURL = "https://androidjsonblog.000webhostapp.com/User/UserRegistration.php";
    String HttpURL = "http://nosquedamos.ddns.net/nosquedamos/UserRegistration.php";

    Boolean CheckEditText ;
    ProgressDialog progressDialog;
    HashMap<String,Object> hashMap = new HashMap<>();
    static HashMap<String,Object> hashMapAddress = new HashMap<>();

    private static ParentsApplication app;
    HttpParse httpParse = new HttpParse();

    private static LatLng goodLatLng = new LatLng(37, -120);
    private GoogleMap googleMap;
    LatLng addressPos, finalAddressPos;
    Marker addressMarker;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        app = ParentsApplication.getInstance();

        double lat = app.getLatitude();

        //Assign Id'S
        First_Name = (EditText)findViewById(R.id.editTextF_Name);
        Last_Name = (EditText)findViewById(R.id.editTextL_Name);
        Email = (EditText)findViewById(R.id.editTextEmail);
        Phone = (EditText)findViewById(R.id.editTextPhone);
        Password = (EditText)findViewById(R.id.editTextPassword);
        Address_Street = (EditText) findViewById(R.id.editTextAddress);
        Address_Number = (EditText) findViewById(R.id.editTextNumber);

        register = (Button)findViewById(R.id.Submit);
        log_in = (Button)findViewById(R.id.Login);

        First_Name.setText("Jose");
        Last_Name.setText("Vigil");
        Email.setText("josemanuelvigil@gmail.com");
        Phone.setText("+540111551812085");
        Address_Street.setText("Pablo Pizzurno");
        Address_Number.setText("1031");
        Password.setText("dale");

        register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                String startingAddress = Address_Street.getText().toString();
                String finalAddress = Address_Number.getText().toString();
                GetDirections directions = new GetDirections();

                directions.setOnGetDirections(new GetDirections.OnGetDirections() {

                    @Override
                    public void jsonDirectionsFound()
                    {
                        // Checking whether EditText is Empty or Not
                        CheckEditTextIsEmptyOrNot();

                        if(CheckEditText)
                        {
                            User user = new User();
                            user.setFirst_Name(First_Name.getText().toString());
                            user.setLast_Name(Last_Name.getText().toString());
                            user.setEmail(Email.getText().toString());
                            user.setTelephone(Phone.getText().toString());
                            user.setStreet(Address_Street.getText().toString());
                            user.setStreet_Number(Integer.parseInt(Address_Number.getText().toString()));
                            user.setPassword(Password.getText().toString());

                            app.setUser(user);

                            new UserRegisterFunctionClass().execute();
                        }
                        else {
                            // If EditText is empty then this block will execute .
                            Toast.makeText(RegisterActivity.this, "Please fill all form fields.", Toast.LENGTH_LONG).show();
                        }

                    }
                });

                directions.execute(startingAddress, finalAddress);

            }
        });

        log_in.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Intent intent = new Intent(RegisterActivity.this, UserLoginActivity.class);
                startActivity(intent);

            }
        });
    }

    public void CheckEditTextIsEmptyOrNot()
    {
        F_Name_Holder = First_Name.getText().toString();
        L_Name_Holder = Last_Name.getText().toString();
        EmailHolder = Email.getText().toString();
        PhoneHolder = Password.getText().toString();
        AddressHolder = Address_Street.getText().toString();
        AddressNumberHolder = Address_Number.getText().toString();
        PasswordHolder = Password.getText().toString();

        if(TextUtils.isEmpty(F_Name_Holder)         ||
                TextUtils.isEmpty(L_Name_Holder)    ||
                TextUtils.isEmpty(EmailHolder)      ||
                TextUtils.isEmpty(AddressHolder)    ||
                TextUtils.isEmpty(AddressNumberHolder)  ||
                TextUtils.isEmpty(PasswordHolder))
        {
            CheckEditText = false;

        } else {

            CheckEditText = true ;
        }
    }

    class UserRegisterFunctionClass extends AsyncTask<String,Void,String> {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            progressDialog = ProgressDialog.show(RegisterActivity.this,"Loading Data",null,true,true);
        }

        @Override
        protected void onPostExecute(String httpResponseMsg) {

            super.onPostExecute(httpResponseMsg);

            progressDialog.dismiss();

            String response = httpResponseMsg.toString();

            if (response.contains("failed"))
            {
                Toast.makeText(RegisterActivity.this,httpResponseMsg.toString(), Toast.LENGTH_LONG).show();
                //createParseUser();
            } else if (response.contains("successfully"))
            {
                createParseUser();
            }

        }

        @Override
        protected String doInBackground(String... params)
        {
            hashMap.put("f_name", app.getUser().getFirst_Name());
            hashMap.put("L_name", app.getUser().getLast_Name());
            hashMap.put("email", app.getUser().getEmail());
            hashMap.put("telefono", app.getUser().getTelephone());
            hashMap.put("calle", app.getUser().getStreet());
            hashMap.put("numero", app.getUser().getStreet_Number());
            hashMap.put("password", app.getUser().getPassword());

            hashMap.put("lat_local", app.getLocal_latitude());
            hashMap.put("lng_local", app.getLocal_longitude());

            hashMap.put("lat", app.getLatitude());
            hashMap.put("lng", app.getLongitude());

            try
            {
                finalResult = httpParse.postRequest(hashMap, HttpURL);

            } catch (Exception ex)
            {
                Log.v("", ex.toString());
            }
            return finalResult;
        }
    }

    private static class GetDirections extends AsyncTask<String, String, JSONObject> {

        private OnGetDirections onGetDirections;

        public interface OnGetDirections
        {
            void jsonDirectionsFound();
        }

        public void setOnGetDirections(OnGetDirections onGetDirections)
        {
            this.onGetDirections = onGetDirections;
        }

        int counter = 0;

        public interface DataDownloadListener {
            public void dataDownloadedSuccessfully(JSONObject json);
            public void dataDownloadFailed();
        }

        DataDownloadListener dataDownloadListener;
        public void setDataDownloadListener(DataDownloadListener dataDownloadListener) {
            this.dataDownloadListener = dataDownloadListener;
        }

        protected void onPreExecute() {
            super.onPreExecute();

        }

        protected JSONObject doInBackground(String... params)
        {

            JSONObject jsonDirectionObject = null;
            String startAddress =  params[0];
            String startNumber  =  params[1];
            startAddress += " " + startNumber + " Hurlingham";
            startAddress = startAddress.replaceAll(" ", "%20");
            String uri = "http://maps.google.com/maps/api/geocode/json?address="
                    + startAddress + "&sensor=false";
            HttpURLConnection connection = null;
            BufferedReader reader = null;

            try
            {
                URL url = new URL(uri);
                connection = (HttpURLConnection) url.openConnection();
                connection.connect();

                InputStream stream = connection.getInputStream();
                reader = new BufferedReader(new InputStreamReader(stream));
                StringBuffer buffer = new StringBuffer();
                String line = "";

                while ((line = reader.readLine()) != null) {
                    buffer.append(line+"\n");
                    Log.d("Response: ", "> " + line);   //here u ll get whole response...... :-)
                }

                double lat = 0.0, lng = 0.0;

                try {
                    jsonDirectionObject = new JSONObject(buffer.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                try {

                    lng = ((JSONArray) jsonDirectionObject.get("results")).getJSONObject(0)
                            .getJSONObject("geometry").getJSONObject("location")
                            .getDouble("lng");
                    lat = ((JSONArray) jsonDirectionObject.get("results")).getJSONObject(0)
                            .getJSONObject("geometry").getJSONObject("location")
                            .getDouble("lat");

                    app.setLocal_latitude(lat);
                    app.setLocal_longitude(lng);

                    return jsonDirectionObject;

                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } catch (MalformedURLException e) {

                e.printStackTrace();

            } catch (IOException e) {

                e.printStackTrace();

            } finally
            {
                if (connection != null)
                {
                    connection.disconnect();
                }
                try {

                    if (reader != null)
                    {
                        reader.close();
                    }

                } catch (IOException e)
                {
                    e.printStackTrace();
                }
            }

            return jsonDirectionObject;
        }

        @Override
        protected void onPostExecute(JSONObject seccionesJson)
        {
            super.onPostExecute(seccionesJson);


            this.onGetDirections.jsonDirectionsFound();


        }
    }

    private void createParseUser()
    {
        final ParseUser user = new ParseUser();

        user.setUsername(app.getUser().getEmail());
        user.setPassword(app.getUser().getPassword());

        user.put("firstName", app.getUser().getFirst_Name());
        user.put("lastName", app.getUser().getLast_Name());
        user.put("phone", app.getUser().getLast_Name());
        user.put("email", app.getUser().getEmail());
        //user.put("address", app.getUser().getStreet());
        //user.put("addressNumber", app.getUser().getStreet_Number());
        user.put("geolocation", app.getUser().buildGeoLocation());

        user.signUpInBackground(new SignUpCallback() {

            @Override
            public void done(ParseException e) {

                if (e == null) {
                    // Signup successful!

                    final ParseObject casa = new ParseObject("Casas");
                    casa.put("street", app.getUser().getStreet());
                    casa.put("number", app.getUser().getStreet_Number());
                    casa.put("geoLocalLocation", app.getUser().buildLocalGeoLocation());

                    casa.saveInBackground(new SaveCallback() {
                        @Override
                        public void done(ParseException e) {

                            if (e == null) {
                                // Signup successful!

                                ParseRelation<ParseObject> relation = user.getRelation("casa");
                                relation.add(casa);

                                user.saveInBackground();

                                finish();
                            }

                        }
                    });

                    finish();
                } else {
                    // Fail!
                    AlertDialog.Builder builder = new AlertDialog.Builder(RegisterActivity.this);
                    builder.setMessage(e.getMessage())
                            .setTitle("Oops!")
                            .setPositiveButton(android.R.string.ok, null);
                    AlertDialog dialog = builder.create();
                    dialog.show();
                }
            }
        });
    }


}