package gamves.com.gamvesparents.model;

/**
 * Created by Jose on 4/20/16.
 */
public class VideoItem {

    public String id;
    public String thumbnail;
    public String title;
    public String description;
    public String created_time;
    public String source;
    public String fromId;
    public String fromName;
    public Long length;
    public boolean isFeatured;

    public VideoItem(String id, String thumbnail, String title, String description) {
        this.id = id;
        this.thumbnail = thumbnail;
        this.title = title;
        this.description = description;
    }

    public VideoItem(String id, String thumbnail, String source, String title, String description, String created_time, Long length, String fromId, String fromName) {
        this.id = id;
        this.thumbnail = thumbnail;
        this.source = source;
        this.title = title;
        this.description = description;
        this.created_time = created_time;
        this.length = length;
        this.fromId = fromId;
        this.fromName = fromName;
    }

    public VideoItem(String id, String thumbnail, String source, String title, String description, String created_time, Long length, String fromId, String fromName, boolean isFeatured) {
        this.id = id;
        this.thumbnail = thumbnail;
        this.source = source;
        this.title = title;
        this.description = description;
        this.created_time = created_time;
        this.length = length;
        this.fromId = fromId;
        this.fromName = fromName;
        this.isFeatured = isFeatured;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(String thumbnail) {
        this.thumbnail = thumbnail;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long getLength() {
        return length;
    }

    public void setLength(Long length) {
        this.length = length;
    }

    public String getCreatedTime() {
        return created_time;
    }

    public void setCreatedTime(String created_time) {
        this.created_time = created_time;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getFromId() {
        return fromId;
    }

    public void setFromId(String fromId) {
        this.fromId = fromId;
    }

    public String getFromName() {
        return fromName;
    }

    public void setFromName(String fromName) {
        this.fromName = fromName;
    }

    public boolean isFeatured() {
        return isFeatured;
    }

    public void setFeatured(boolean featured) {
        isFeatured = featured;
    }

    @Override
    public String toString() {
        return "VideosListItem [id=" + id
                + ", thumbnail=" + thumbnail
                + ", source=" + source
                + ", title=" + title
                + ", description=" + description
                + ", created_time=" + created_time
                + ", length=" + length
                + ", fromId=" + fromId
                + ", fromName=" + fromName
                + ", isFeatured=" + isFeatured
                + "]";
    }
}
