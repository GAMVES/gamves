package com.gamves.gamvescommunity.utils;

import android.content.Context;
import android.util.AttributeSet;
import android.view.SurfaceView;

/**
 * Created by Jose on 3/3/16.
 **/
public class WideVideoView extends SurfaceView {

    public WideVideoView(Context context) {
        super(context);
    }

    public WideVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public WideVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        float ratio = 9.0f / 16;
        setMeasuredDimension(getMeasuredWidth(), Math.round(getMeasuredWidth() * ratio));
    }
}
