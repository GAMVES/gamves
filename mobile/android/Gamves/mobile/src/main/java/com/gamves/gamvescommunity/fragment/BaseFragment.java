package com.gamves.gamvescommunity.fragment;

import android.support.v4.app.Fragment;

/**
 * Created by jose on 7/17/17.
 */

public abstract class BaseFragment extends Fragment
{

    private boolean dataChanged = false;

    @Override
    public void onResume() {
        super.onResume();
        setDataChanged(false);
    }

    public boolean isDataChanged()
    {
        return dataChanged;
    }

    public void setDataChanged(boolean dataChanged)
    {
        this.dataChanged = dataChanged;
    }

    public abstract void updateData();

    public abstract void finishedLoad();


}
