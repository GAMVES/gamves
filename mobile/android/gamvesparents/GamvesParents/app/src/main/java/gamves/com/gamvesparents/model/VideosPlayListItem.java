package gamves.com.gamvesparents.model;

/**
 * Created by Jose on 4/20/16.
 **/
public class VideosPlayListItem {

    public String title;
    public String id;

    public VideosPlayListItem(String title, String id) {
        this.title = title;
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    @Override
    public String toString() {
        return "VideosPlayListItem [title=" + title
                + ", id=" + id
                +"]";
    }
}
