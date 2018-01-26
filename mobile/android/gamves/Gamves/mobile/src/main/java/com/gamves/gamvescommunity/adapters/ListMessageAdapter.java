package com.gamves.gamvescommunity.adapters;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v7.widget.RecyclerView;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.gamves.gamvescommunity.GamvesApplication;
import com.gamves.gamvescommunity.VideoDetail;
import com.gamves.gamvescommunity.model.Consersation;

import java.util.HashMap;

import com.gamves.gamvescommunity.interfaces.*;

import com.gamves.gamvescommunity.R;
import com.parse.ParseUser;

/**
 * Created by jose on 9/13/17.
 */

public class ListMessageAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private Context context;
    private Consersation consersation;

    public ListMessageAdapter(Context context, Consersation consersation) {
        this.context = context;
        this.consersation = consersation;
    }


    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        if (viewType == VideoDetail.VIEW_TYPE_FRIEND_MESSAGE) {
            View view = LayoutInflater.from(context).inflate(R.layout.rc_item_message_friend, parent, false);
            return new ItemMessageFriendHolder(view);
        } else if (viewType == VideoDetail.VIEW_TYPE_USER_MESSAGE) {
            View view = LayoutInflater.from(context).inflate(R.layout.rc_item_message_user, parent, false);
            return new ItemMessageUserHolder(view);
        }
        return null;
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {

        if (holder instanceof ItemMessageFriendHolder)
        {
            ((ItemMessageFriendHolder) holder).txtContent.setText(consersation.getListMessageData().get(position).message);

                /*Bitmap currentAvata = bitmapAvata.get(consersation.getListMessageData().get(position).idSender);

                if (currentAvata != null) {
                    ((ItemMessageFriendHolder) holder).avata.setImageBitmap(currentAvata);
                } else {
                    final String id = consersation.getListMessageData().get(position).idSender;
                    if(bitmapAvataDB.get(id) == null){
                        bitmapAvataDB.put(id, FirebaseDatabase.getInstance().getReference().child("user/" + id + "/avata"));
                        bitmapAvataDB.get(id).addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override
                            public void onDataChange(DataSnapshot dataSnapshot) {
                                if (dataSnapshot.getValue() != null) {
                                    String avataStr = (String) dataSnapshot.getValue();
                                    if(!avataStr.equals(StaticConfig.STR_DEFAULT_BASE64)) {
                                        byte[] decodedString = Base64.decode(avataStr, Base64.DEFAULT);
                                        ChatActivity.bitmapAvataFriend.put(id, BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length));
                                    }else{
                                        ChatActivity.bitmapAvataFriend.put(id, BitmapFactory.decodeResource(context.getResources(), R.drawable.default_avata));
                                    }
                                    notifyDataSetChanged();
                                }
                            }

                            @Override
                            public void onCancelled(DatabaseError databaseError) {

                            }
                        });
                    }
                }*/

        } else if (holder instanceof ItemMessageUserHolder) {
            ((ItemMessageUserHolder) holder).txtContent.setText(consersation.getListMessageData().get(position).message);
            //if (bitmapAvataUser != null) {
            //    ((ItemMessageUserHolder) holder).avata.setImageBitmap(bitmapAvataUser);
            //}
        }
    }

    @Override
    public int getItemViewType(int position) {
        String userId =  ParseUser.getCurrentUser().getObjectId();
        int type = consersation.getListMessageData().get(position).userId.equals(userId) ? VideoDetail.VIEW_TYPE_USER_MESSAGE : VideoDetail.VIEW_TYPE_FRIEND_MESSAGE;
        return type;
    }

    @Override
    public int getItemCount() {
        int count = consersation.getListMessageData().size();
        return count;
    }
}

