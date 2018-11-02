package gamves.com.gamvesparents.model;

import android.widget.ImageView;

import com.parse.ParseObject;

import java.util.List;

/**
 * Created by jose on 4/20/16.
 */
public class FeedItem {

    public int id;
    public String text;
    public Boolean isVideoChat;
    public ImageView chatThumbnail;
    public ImageView userThumbnail;
    public int chatId;
    public String lasPoster;
    public List<Classes.GamvesParseUser> usersList;
    public String users;
    public Boolean usersLoaded;
    public Boolean imagesLoaded;
    public Boolean badgeIsActive;
    public Boolean badgeNumber;
    public ParseObject feedObj;

    public FeedItem(int id,
                    String text,
                    Boolean isVideoChat,
                    String lasPoster,
                    int chatId,
                    String users,
                    Boolean usersLoaded,
                    Boolean imagesLoaded,
                    Boolean badgeIsActive,
                    Boolean badgeNumber,
                    ParseObject feedObj) {
        this.id = id;
        this.text = text;
        this.isVideoChat = isVideoChat;
        this.lasPoster = lasPoster;
        this.chatId = chatId;
        this.users = users;
        this.usersLoaded = usersLoaded;
        this.imagesLoaded = imagesLoaded;
        this.badgeIsActive = badgeIsActive;
        this.badgeNumber = badgeNumber;
        this.feedObj = feedObj;
    }


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getText() {
        return text;
    }

    public Boolean getVideoChat() {
        return isVideoChat;
    }

    public ImageView getChatThumbnail() {
        return chatThumbnail;
    }

    public ImageView getUserThumbnail() {
        return userThumbnail;
    }

    public int getChatId() {
        return chatId;
    }

    public String getLasPoster() {
        return lasPoster;
    }

    public List<Classes.GamvesParseUser> getUsersList() {
        return usersList;
    }

    public String getUsers() {
        return users;
    }

    public Boolean getUsersLoaded() {
        return usersLoaded;
    }

    public Boolean getImagesLoaded() {
        return imagesLoaded;
    }

    public Boolean getBadgeIsActive() {
        return badgeIsActive;
    }

    public Boolean getBadgeNumber() {
        return badgeNumber;
    }

    public ParseObject getFeedObj() {
        return feedObj;
    }

    public void setText(String text) {
        this.text = text;
    }

    public void setVideoChat(Boolean videoChat) {
        isVideoChat = videoChat;
    }

    public void setChatThumbnail(ImageView chatThumbnail) {
        this.chatThumbnail = chatThumbnail;
    }

    public void setUserThumbnail(ImageView userThumbnail) {
        this.userThumbnail = userThumbnail;
    }

    public void setChatId(int chatId) {
        this.chatId = chatId;
    }

    public void setLasPoster(String lasPoster) {
        this.lasPoster = lasPoster;
    }

    public void setUsersList(List<Classes.GamvesParseUser> usersList) {
        this.usersList = usersList;
    }

    public void setUsers(String users) {
        this.users = users;
    }

    public void setUsersLoaded(Boolean usersLoaded) {
        this.usersLoaded = usersLoaded;
    }

    public void setImagesLoaded(Boolean imagesLoaded) {
        this.imagesLoaded = imagesLoaded;
    }

    public void setBadgeIsActive(Boolean badgeIsActive) {
        this.badgeIsActive = badgeIsActive;
    }

    public void setBadgeNumber(Boolean badgeNumber) {
        this.badgeNumber = badgeNumber;
    }

    public void setFeedObj(ParseObject feedObj) {
        this.feedObj = feedObj;
    }

    @Override
    public String toString() {
        return "VideosListItem [id=" + id
                + ", text=" + text
                + ", isVideoChat=" + isVideoChat
                + ", chatThumbnail=" + chatThumbnail
                + ", userThumbnail=" + userThumbnail
                + ", chatId=" + chatId
                + ", lasPoster=" + lasPoster
                + ", users=" + users
                + ", usersLoaded=" + usersLoaded
                + ", imagesLoaded=" + imagesLoaded
                + ", badgeIsActive=" + badgeIsActive
                + ", badgeNumber=" + badgeNumber
                + "]";
    }
}
