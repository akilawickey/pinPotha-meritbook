package org.leafylanka.pinpotha.adapters;

import android.content.Context;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

import org.leafylanka.pinpotha.R;
import org.leafylanka.pinpotha.models.Post;

/**
 * Created by ZarSaeed on 23/09/2018.
 */

public class PostsGridAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private ArrayList<Post> list;
    private Context context;

    public PostsGridAdapter(ArrayList<Post> list,Context context) {
        this.list = list;
        this.context = context;
    }
    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        final View view2 = LayoutInflater.from(context).inflate(R.layout.post_grid_item, parent, false);
        return new PostsGridViewHolder(view2);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        PostsGridViewHolder normalViewHolder = (PostsGridViewHolder) holder;
        normalViewHolder.bindPosts(list.get(position));
    }

    @Override
    public int getItemCount() {
        return list.size();
    }
}
