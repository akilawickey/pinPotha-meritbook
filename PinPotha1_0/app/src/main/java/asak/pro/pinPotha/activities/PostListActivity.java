package asak.pro.pinPotha.activities;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.adapters.CustomRecyclerView;
import asak.pro.pinPotha.adapters.PostsAdapter;
import asak.pro.pinPotha.adapters.PostsViewHolder;
import asak.pro.pinPotha.models.Post;

public class PostListActivity extends AppCompatActivity {
    private FirebaseRecyclerAdapter adapter;
    private CustomRecyclerView recyclerView;
    private String date;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_list);
        date=getIntent().getStringExtra("DATE");
        setTitle(date);
        recyclerView=findViewById(R.id.recycler_view);
        recyclerView.setEmptyView(findViewById(R.id.empty_view));
        setUpPostList();
    }

    private void setUpPostList() {
        DatabaseReference reference= FirebaseDatabase.getInstance().getReference()
                .child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","))
                .child(date);
        adapter=new PostsAdapter(Post.class,R.layout.post_list_item,PostsViewHolder.class,reference);
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setAdapter(adapter);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        adapter.cleanup();
    }

}
