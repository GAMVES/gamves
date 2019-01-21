package gamves.com.gamvesparents.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import gamves.com.gamvesparents.R;
import gamves.com.gamvesparents.activities.RegisterActivity;

/**
 * Created by jose on 9/15/17.
 */

public class FragmentHome extends Fragment {

    private Button btn_link_signup, btn_login;

    public FragmentHome() {
        // Required empty public constructor
    }

    public static final FragmentHome newInstance() {
        FragmentHome fragment = new FragmentHome();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_home, container, false);

        btn_login = (Button) view.findViewById(R.id.btn_login);

        btn_login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(getContext(), RegisterActivity.class);
                startActivity(i);
            }
        });

        btn_link_signup = (Button) view.findViewById(R.id.btn_link_signup);

        btn_link_signup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(getContext(), RegisterActivity.class);
                startActivity(i);
            }
        });


        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
    }


}
