package gamves.com.gamvesparents.model;

import android.graphics.Bitmap;

import com.parse.ParseObject;
import com.parse.ParseUser;

/**
 * Created by jose on 27/01/2018.
 */


public class Classes
{

    public static class GamvesAvatar
    {

        private Bitmap avatarBitmap;
        private Boolean isQuened;
        private Boolean isDownloaded;

        public GamvesAvatar() {
        }

        public Bitmap getAvatarBitmap() {
            return avatarBitmap;
        }

        public Boolean getDownloaded() {
            return isDownloaded;
        }

        public Boolean getQuened() {
            return isQuened;
        }

        public void setAvatarBitmap(Bitmap avatarBitmap) {
            this.avatarBitmap = avatarBitmap;
        }

        public void setDownloaded(Boolean downloaded) {
            isDownloaded = downloaded;
        }

        public void setQuened(Boolean quened) {
            isQuened = quened;
        }
    }

    public static class GamvesParseUser
    {
        private ParseUser gamvesUser;
        private String userId;

        public ParseUser getGamvesUser() {
            return gamvesUser;
        }

        public String getUserId() {
            return userId;
        }

        public void setGamvesUser(ParseUser gamvesUser) {
            this.gamvesUser = gamvesUser;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }
    }

    public static class GamvesParseUser
    {
        private ParseUser gamvesUser;
        private String userId;

        public ParseUser getGamvesUser() {
            return gamvesUser;
        }

        public String getUserId() {
            return userId;
        }

        public void setGamvesUser(ParseUser gamvesUser) {
            this.gamvesUser = gamvesUser;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }
    }


    public static class GamvesSchools
    {
        private String objectId;
        private Bitmap thumbnail;
        private String schoolName;
        private String shortName;
        private ParseObject schoolOBj;

        public String getObjectId() {
            return objectId;
        }

        public Bitmap getThumbnail() {
            return thumbnail;
        }

        public String getSchoolName() {
            return schoolName;
        }

        public String getShortName() {
            return shortName;
        }

        public ParseObject getSchoolOBj() {
            return schoolOBj;
        }

        public void setObjectId(String objectId) {
            this.objectId = objectId;
        }

        public void setThumbnail(Bitmap thumbnail) {
            this.thumbnail = thumbnail;
        }

        public void setSchoolName(String schoolName) {
            this.schoolName = schoolName;
        }

        public void setShortName(String shortName) {
            this.shortName = shortName;
        }

        public void setSchoolOBj(ParseObject schoolOBj) {
            this.schoolOBj = schoolOBj;
        }
    }



}
