package asak.pro.pinPotha.adapters;

import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.makeramen.roundedimageview.RoundedImageView;
import com.squareup.picasso.Picasso;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.activities.DetailsActivity;
import asak.pro.pinPotha.models.Post;

/**
 * Created by ZarSaeed on 6/23/2018.
 */

public class PostsViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener{
    private static final int MAX_WIDTH = 200;
    private static final int MAX_HEIGHT = 200;

    View mView;
    Context mContext;
    Post post;

    public PostsViewHolder(View itemView) {
        super(itemView);
        mView = itemView;
        mContext = itemView.getContext();
        itemView.setOnClickListener(this);
    }

    public void bindPosts(Post post) {
        RoundedImageView postImageView = mView.findViewById(R.id.post_image);
        postImageView.setCornerRadius(10,0,10,0);
        TextView nameTextView = mView.findViewById(R.id.txt_note);
        this.post=post;
        if (post.getPhotoUrl()!=null) Picasso.get().load(post.getPhotoUrl()).placeholder(R.drawable.picture).resize(MAX_WIDTH,MAX_HEIGHT).into(postImageView);
        if (post.getNote()!=null) nameTextView.setText(post.getNote());

    }

    @Override
    public void onClick(View view) {
        Intent intent=new Intent(mContext, DetailsActivity.class);
        intent.putExtra("POST",post);
        mContext.startActivity(intent);
    }

}
