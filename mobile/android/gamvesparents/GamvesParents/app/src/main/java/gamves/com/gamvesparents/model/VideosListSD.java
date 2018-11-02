package gamves.com.gamvesparents.model;

/**
 * Created by Jose on 4/20/16.
 **/
public class VideosListSD {

    public String title;
    public String description;
    public String timeSaved;
    public String path;

    public VideosListSD(String title, String description, String timeSaved, String path) {
        this.title = title;
        this.description = description;
        this.timeSaved = timeSaved;
        this.path = path;
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

    public String getTimeSaved() {
        return timeSaved;
    }

    public void setTimeSaved(String timeSaved) {
        this.timeSaved = timeSaved;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    @Override
    public String toString() {
        return "VideosListSD [title=" + title
                + ", description=" + description
                + ", timeSaved=" + timeSaved
                + ", path=" + path +"]";
    }
}
