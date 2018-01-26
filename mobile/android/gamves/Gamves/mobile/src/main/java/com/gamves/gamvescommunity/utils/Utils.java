package com.gamves.gamvescommunity.utils;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.ActionBar;
import android.support.v8.renderscript.Allocation;
import android.support.v8.renderscript.Element;
import android.support.v8.renderscript.RenderScript;
import android.support.v8.renderscript.ScriptIntrinsicBlur;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.Transformation;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.gamves.gamvescommunity.GamvesApplication;
import com.gamves.gamvescommunity.model.VideosListSD;
import com.gamves.gamvescommunity.utils.snackbar.TSnackbar;
import com.wang.avi.AVLoadingIndicatorView;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import com.gamves.gamvescommunity.R;

/**
 * Created by mariano on 2/27/16.
 **/
public class Utils {

    private static Utils INSTANCE = new Utils();
    private MediaMetadataRetriever mediaRetriever;

    public static Utils get() {
        return INSTANCE;
    }

    private static final int SPEED_EXPAND_COLLAPSE = 200;

    private String captureTitle;
    private int capturePosition;
    private String captureSource;
    private Activity context;
    private View snackView;
    private boolean offline;
    private View popupView;

    public static void expand(final View v) {
        v.measure(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final int targetHeight = v.getMeasuredHeight();

        // Older versions of android (pre API 21) cancel animations for views with a height of 0.
        v.getLayoutParams().height = 1;
        v.setVisibility(View.VISIBLE);
        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                v.getLayoutParams().height = interpolatedTime == 1
                        ? ViewGroup.LayoutParams.WRAP_CONTENT
                        : (int) (targetHeight * interpolatedTime);
                v.requestLayout();
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        // 1dp/ms
        a.setDuration((int) (targetHeight / v.getContext().getResources().getDisplayMetrics().density) + SPEED_EXPAND_COLLAPSE);
        v.startAnimation(a);
    }

    public static void collapse(final View v) {
        final int initialHeight = v.getMeasuredHeight();

        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                if (interpolatedTime == 1) {
                    v.setVisibility(View.GONE);
                } else {
                    v.getLayoutParams().height = initialHeight - (int) (initialHeight * interpolatedTime);
                    v.requestLayout();
                }
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        // 1dp/ms
        a.setDuration((int) (initialHeight / v.getContext().getResources().getDisplayMetrics().density) + SPEED_EXPAND_COLLAPSE);
        v.startAnimation(a);
    }

//    public static String maxLines(TextView textView, int maxLines) {
//        if (textView.getLineCount() > maxLines && textView.getLineCount() > 0 && maxLines > 0) {
//            int lineEndIndex = textView.getLayout().getLineEnd(maxLines - 1);
//
//            return textView.getText().subSequence(0, lineEndIndex - 3) + "...";
//        }else{
//            return textView.getText().toString();
//        }
//    }

    public static Drawable setDrawable(int imageDrawable) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return GamvesApplication.CONTEXT.getDrawable(imageDrawable);
        } else {
            return GamvesApplication.CONTEXT.getResources().getDrawable(imageDrawable);
        }
    }

    public static String setGlideDrawable(String drawable) {
        return "android.resource://com.gamves/drawable/" + drawable;
    }

    public static void setStatusBarTranslucent(boolean makeTranslucent, boolean makeDisappear, Activity context, ActionBar bar) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            if (makeTranslucent) {
                if (makeDisappear) {
                    View decorView = context.getWindow().getDecorView();
                    int uiOptions = View.SYSTEM_UI_FLAG_FULLSCREEN;
                    decorView.setSystemUiVisibility(uiOptions);
                }
                context.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            } else {
                context.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            }
        }

        if (bar != null) {
            bar.setBackgroundDrawable(new ColorDrawable(Utils.getColorInt(context, R.color.transparent_white)));
            bar.setTitle("");
        }

    }

    public static void setClearStatus(Activity activity) {

        final int orientation = activity.getResources().getConfiguration().orientation;

        switch (orientation) {
            case Configuration.ORIENTATION_PORTRAIT:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    View decorView = activity.getWindow().getDecorView();
                    int uiOptions = View.SYSTEM_UI_FLAG_FULLSCREEN;
                    decorView.setSystemUiVisibility(uiOptions);
                    activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
                    activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
                }
                break;
            case Configuration.ORIENTATION_LANDSCAPE:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION, WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
                    activity.getWindow().getDecorView().setSystemUiVisibility(
                            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                                    | View.SYSTEM_UI_FLAG_IMMERSIVE);
                } else {
                    activity.getWindow().getDecorView().setSystemUiVisibility(
                            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                                    | View.SYSTEM_UI_FLAG_FULLSCREEN);
                    break;
                }

        }
    }

    public static void setStatusBarTranslucent(boolean makeTranslucent, boolean makeDisappear, Activity context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            if (makeTranslucent) {
                if (makeDisappear) {
                    View decorView = context.getWindow().getDecorView();
                    int uiOptions = View.SYSTEM_UI_FLAG_FULLSCREEN;
                    decorView.setSystemUiVisibility(uiOptions);
                }
                context.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            } else {
                context.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            }
        }
    }

    public static String convertToHMmSs(long milliseconds) {
        long s = milliseconds % 60;
        long m = (milliseconds / 60) % 60;
        // FOR HOURS long h = (milliseconds / (60 * 60)) % 24;
        return String.format(Locale.ENGLISH, "%02d:%02d", m, s);
    }

//    public static void tintWidget(View view, String color) {
//        Drawable wrappedDrawable = DrawableCompat.wrap(view.getBackground());
//        DrawableCompat.setTint(wrappedDrawable, Color.parseColor(color));
//        view.setBackgroundDrawable(wrappedDrawable);
//    }

    public static int getColorInt(Context context, int id) {
        final int version = Build.VERSION.SDK_INT;
        if (version >= 23) {
            return ContextCompat.getColor(context, id);
        } else {
            return context.getResources().getColor(id);
        }
    }

    /**
     * set Progress animation
     */

    public static void showProgress(final AVLoadingIndicatorView view) {
        view.setVisibility(View.VISIBLE);
        view.animate().alpha(1).setStartDelay(500).setDuration(400).withEndAction(new Runnable() {
            @Override
            public void run() {
                view.setAlpha(1);
            }
        });
    }

    public static void hideProgress(final AVLoadingIndicatorView view) {
        view.animate().alpha(0).setDuration(200).withEndAction(new Runnable() {
            @Override
            public void run() {
                view.setAlpha(0);
                view.setVisibility(View.GONE);
            }
        });
    }

    public static boolean isProgressVisible(AVLoadingIndicatorView view) {
        return view.getVisibility() == View.VISIBLE;
    }

    public static void showTopSnackBar(Activity context, int view, String bgColor, String text, String textColor) {
        final TSnackbar snackbar = TSnackbar.make(context.findViewById(view), text, TSnackbar.LENGTH_LONG);
        View snackbarView = snackbar.getView();
        snackbarView.setBackgroundColor(Color.parseColor(bgColor));
        TextView textView = (TextView) snackbarView.findViewById(R.id.snackbar_text);
        textView.setTextColor(Color.parseColor(textColor));
        snackbar.setAction(GamvesApplication.CONTEXT.getResources().getString(R.string.snack_close), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                snackbar.dismiss();
            }
        });
        snackbar.setActionTextColor(Color.WHITE);
        snackbar.show();
    }

    public static void startActivityOnTop(Activity activity, Class toActivity) {
        Intent intent = new Intent(activity, toActivity);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        activity.startActivity(intent);
        activity.finish();
    }

    public static void startApplicationIntent(Activity activity) {
        Intent i = GamvesApplication.CONTEXT.getPackageManager()
                .getLaunchIntentForPackage(GamvesApplication.CONTEXT.getPackageName());
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_CLEAR_TASK
                | Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(i);
        activity.finish();
    }

    public static Date setDaysFromNow(int date) {
        TimeZone timeZone = TimeZone.getTimeZone("UTC");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        sdf.setTimeZone(timeZone);

        long dateToFormat = System.currentTimeMillis() - (1000 * 60 * 60 * 24 * date);

        return new Date(dateToFormat);
    }

    public static String videoFanPage(String title) {

        if (title.length() > 30) {
            return title.substring(0, 30) + "...";
        } else {
            return title;
        }
    }

    public static String videoTitle(String title) {

        if (title.length() > 40) {
            return title.substring(0, 40) + "...";
        } else {
            return title;
        }
    }

    public static String videoTitleSD(String title) {
        if (title.length() > 30) {
            return title.substring(0, 30);
        } else {
            return title;
        }
    }

    public static String videoDescriptionSD(String description) {

        if (description.length() > 60) {
            return description.substring(0, 60);
        } else {
            return description;
        }
    }

    public static String setVideoSDName(String title, String description, long time) {
        String finalTitle = title != null ? title : "Shall TV Video";
        String toTitle = finalTitle.replaceAll("[^A-Za-z0-9()\\[\\] ]+", "").length() < 1 ? "Shall TV Video" : finalTitle.replaceAll("[^A-Za-z0-9()\\[\\] ]+", "");
        String finalDescription = description != null ? description : "No current description available";
        String toDescription = finalDescription.replaceAll("[^A-Za-z0-9()\\[\\] ]+", "").length() < 1 ? "No current description available" : finalDescription.replaceAll("[^A-Za-z0-9()\\[\\] ]+", "");
        return "title=" + videoTitleSD(toTitle)
                + ",description=" + videoDescriptionSD(toDescription)
                + ",timeSaved=" + time
                + ".mp4";
    }

    public static List<VideosListSD> getListOfSDVideos() {

        String[] fileList = {};
        List<VideosListSD> finalList = new ArrayList<>();

        File videoFiles = new File(Environment.getExternalStorageDirectory() + "/ShallTV");

        if (videoFiles.isDirectory()) {
            fileList = videoFiles.list();
        }

        for (String aFileList : fileList) {

            if (aFileList.endsWith(".mp4")) {

                String value = aFileList.substring(0, aFileList.length() - 4);

                String[] firstSplit;
                String[][] secondSplit;

                firstSplit = value.split(",");

                secondSplit = new String[firstSplit.length][];

                for (int e = 0; e < firstSplit.length; e++) {
                    secondSplit[e] = firstSplit[e].split("=");
                }

                finalList.add(setVideoSD(secondSplit[0][1]
                        , secondSplit[1][1]
                        , secondSplit[2][1]
                        , Environment.getExternalStorageDirectory() + "/ShallTV/" + aFileList));
            }
        }

        return finalList;
    }

    public static String[] getSavedCategories(Context context, int type) {

        String[] originalList = KeySaver.getStringSavedShare(context, "savedList").split(",");
        String[] secondList = new String[originalList.length];

        for (int e = 0; e < originalList.length; e++) {
            secondList[e] = originalList[e].split("=")[type];
        }

        return secondList;
    }

    private static VideosListSD setVideoSD(String title, String description, String time, String path) {
        return new VideosListSD(title, description, time, path);
    }

    public static String getFormatDate(long timestampInMilliSeconds) {
        Date date = new Date();
        date.setTime(timestampInMilliSeconds);
        return new SimpleDateFormat("MMM d, yyyy").format(date);
    }

    public static String getFormatDate(String timestampInMilliSeconds) {
        Date date = new Date();
        date.setTime(Long.parseLong(timestampInMilliSeconds));
        return new SimpleDateFormat("MMM d, yyyy").format(date);
    }

    public static Bitmap blur(Bitmap image) {
        if (null == image) return null;

        Bitmap outputBitmap = Bitmap.createBitmap(image);
        final RenderScript renderScript = RenderScript.create(GamvesApplication.CONTEXT);
        Allocation tmpIn = Allocation.createFromBitmap(renderScript, image);
        Allocation tmpOut = Allocation.createFromBitmap(renderScript, outputBitmap);

        ScriptIntrinsicBlur theIntrinsic = ScriptIntrinsicBlur.create(renderScript, Element.U8_4(renderScript));
        theIntrinsic.setRadius(25f);
        theIntrinsic.setInput(tmpIn);
        theIntrinsic.forEach(tmpOut);
        tmpOut.copyTo(outputBitmap);
        return outputBitmap;
    }

    public static void deleteVideoOffline(String path) {
        File toDeleteMp4 = new File(path);
        File toDeletePng = new File(path.substring(0, path.length() - 4) + ".png");
        Boolean deletedMp4 = toDeleteMp4.delete();
        Boolean deletedPng = toDeletePng.delete();
    }

    public static String getSavedLanguage(int languageId) {
        if (KeySaver.isExist(GamvesApplication.CONTEXT, "language")) {
            if (languageId == 1) {
                return GamvesApplication.CONTEXT.getResources().getString(R.string.language_1);
            } else if (languageId == 2) {
                return GamvesApplication.CONTEXT.getResources().getString(R.string.language_2);
            } else {
                return "none";
            }
        }
        return "none";
    }

    public static String getSavedLanguageName(int languageId) {
        if (KeySaver.isExist(GamvesApplication.CONTEXT, "language")) {
            if (languageId == 1) {
                return GamvesApplication.CONTEXT.getResources().getString(R.string.language_name_1);
            } else if (languageId == 2) {
                return GamvesApplication.CONTEXT.getResources().getString(R.string.language_name_2);
            } else {
                return null;
            }
        }
        return "";
    }

    public static boolean containsAny(String str, String[] words) {
        for (String word : words) {
            if (str.contains(word)) {
                return true;
            }
        }
        return false;
    }

    public Utils captureBitmap(Activity context) {
        this.context = context;
        mediaRetriever = new MediaMetadataRetriever();
        return this;
    }

    public Utils setSource(String source) {
        Log.e("image", "" + captureSource);
        this.captureSource = source;
        return this;
    }

    public Utils setPosition(int position) {
        this.capturePosition = position;
        return this;
    }

    public Utils setTitle(String title) {
        this.captureTitle = title;
        return this;
    }

    public Utils setView(View view) {
        this.snackView = view;
        return this;
    }

    public void show() {
        new generateBitmap().execute();
    }

    private class generateBitmap extends AsyncTask<Boolean, Boolean, Boolean> {

        private ProgressDialog mProgress;
        private String path;

        @Override
        protected void onPreExecute() {
            mProgress = new ProgressDialog(context);
            mProgress.setMessage(GamvesApplication.CONTEXT.getResources().getString(R.string.loading_dialog_capture_description));
            mProgress.setCancelable(false);
            mProgress.show();
        }

        @Override
        protected Boolean doInBackground(Boolean... params) {
            boolean finish;
            try {
                mediaRetriever.setDataSource(captureSource, new Hashtable<String, String>());
                Bitmap originalBitmap = mediaRetriever.getFrameAtTime(capturePosition);

                Bitmap watermark = BitmapFactory.decodeResource(context.getResources(), R.drawable.watermark);
                Bitmap result = Bitmap.createBitmap(originalBitmap.getWidth(), originalBitmap.getHeight(), originalBitmap.getConfig());
                Canvas canvas = new Canvas(result);
                canvas.drawBitmap(originalBitmap, 0, 0, null);
                canvas.drawBitmap(watermark, originalBitmap.getWidth() - (watermark.getWidth() + 30), originalBitmap.getHeight() - (watermark.getHeight() + 30), null);
                path = MediaStore.Images.Media.insertImage(GamvesApplication.CONTEXT.getContentResolver(), result, captureTitle, null);
                finish = true;
            } catch (Exception e) {
                Snackbar.make(snackView, "Error getting capture. Try again!", Snackbar.LENGTH_SHORT).show();
                finish = false;
            }
            return finish;

        }

        @Override
        protected void onPostExecute(Boolean result) {
            super.onPostExecute(result);
            mProgress.dismiss();

            if (result) {
                Uri uri = Uri.parse(path);
                Intent shareIntent = new Intent();
                shareIntent.setAction(Intent.ACTION_SEND);
                shareIntent.putExtra(Intent.EXTRA_STREAM, uri);
                shareIntent.setType("image/*");
                context.startActivity(shareIntent);
            }

        }


    }

    public Utils setContext(Activity context) {
        this.context = context;
        return this;
    }

    public Utils setPopView(View view) {
        this.popupView = view;
        return this;
    }

    public void showPopup(){
        int[] location = new int[2];
        popupView.getLocationOnScreen(location);

        Point p = new Point();
        p.x = location[0];
        p.y = location[1];

        RelativeLayout viewGroup = (RelativeLayout) context.findViewById(R.id.popup_root);
        LayoutInflater layoutInflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View layout = layoutInflater.inflate(R.layout.dialog_popup, viewGroup);

        SelectableRoundedImageView dialogBg = (SelectableRoundedImageView) layout.findViewById(R.id.dialog_bg);
        dialogBg.setCornerRadiiDP(6, 6, 6, 6);

        final PopupWindow popup = new PopupWindow(layout, ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT, false);
        popup.setBackgroundDrawable(new BitmapDrawable());
        popup.setOutsideTouchable(true);
        popup.setTouchable(true);
        popup.setTouchInterceptor(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                popup.dismiss();
                KeySaver.saveShare(context, "dialog_first", true);
                return true;
            }
        });
        popup.setAnimationStyle(R.style.PopupWindowAnimation);
        popup.showAtLocation(layout, Gravity.NO_GRAVITY, p.x, p.y + popupView.getHeight());
    }

}

