package asak.pro.pinPotha.activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.support.design.widget.BottomNavigationView;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

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
    private TextView titleTxt;
    private TextView noteTxt;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_details);
        post= (Post) getIntent().getSerializableExtra("POST");
        date=new Date(Long.parseLong(post.getTimeStamp().get("server_time").toString()));
        titleTxt = findViewById(R.id.txt_title);
        TextView dateTxt = findViewById(R.id.txt_date);
        updateTitle(post.getNote());
        dateTxt.setText(formatDate(date,"dd-MM-yyyy"));
        if (getSupportActionBar() != null) {
            getSupportActionBar().setSubtitle(formatDate(date,"dd-MM-yyyy"));
        }
        postImage=findViewById(R.id.post_img);
        noteTxt=findViewById(R.id.txt_note);
        if (post.getPhotoUrl()!=null) {
            Picasso.get().load(post.getPhotoUrl()).placeholder(R.drawable.picture).into(postImage);
            updateNoteText(post.getNote());
        }else {
            postImage.setVisibility(View.GONE);
            updateNoteText(post.getNote());
        }
        setUpBottomNavigation();
    }

    private void setUpBottomNavigation() {
        BottomNavigationView bottomNavigationView = findViewById(R.id.bottom_navigation);
        bottomNavigationView.setSelectedItemId(R.id.nav_view);
        bottomNavigationView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(android.view.MenuItem item) {
                int itemId = item.getItemId();
                if (itemId == R.id.nav_view) {
                    startActivity(new Intent(DetailsActivity.this, GoodThingsActivity.class));
                    return true;
                }
                if (itemId == R.id.nav_home) {
                    Intent intent = new Intent(DetailsActivity.this, DashboardActivity.class);
                    intent.putExtra("MILLIS", String.valueOf(date.getTime()));
                    startActivity(intent);
                    return true;
                }
                if (itemId == R.id.nav_add) {
                    Intent intent = new Intent(DetailsActivity.this, PostListActivity.class);
                    intent.putExtra("MILLIS", String.valueOf(date.getTime()));
                    startActivity(intent);
                    return true;
                }
                if (itemId == R.id.nav_settings) {
                    startActivity(new Intent(DetailsActivity.this, SettingsActivity.class));
                    return true;
                }
                return false;
            }
        });
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
        else if (item.getItemId()==R.id.action_edit_note) {
            showEditNoteDialog();
            return true;
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

    private void showEditNoteDialog() {
        final EditText input = new EditText(this);
        input.setHint("Update good thing note");
        if (post.getNote() != null) {
            input.setText(post.getNote());
            input.setSelection(input.getText().length());
        }
        new AlertDialog.Builder(this)
                .setTitle("Edit Note")
                .setView(input)
                .setPositiveButton("Save", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        String newNote = input.getText().toString().trim();
                        if (newNote.equals("")) {
                            showToastMessage("Note cannot be empty");
                            return;
                        }
                        getPostReference().child("note").setValue(newNote)
                                .addOnSuccessListener(new OnSuccessListener<Void>() {
                                    @Override
                                    public void onSuccess(Void aVoid) {
                                        post.setNote(newNote);
                                        updateTitle(newNote);
                                        updateNoteText(newNote);
                                        showToastMessage("Note updated");
                                    }
                                });
                    }
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private DatabaseReference getPostReference() {
        return FirebaseDatabase.getInstance().getReference().child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","))
                .child(formatDate(date,"dd-MM-yyyy"))
                .child(post.getPostId());
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

    private void updateTitle(String note) {
        if (note != null && !note.trim().equals("")) {
            setTitle(note);
            titleTxt.setText(note);
        } else {
            setTitle("Good Thing");
            titleTxt.setText("Good Thing");
        }
    }

    private void updateNoteText(String note) {
        if (note != null && !note.trim().equals("")) {
            noteTxt.setText(note);
            noteTxt.setVisibility(View.VISIBLE);
        } else {
            noteTxt.setVisibility(View.GONE);
        }
    }

}
