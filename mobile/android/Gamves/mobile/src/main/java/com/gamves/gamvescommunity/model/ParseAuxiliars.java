package com.gamves.gamvescommunity.model;

import android.graphics.Bitmap;

import com.parse.ParseUser;

/**
 * Created by jose on 10/2/17.
 */

public class ParseAuxiliars
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



}
