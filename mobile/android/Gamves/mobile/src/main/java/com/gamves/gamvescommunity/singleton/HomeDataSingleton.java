package com.gamves.gamvescommunity.singleton;

import com.gamves.gamvescommunity.model.CategoryItem;
import com.gamves.gamvescommunity.model.FanPageListItem;
import com.gamves.gamvescommunity.model.VideosListItem;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by jose on 7/15/17.
 */

public class HomeDataSingleton 
{

    private List<CategoryItem> categoryList;

 	private static HomeDataSingleton instance = null;
   	protected HomeDataSingleton() {
    	// Exists only to defeat instantiation.
        categoryList = new ArrayList<>();
   	}
   	public static HomeDataSingleton getInstance() {
      
      	if(instance == null) {
         	instance = new HomeDataSingleton();
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

    public CategoryItem getActiveCategory()
    {
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




}
