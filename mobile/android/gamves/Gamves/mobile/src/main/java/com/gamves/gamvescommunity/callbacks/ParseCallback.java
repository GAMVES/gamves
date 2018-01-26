package com.gamves.gamvescommunity.callbacks;

import com.gamves.gamvescommunity.model.CategoryItem;

/**
 * Created by Jose on 4/21/16.
 **/
public interface ParseCallback {
    void onTaskCompleted();

    void onTaskCompletedCategory(CategoryItem item);
}
