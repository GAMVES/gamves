package com.gamves.gamvescommunity.model;

import android.graphics.Bitmap;

import java.util.ArrayList;
import java.util.Hashtable;
import com.gamves.gamvescommunity.model.ParseAuxiliars.GamvesAvatar;

public class Consersation {

    private ArrayList<Message> listMessageData;
    private Hashtable<String, GamvesAvatar> avatarsData;

    public Consersation(){
        listMessageData = new ArrayList<>();
        avatarsData = new Hashtable<>();
    }

    public ArrayList<Message> getListMessageData()
    {
        return listMessageData;
    }

    public void addMessage(Message message)
    {
        listMessageData.add(message);
    }

    public void addBitmapToAvatar(String userId, Bitmap avatarBitmap)
    {
        GamvesAvatar av = avatarsData.get(userId);
        av.setAvatarBitmap(avatarBitmap);
        av.setDownloaded(true);
        av.setQuened(false);
    }

    public boolean isAvatarDownloaded(String key)
    {
        if (avatarsData.containsKey(key))
        {
            GamvesAvatar addedAvatar = avatarsData.get(key);
            Boolean isQuened = addedAvatar.getQuened();
            Boolean isDownloaded = addedAvatar.getDownloaded();
            if (isQuened)
            {
                return true;
            } else
            {
                return false;
            }
        } else
        {
            GamvesAvatar newAvatar = new GamvesAvatar();
            newAvatar.setDownloaded(false);
            newAvatar.setQuened(true);
            avatarsData.put(key, newAvatar);
            return false;
        }
    }



}
