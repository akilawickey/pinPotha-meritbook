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
 * Created by ZarSaeed on 23/09/2018.
 */

public class PostsGridViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

    private static final int MAX_WIDTH = 200;
    private static final int MAX_HEIGHT = 250;
    TextView textView;
    RoundedImageView imageView;
    Context mContext;
    private Post post;

    public PostsGridViewHolder(View itemView) {
        super(itemView);
        mContext = itemView.getContext();
        textView = itemView.findViewById(R.id.textView);
        imageView = itemView.findViewById(R.id.post_image);
        itemView.setOnClickListener(this);
    }
    public void bindPosts(Post post) {
        imageView.setCornerRadius(10,10,10,10);
        if (post.getPhotoUrl()!=null) Picasso.get().load(post.getPhotoUrl()).placeholder(R.drawable.picture).resize(MAX_WIDTH,MAX_HEIGHT).into(imageView);
        if (post.getNote()!=null) textView.setText(post.getNote());
        this.post = post;
    }

    @Override
    public void onClick(View view) {
        Intent intent=new Intent(mContext, DetailsActivity.class);
        intent.putExtra("POST",post);
        mContext.startActivity(intent);
    }
}
