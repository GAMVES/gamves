package gamves.com.gamvesparents.model;


/*

class GamvesSchools
{
    var objectId = String()
    var icon:UIImage?
    var thumbnail:UIImage?
    var schoolName = String()
    var schoolOBj:PFObject!
    var userCount = Int()
}
 */

import android.graphics.Bitmap;

import com.parse.ParseObject;

public class School {

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
