package gamves.com.gamvesparents.model;

import com.parse.ParseGeoPoint;

import gamves.com.gamvesparents.ParentsApplication;


/**
 * Created by jose on 19/11/2017.
 */

public class User {

    private String First_Name;
    private String Last_Name;
    private String Email;
    private String Password;
    private String Telephone;
    private String Street;
    private int Street_Number;

    private double Latitude;
    private double Longitude;
    private ParseGeoPoint geolocation;

    private double Latitude_Local;
    private double Longitude_Local;
    private ParseGeoPoint geoLocalLocation;

    private ParentsApplication app;

    public User()
    {
        app = ParentsApplication.getInstance();
    }

    public String getFirst_Name() {
        return First_Name;
    }

    public String getLast_Name() {
        return Last_Name;
    }

    public String getEmail() {
        return Email;
    }

    public String getPassword() {
        return Password;
    }

    public String getTelephone() {
        return Telephone;
    }

    public String getStreet() {
        return Street;
    }

    public int getStreet_Number() {
        return Street_Number;
    }

    public double getLatitude() {
        return Latitude;
    }

    public double getLongitude() {
        return Longitude;
    }

    public void setFirst_Name(String first_Name) {
        First_Name = first_Name;
    }

    public void setLast_Name(String last_Name) {
        Last_Name = last_Name;
    }

    public void setEmail(String email) {
        Email = email;
    }

    public void setPassword(String password) {
        Password = password;
    }

    public void setTelephone(String telephone) {
        Telephone = telephone;
    }

    public void setStreet(String street) {
        Street = street;
    }

    public void setStreet_Number(int street_Number) {
        Street_Number = street_Number;
    }

    public void setLatitude(double latitude) {
        Latitude = latitude;
    }

    public void setLongitude(double longitude) {
        Longitude = longitude;
    }

    public ParseGeoPoint buildGeoLocation()
    {
        geolocation = new ParseGeoPoint(app.getLatitude(), app.getLongitude());
        return geolocation;
    }

    public double getLatitude_Local() {
        return Latitude_Local;
    }

    public double getLongitude_Local() {
        return Longitude_Local;
    }

    public void setLatitude_Local(double latitude_Local) {
        Latitude_Local = latitude_Local;
    }

    public void setLongitude_Local(double longitude_Local) {
        Longitude_Local = longitude_Local;
    }

    public ParseGeoPoint buildLocalGeoLocation()
    {
        geoLocalLocation = new ParseGeoPoint(app.getLocal_latitude(), app.getLocal_longitude());
        return geoLocalLocation;
    }

}
