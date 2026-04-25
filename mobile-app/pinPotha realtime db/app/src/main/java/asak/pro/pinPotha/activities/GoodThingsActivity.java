package asak.pro.pinPotha.activities;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.adapters.CustomRecyclerView;
import asak.pro.pinPotha.adapters.PostsViewHolder;
import asak.pro.pinPotha.models.Post;

public class GoodThingsActivity extends AppCompatActivity {
    private static final String POSTS_PATH = "posts";

    private DatabaseReference postsReference;
    private ValueEventListener postsListener;
    private final List<Post> allPosts = new ArrayList<>();
    private final List<Post> visiblePosts = new ArrayList<>();
    private GoodThingsAdapter adapter;
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy", Locale.getDefault());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_good_things);
        setTitle("View Good Things");

        CustomRecyclerView recyclerView = findViewById(R.id.recycler_view);
        recyclerView.setEmptyView(findViewById(R.id.empty_view));
        recyclerView.setLayoutManager(new GridLayoutManager(this, 2));
        adapter = new GoodThingsAdapter(visiblePosts);
        recyclerView.setAdapter(adapter);

        EditText searchInput = findViewById(R.id.edt_search);
        searchInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                // No-op.
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                applyFilter(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {
                // No-op.
            }
        });

        subscribePosts();
    }

    private void subscribePosts() {
        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user == null || user.getEmail() == null) {
            finish();
            return;
        }
        postsReference = FirebaseDatabase.getInstance().getReference()
                .child(POSTS_PATH)
                .child(user.getEmail().replace(".", ","));
        postsListener = postsReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                allPosts.clear();
                for (DataSnapshot dateNode : dataSnapshot.getChildren()) {
                    for (DataSnapshot postNode : dateNode.getChildren()) {
                        Post post = postNode.getValue(Post.class);
                        if (post != null) {
                            allPosts.add(post);
                        }
                    }
                }
                Collections.sort(allPosts, new Comparator<Post>() {
                    @Override
                    public int compare(Post left, Post right) {
                        return Long.valueOf(getTimestamp(right)).compareTo(getTimestamp(left));
                    }
                });
                applyFilter("");
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // No-op.
            }
        });
    }

    private void applyFilter(String rawQuery) {
        String query = rawQuery == null ? "" : rawQuery.trim().toLowerCase(Locale.getDefault());
        visiblePosts.clear();
        if (query.isEmpty()) {
            visiblePosts.addAll(allPosts);
        } else {
            for (Post post : allPosts) {
                String note = post.getNote() == null ? "" : post.getNote().toLowerCase(Locale.getDefault());
                String dateText = dateFormat.format(new Date(getTimestamp(post))).toLowerCase(Locale.getDefault());
                if (note.contains(query) || dateText.contains(query)) {
                    visiblePosts.add(post);
                }
            }
        }
        adapter.notifyDataSetChanged();
    }

    private long getTimestamp(Post post) {
        if (post.getTimeStamp() == null || post.getTimeStamp().get("server_time") == null) {
            return Calendar.getInstance().getTimeInMillis();
        }
        Object value = post.getTimeStamp().get("server_time");
        if (value instanceof Long) {
            return (Long) value;
        }
        if (value instanceof String) {
            try {
                return Long.parseLong((String) value);
            } catch (NumberFormatException ignored) {
                return Calendar.getInstance().getTimeInMillis();
            }
        }
        return Calendar.getInstance().getTimeInMillis();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (postsReference != null && postsListener != null) {
            postsReference.removeEventListener(postsListener);
            postsListener = null;
        }
    }

    private static class GoodThingsAdapter extends RecyclerView.Adapter<PostsViewHolder> {
        private final List<Post> posts;

        GoodThingsAdapter(List<Post> posts) {
            this.posts = posts;
        }

        @Override
        public PostsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.home_post_item, parent, false);
            return new PostsViewHolder(view);
        }

        @Override
        public void onBindViewHolder(PostsViewHolder holder, int position) {
            holder.bindPosts(posts.get(position));
        }

        @Override
        public int getItemCount() {
            return posts.size();
        }
    }
}
