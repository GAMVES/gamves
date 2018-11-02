package gamves.com.gamvesparents.model;


import java.util.Date;

public class Message
{
    public String message;
    public String userId;
    public String fanpageId;
    public String videoId;
    public Date dateTime;

    public String getMessage() {
        return message;
    }

    public String getUserId() {
        return userId;
    }

    public String getFanpageId() {
        return fanpageId;
    }

    public String getVideoId() {
        return videoId;
    }

    public Date getDateTime() {
        return dateTime;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public void setFanpageId(String fanpageId) {
        this.fanpageId = fanpageId;
    }

    public void setVideoId(String videoId) {
        this.videoId = videoId;
    }

    public void setDateTime(Date dateTime) {
        this.dateTime = dateTime;
    }
}