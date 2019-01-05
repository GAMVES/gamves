package gamves.com.gamvesparents.singleton;

import android.app.AlertDialog;
import android.util.Log;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.ArrayList;
import java.util.List;

import gamves.com.gamvesparents.GamvesParentsApplication;
import gamves.com.gamvesparents.UserLoginActivity;
import gamves.com.gamvesparents.model.CategoryItem;
import gamves.com.gamvesparents.model.Classes;
import gamves.com.gamvesparents.model.FanPageListItem;
import gamves.com.gamvesparents.model.FeedItem;
import gamves.com.gamvesparents.model.School;
import gamves.com.gamvesparents.model.VideosListItem;

/**
 * Created by jose on 7/15/17.
 */

public class DataSingleton
{

    private List<CategoryItem> categoryList;

    private List<FeedItem> feedList;

    private List<School> schools;

 	private static DataSingleton instance = null;
   	protected DataSingleton() {
    	// Exists only to defeat instantiation.
        categoryList = new ArrayList<>();
   	}
   	public static DataSingleton getInstance() {
      
      	if(instance == null) {
         	instance = new DataSingleton();
      	}


      	return instance;
   }

    public List<CategoryItem> getCategoryList()
    {
        return categoryList;
    }

    public void setCategoryList(List<CategoryItem> categoryList) {
        this.categoryList = categoryList;
    }

    public void addCategoryItem(CategoryItem categoryItem)
    {
        this.categoryList.add(categoryItem);
    }

    public CategoryItem getActiveCategory() {

        CategoryItem catItem = null;
        for (int i=0; i<categoryList.size(); i++)
        {
            if (categoryList.get(i).isActive())
            {
                return categoryList.get(i);
            }
        }
        return catItem;
    }

    public FanPageListItem getActiveFanpage()
    {
        FanPageListItem fanpageItem = null;

        CategoryItem activeCategory = getActiveCategory();
        List<FanPageListItem> listFanpage = activeCategory.getFanpages();

        for (int i=0;i<listFanpage.size(); i++)
        {
            Boolean active = (Boolean) listFanpage.get(i).getActive();
            if (active!=null && active)
            {
                return listFanpage.get(i);
            }
        }

        return fanpageItem;
    }

    public void addVideoToFunpage(VideosListItem videoItem)
    {
        FanPageListItem active_fanpage = getActiveFanpage();

        active_fanpage.getVideos().add(videoItem);
    }

    public boolean hasCategories()
    {
        if (categoryList!=null)
        {
            if (categoryList.size() > 0)
                return true;
        }
        return false;
    }

    //-
    //  SCHOOL
    // private Bitmap avatarBitmap;

    public void getSchools() {

        ParseQuery<ParseObject> querySchools = ParseQuery.getQuery("Schools");

        querySchools.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> schoolList, ParseException e) {
                if (e == null) {

                    Log.d("score", "Retrieved " + schoolList.size() + " scores");

                    List<School> schoolz = null;

                    for (int i=0; i<schoolList.size(); i++){

                        ParseObject schoolPF =  schoolList.get(i);

                        School school = new School();

                        school.setObjectId(schoolPF.getString("objectId"));

                        schoolz.add(school);

                        /*
                        private String objectId;
                        private Bitmap thumbnail;
                        private String schoolName;
                        private String shortName;
                        private ParseObject schoolOBj;
                         */

                    }

                    schools = schoolz;

                    dataCallback.getSchools(schoolz);

                } else {
                    Log.d("score", "Error: " + e.getMessage());
                }
            }
        });
    };

    private OnDataCallback dataCallback;
    public interface OnDataCallback
    {
        void getSchools(List<School> schools);
    }
    public void setOnDataCallback(OnDataCallback callback){
        this.dataCallback = callback;
    }

    public List<FeedItem> getFeedList() {
        return feedList;
    }

    public void setFeedList(List<FeedItem> feedList) {
        this.feedList = feedList;
    }

    public void addFeedToFeeList(FeedItem feedItem) {
   	    this.feedList.add(feedItem);
    }

}
