package asak.pro.pinPotha.adapters;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.google.firebase.database.Query;

import asak.pro.pinPotha.models.Post;

/**
 * Created by ZarSaeed on 6/23/2018.
 */

public class PostsAdapter extends FirebaseRecyclerAdapter<Post,PostsViewHolder> {
    /**
     * @param modelClass      Firebase will marshall the data at a location into
     *                        an instance of a class that you provide
     * @param modelLayout     This is the layout used to represent a single item in the list.
     *                        You will be responsible for populating an instance of the corresponding
     *                        view with the data from an instance of modelClass.
     * @param viewHolderClass The class that hold references to all sub-views in an instance modelLayout.
     * @param ref             The Firebase location to watch for data changes. Can also be a slice of a location,
     *                        using some combination of {@code limit()}, {@code startAt()}, and {@code endAt()}.
     */
    public PostsAdapter(Class<Post> modelClass, int modelLayout, Class<PostsViewHolder> viewHolderClass, Query ref) {
        super(modelClass, modelLayout, viewHolderClass, ref);
    }

    @Override
    protected void populateViewHolder(PostsViewHolder viewHolder, Post model, int position) {
        viewHolder.bindPosts(model);
    }
}
