package gamves.com.gamvesparents.fragment;


import android.app.ProgressDialog;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TimePicker;

import com.getbase.floatingactionbutton.FloatingActionButton;
import com.getbase.floatingactionbutton.FloatingActionsMenu;

import gamves.com.gamvesparents.R;

/**
 * Created by jose on 9/15/17.
 */

public class FragmentFeed extends Fragment {

    private ProgressDialog progressDialog;

    private String Selected_From_Time;

    private Button date_time_set;

    public FragmentFeed() {
        // Required empty public constructor
    }

    private Context context;

    private AlertDialog alertDialog;

    public static final FragmentFeed newInstance() {
        FragmentFeed fragment = new FragmentFeed();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        progressDialog = new ProgressDialog(getActivity());
        progressDialog.setMessage("Please wait.");
        progressDialog.show();

        final View dialogView = View.inflate(getActivity(), R.layout.time_picker_dialod, null);

        alertDialog = new AlertDialog.Builder(getActivity()).create();
        alertDialog.setView(dialogView);

        final TimePicker timePicker = (TimePicker) dialogView.findViewById(R.id.time_picker);

        if (Build.VERSION.SDK_INT >= 23) {
            timePicker.setHour(00);
            timePicker.setMinute(00);
        } else {
            timePicker.setCurrentHour(00);
            timePicker.setCurrentMinute(00);
        }

        dialogView.findViewById(R.id.date_time_set).setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {

                if (Build.VERSION.SDK_INT >= 23) {

                    Selected_From_Time = timePicker.getHour() + ":" + timePicker.getMinute() + ":" + "00";
                } else {
                    Selected_From_Time = timePicker.getCurrentHour() + ":" + timePicker.getCurrentMinute() + ":" + "00";
                }

                alertDialog.dismiss();
            }
        });



        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_vigilant, container, false);

        date_time_set = (Button) view.findViewById(R.id.date_time_set);

        final FloatingActionsMenu menuMultipleActions = (FloatingActionsMenu) view.findViewById(R.id.add_vigilant_task);

        final FloatingActionButton actionA = (FloatingActionButton) view.findViewById(R.id.action_a);
        actionA.setOnClickListener(new View.OnClickListener() {
          @Override
          public void onClick(View view) {
            actionA.setTitle("Action A clicked");
          }
        });


        final FloatingActionButton actionB = (FloatingActionButton) view.findViewById(R.id.action_b);
        actionB.setOnClickListener(new View.OnClickListener() {
          @Override
          public void onClick(View view) {
            actionB.setTitle("Action B clicked");
          }
        });

        /*FloatingActionButton button = (FloatingActionButton) view.findViewById(R.id.add_vigilant_task);
        button.setSize(FloatingActionButton.SIZE_MINI);
        button.setColorNormalResId(R.color.pink);
        button.setColorPressedResId(R.color.pink_pressed);
        button.setIcon(R.drawable.ic_add_white_24dp);
        button.setStrokeVisible(false);

        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v)
            {
                alertDialog.show();
                if (alertDialog.isShowing()) {
                    progressDialog.dismiss();
                }
            }
        });*/

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
    }


}
