package gamves.com.gamvesparents.singleton;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.widget.ImageView;

import com.parse.FindCallback;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.ArrayList;
import java.util.List;

import gamves.com.gamvesparents.ParentsApplication;
import gamves.com.gamvesparents.model.CategoryItem;
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

    public List<School> schools;

    private int countSchools = 0;

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

    public void querySchools() {

        ParseQuery<ParseObject> querySchools = ParseQuery.getQuery("Schools");

        querySchools.findInBackground(new FindCallback<ParseObject>() {

            @Override
            public void done(List<ParseObject> schoolList, ParseException e) {


                if (e == null) {

                    final List<School> schoolz = new ArrayList<School>();

                    final int shoolsAmount = schoolList.size();

                    for (int i = 0; i < schoolList.size(); i++) {

                        final ParseObject schoolOBj = schoolList.get(i);
                        final String objectId =  schoolList.get(i).getObjectId();
                        final String schoolName =  schoolList.get(i).getString("name");
                        final String shortName =  schoolList.get(i).getString("short");

                        ParseFile parseFile = schoolList.get(i).getParseFile("thumbnail");

                        parseFile.getDataInBackground(new GetDataCallback() {

                            @Override
                            public void done(byte[] data, ParseException e) {

                                if(e==null){

                                    Bitmap bitmapImage = BitmapFactory.decodeByteArray(data, 0, data.length);

                                    ImageView image = new ImageView(ParentsApplication.getInstance().getContext());
                                    image.setImageBitmap(bitmapImage);

                                    final School school = new School();
                                    school.setSchoolOBj(schoolOBj);
                                    school.setObjectId(objectId);
                                    school.setSchoolName(schoolName);
                                    school.setShortName(shortName);
                                    school.setImageView(image);
                                    school.setThumbnail(bitmapImage);

                                    schoolz.add(school);

                                    if (countSchools == shoolsAmount-1) {

                                        dataCallback.getSchools(schoolz);
                                        schools = schoolz;
                                    }

                                    countSchools++;
                                }
                                else{
                                    Log.i("info", e.getMessage());
                                }
                            }
                        });

                    }


                } else {
                    //there was a problem

                }
            }
        });
    };

    public List<School> getSchools() {
        return schools;
    }

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
