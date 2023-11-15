package asak.pro.pinPotha.activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.models.Post;

public class DetailsActivity extends AppCompatActivity {
    private Date date;
    private Post post;
    private ImageView postImage;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_details);
        View view=findViewById(R.id.l);
        post= (Post) getIntent().getSerializableExtra("POST");
        date=new Date(Long.parseLong(post.getTimeStamp().get("server_time").toString()));
        setTitle(formatDate(date,"dd-MM-yyyy"));
        postImage=findViewById(R.id.post_img);
        TextView noteTxt=findViewById(R.id.txt_note);
        if (post.getPhotoUrl()!=null) {
            Picasso.get().load(post.getPhotoUrl()).placeholder(R.drawable.picture).into(postImage);
        }else {
            postImage.setVisibility(View.GONE);
            RelativeLayout.LayoutParams params=new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM,0);
            params.addRule(RelativeLayout.CENTER_IN_PARENT,1);
            noteTxt.setLayoutParams(params);
        }
        if (post.getNote()!=null) noteTxt.setText(post.getNote());
        else noteTxt.setVisibility(View.GONE);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.post_menu,menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId()==R.id.action_share) {
            shareTextUrl();
        }
        else if (item.getItemId()==R.id.action_delete) {
            deleteDailog();
        }
        else if (item.getItemId()==android.R.id.home) {
            onBackPressed();
            return true;
        }
        return false;
    }

    public void deleteDailog() {
         new AlertDialog.Builder(this)
                //set icon
                .setIcon(android.R.drawable.ic_delete)
                //set title
                .setTitle("Delete")
                //set message
                .setMessage("Are you sure to delete this?")
                //set positive button
                .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        DatabaseReference reference= FirebaseDatabase.getInstance().getReference().child("posts")
                                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","))
                                .child(formatDate(date,"dd-MM-yyyy"))
                                .child(post.getPostId());
                        reference.keepSynced(true);
                        reference.removeValue().addOnSuccessListener(new OnSuccessListener<Void>() {
                            @Override
                            public void onSuccess(Void aVoid) {
                                if (post.getPhotoUrl() != null) {
                                    StorageReference reference1 = FirebaseStorage.getInstance().getReferenceFromUrl(post.getPhotoUrl());
                                    reference1.delete().addOnSuccessListener(new OnSuccessListener<Void>() {
                                        @Override
                                        public void onSuccess(Void aVoid) {
                                            showToastMessage("Post Deleted");
                                        finish();
                                        }
                                    });
                                } else {
                                    showToastMessage("Post Deleted");
                                    finish();
                                }
                            }
                        });
                    }
                })
                //set negative button
                .setNegativeButton("No", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                      dialogInterface.dismiss();
                    }
                })
                .show();
    }

    public String formatDate(Date date, String type) {
        SimpleDateFormat simpleDateFormat=new SimpleDateFormat(type);
        return simpleDateFormat.format(date);
    }

    public void showToastMessage(String message) {
        Toast.makeText(this,message,Toast.LENGTH_SHORT).show();
    }

    private void shareTextUrl() {
        Intent share = new Intent(android.content.Intent.ACTION_SEND);
        share.setType("text/plain");
        share.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);

        // Add data to the intent, the receiving app will decide
        // what to do with it.
        if (post.getNote()!=null)  share.putExtra(Intent.EXTRA_SUBJECT, post.getNote());
        if (post.getPhotoUrl()!=null)share.putExtra(Intent.EXTRA_TEXT, post.getPhotoUrl());

        startActivity(Intent.createChooser(share, "Share!"));
    }

}
