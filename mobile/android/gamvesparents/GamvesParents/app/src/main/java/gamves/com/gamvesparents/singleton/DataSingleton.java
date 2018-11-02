package gamves.com.gamvesparents.singleton;

import java.util.ArrayList;
import java.util.List;

import gamves.com.gamvesparents.model.CategoryItem;
import gamves.com.gamvesparents.model.FanPageListItem;
import gamves.com.gamvesparents.model.FeedItem;
import gamves.com.gamvesparents.model.VideosListItem;

/**
 * Created by jose on 7/15/17.
 */

public class DataSingleton
{

    private List<CategoryItem> categoryList;

    private List<FeedItem> feedList;

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
