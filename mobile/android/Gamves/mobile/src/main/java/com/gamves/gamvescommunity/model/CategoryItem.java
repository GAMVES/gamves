package com.gamves.gamvescommunity.model;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.drawable.GlideDrawable;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.gamves.gamvescommunity.R;
import com.gamves.gamvescommunity.utils.ImageConverter;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;

import java.util.List;

import com.gamves.gamvescommunity.R;

/**
 * Created by mariano on 4/20/16.
 **/
public class CategoryItem {

    public String id;
    public String name;

    private Bitmap thumbnail;
    private Bitmap background;

    private String thumbnailUrl;
    private String backgroundUrl;

    //public ParseFile thubFile;

    public List<FanPageListItem> fanpages;
    private Context context;
    boolean isActive;

    int gradientId;

    public CategoryItem(Context context) {
        this.context = context;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Bitmap getThumbnailBitmap() {
        return thumbnail;
    }

    public Bitmap getBackgroundBitmap() {
        return background;
    }

    public void setThumbnail(Bitmap thumbnail) {
        this.thumbnail = thumbnail;
    }

    public void setBackground(Bitmap background) {
        this.background = background;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public String getBackgroundUrl() {
        return backgroundUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public void setBackgroundUrl(String backgroundUrl) {
        this.backgroundUrl = backgroundUrl;
    }

    public int getGradientId() {
        return gradientId;
    }

    public void setGradientId(int gradientId) {
        this.gradientId = gradientId;
    }

    public List<FanPageListItem> getFanpages() {
        return fanpages;
    }

    public void setFanpages(List<FanPageListItem> fanpages) {
        this.fanpages = fanpages;
    }

    @Override
    public String toString() {
        return "FanPageListItem [id=" + id + ", name=" + name + ", videos=" + fanpages + "]";
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}

