package com.gamves.gamvescommunity.model;

import android.graphics.Bitmap;

import com.panframe.android.lib.PFObjectFactory;
import com.parse.ParseObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jose on 4/20/16.
 **/
public class FanPageListItem {

    public String id;
    public String pageName;
    public String pageAbout;
    public String avatar;
    public List<VideosListItem> videos;
    public Boolean isActive;
    public String PageCoverUrl;

    private Bitmap pageIcon;
    private Bitmap pageCover;

    private String pageIconUrl;
    private String pageCoverUrl;

    private String pageLink;
    private String pageLikes;

    private ParseObject fanpageObject;

    public FanPageListItem() {

    }

    public FanPageListItem(String id, String pageName, String avatar) {
        this.id = id;
        this.pageName = pageName;
        this.avatar = avatar;
    }

    public FanPageListItem(String id, String pageName, String avatar, List<VideosListItem> videos) {
        this.id = id;
        this.pageName = pageName;
        this.avatar = avatar;
        this.videos = videos;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPageName() {
        return pageName;
    }

    public void setName(String pageName) {
        this.pageName = pageName;
    }

    public String getPageAbout() {
        return pageAbout;
    }

    public void setPageAbout(String pageAbout) {
        this.pageAbout = pageAbout;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public List<VideosListItem> getVideos()
    {

        if (videos==null)
            videos = new ArrayList<VideosListItem>();

        return videos;
    }

    public void setVideos(List<VideosListItem> videos) {
        this.videos = videos;
    }

    @Override
    public String toString() {
        return "FanPageListItem [id=" + id + ", name=" + pageName + ", avatar=" + avatar + ", videos=" + videos + "]";
    }

    public Boolean getActive() {
        return isActive;
    }

    public void setActive(Boolean active) {
        isActive = active;
    }

    public String getPageCoverUrl() {
        return PageCoverUrl;
    }

    public void setPageCoverurl(String pageCoverUrl) {
        PageCoverUrl = pageCoverUrl;
    }

    public Bitmap getPageIcon() {
        return pageIcon;
    }

    public void setPageIcon(Bitmap pageIcon) {
        this.pageIcon = pageIcon;
    }

    public Bitmap getPageCover() {
        return pageCover;
    }

    public void setPageName(String pageName) {
        this.pageName = pageName;
    }

    public void setPageCover(Bitmap pageCover) {
        this.pageCover = pageCover;
    }

    public void setPageIconUrl(String pageIconUrl) {
        this.pageIconUrl = pageIconUrl;
    }

    public void setPageCoverUrl(String pageCoverUrl) {
        PageCoverUrl = pageCoverUrl;
    }

    public String getPageIconUrl() {
        return pageIconUrl;
    }

    public String getPageLink() {
        return pageLink;
    }

    public String getPageLikes() {
        return pageLikes;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setPageLink(String pageLink) {
        this.pageLink = pageLink;
    }

    public void setPageLikes(String pageLikes) {
        this.pageLikes = pageLikes;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public ParseObject getFanpageObject() {
        return fanpageObject;
    }

    public void setFanpageObject(ParseObject fanpageObject) {
        this.fanpageObject = fanpageObject;
    }
}

