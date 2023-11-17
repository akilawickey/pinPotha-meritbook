package org.leafylanka.pinpotha.activities;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.github.sundeepk.compactcalendarview.CompactCalendarView;
import com.github.sundeepk.compactcalendarview.domain.Event;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.navigation.NavigationView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;
import com.squareup.picasso.Picasso;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;

import org.leafylanka.pinpotha.R;
import org.leafylanka.pinpotha.adapters.PostsGridAdapter;
import org.leafylanka.pinpotha.models.Post;
import org.leafylanka.pinpotha.models.Utils;
import de.hdodenhof.circleimageview.CircleImageView;

public class DashboardActivity extends AppCompatActivity {
    private CompactCalendarView calendarView;
    private TextView txtMonth;
    private EditText edtNote;
    private ProgressDialog mProgressDialog;
    private EditText edtSearchNote;
    private static final int CAMERA_REQUEST = 1;
    private static final int PICK_FROM_GALLERY = 2;
    private static final int MY_PERMISSIONS_REQUEST_READ_CAMERA = 3;
    private static final int MY_PERMISSIONS_REQUEST_READ_CONTENT = 4 ;
    boolean isCameraOption=true;
    private Utils mUtils;
    private TextView txtEmpty;
    private ProgressBar progressBar;
    private PostsGridAdapter adapter;
    private ArrayList<Post> postList;
    private GridLayoutManager mLayoutManager;
    private Query query;
    private ValueEventListener listener;
    private FloatingActionButton floatingActionButton;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);
        Toolbar toolbar =findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        mUtils = new Utils(this,null);
        mProgressDialog =new ProgressDialog(this);
        mProgressDialog.setTitle("Loading...");
        mProgressDialog.setMessage("Posting.....");
        setTitle(getString(R.string.app_name));
        final RecyclerView mRecyclerView = findViewById(R.id.recycler_view);
        progressBar = findViewById(R.id.progressBar);
        txtEmpty = findViewById(R.id.txt_empty);
        edtSearchNote = findViewById(R.id.edt_search_admin);
        floatingActionButton = findViewById(R.id.fab);
        progressBar.setVisibility(View.VISIBLE);
        postList = new ArrayList<>();

        query = FirebaseDatabase.getInstance().getReference().child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","));
        query.keepSynced(true);
        listener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                postList.clear();
                if (dataSnapshot.getValue() != null) {
                    for (DataSnapshot dataSnapshot1 : dataSnapshot.getChildren()) {
                        for (DataSnapshot dataSnapshot2 : dataSnapshot1.getChildren()) {
                            Post post = dataSnapshot2.getValue(Post.class);
                            postList.add(post);
                        }
                    }
                    Collections.reverse(postList);
                    txtEmpty.setVisibility(View.GONE);
                    edtSearchNote.setVisibility(View.VISIBLE);
                } else {
                    txtEmpty.setVisibility(View.VISIBLE);
                    edtSearchNote.setVisibility(View.GONE);
                }
                progressBar.setVisibility(View.GONE);
                adapter = new PostsGridAdapter(postList,DashboardActivity.this);
                mLayoutManager = new GridLayoutManager(DashboardActivity.this, 2, LinearLayoutManager.VERTICAL, false);
                mRecyclerView.setAdapter(adapter);
                mRecyclerView.setLayoutManager(mLayoutManager);
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                Log.e("tag",""+databaseError.getMessage());
                progressBar.setVisibility(View.GONE);
            }
        };
        query.addValueEventListener(listener);
        floatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(DashboardActivity.this, AddActivity.class);
                startActivity(intent);
            }
        });

        NavigationView navigationView =findViewById(R.id.nav_view);
        CircleImageView proImage=navigationView.getHeaderView(0).findViewById(R.id.imageView);
        TextView txtName=navigationView.getHeaderView(0).findViewById(R.id.txt_name);
        TextView txtEmail=navigationView.getHeaderView(0).findViewById(R.id.txt_email);
        Picasso.get().load(FirebaseAuth.getInstance().getCurrentUser().getPhotoUrl()).into(proImage);
        txtName.setText(FirebaseAuth.getInstance().getCurrentUser().getDisplayName());
        txtEmail.setText(FirebaseAuth.getInstance().getCurrentUser().getEmail());

        edtSearchNote.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                if (!charSequence.toString().equals("")) {
                    ArrayList<Post> searchPostList = new ArrayList<>();
                    searchPostList.clear();
                    for (int j = 0; j < postList.size(); j++) {
                        if (postList.get(j).getNote()!=null) {
                            Log.e("char",charSequence.toString());
                            Log.e("tag",postList.get(j).getNote());
                            if (postList.get(j).getNote().toLowerCase().trim().contains(charSequence.toString().toLowerCase())) {
                                searchPostList.add(postList.get(j));
                            }
                        }
                    }
                    mRecyclerView.setAdapter(null);
                    adapter = new PostsGridAdapter(searchPostList,DashboardActivity.this);
                    mRecyclerView.setAdapter(adapter);
                    mRecyclerView.setLayoutManager(mLayoutManager);
                }
                else {
                    mRecyclerView.setAdapter(null);
                    adapter = new PostsGridAdapter(postList,DashboardActivity.this);
                    mRecyclerView.setAdapter(adapter);
                    mRecyclerView.setLayoutManager(mLayoutManager);
                }
            }

            @Override
            public void afterTextChanged(Editable editable) {

            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        query.removeEventListener(listener);
    }

    @Override
    protected void onResume() {
        super.onResume();
        query.addValueEventListener(listener);
    }

    public void setUpCalendar() {
        calendarView=findViewById(R.id.compactcalendar_view);
        txtMonth=findViewById(R.id.txt_month);
        Date currentDate=new Date(Calendar.getInstance().getTimeInMillis());
        txtMonth.setText(mUtils.formatDate(currentDate,"MMM-yyyy"));
        calendarView.setListener(new CompactCalendarView.CompactCalendarViewListener() {
            @Override
            public void onDayClick(Date dateClicked) {
                Intent intent=new Intent(DashboardActivity.this,PostListActivity.class);
                intent.putExtra("MILLIS",""+dateClicked.getTime());
                startActivity(intent);
            }

            @Override
            public void onMonthScroll(Date firstDayOfNewMonth) {
                txtMonth.setText(mUtils.formatDate(firstDayOfNewMonth,"MMM-yyyy"));
            }
        });
    }

    public void getAllPostsTimes() {
        final DatabaseReference allPostsRef=FirebaseDatabase.getInstance().getReference().child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","));
        ValueEventListener listener=new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (dataSnapshot.getValue()!=null) {
                    for (DataSnapshot snapshot:dataSnapshot.getChildren()) {
                        for (DataSnapshot snapshot1:snapshot.getChildren()) {
                            if (snapshot1.getValue()!=null) {
                                Post post=snapshot1.getValue(Post.class);
                                HashMap<String,Object> timeStamp=post.getTimeStamp();
                                Log.e("tag",timeStamp.get("server_time").toString());
                                Event event = new Event(getResources().getColor(R.color.calendarSelectedDay), Long.parseLong(timeStamp.get("server_time").toString()));
                                calendarView.addEvent(event);
                            }
                        }
                    }
                }
                else {
                    mUtils.showToastMessage(getString(R.string.not_posted));
                }
                allPostsRef.removeEventListener(this);
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                mUtils.showToastMessage(getString(R.string.something_went_wrong));
            }
        };
        allPostsRef.addValueEventListener(listener);
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer =  findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    public void showPostsDialog() {
        final String[] option = new String[]{"Take a Note", "Get From Camera",
                "Get From the Phone"};
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.select_dialog_item, option);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setTitle("Select Option");
        builder.setAdapter(adapter, new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {


                    if (edtNote.getText().toString().trim().length() > 0) {
                        mUtils.addNote(mProgressDialog,edtNote,false);
                    } else {
                        /*AlertDialog alert = new AlertDialog.Builder(DashboardActivity.this).create();
                        alert.setMessage("Please Type Some good work !!!");
                        alert.show();*/
                        edtNote.setError(getString(R.string.please_type_good_work));
                    }
                }

                if (which == 1) {
                    isCameraOption=true;
                    cameraPermissionCheck();
                }
                if (which == 2) {
                    isCameraOption=false;
                    cameraPermissionCheck();
                }

            }

        });
        builder.show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case CAMERA_REQUEST:
                mUtils.postWithPhoto(null, null, mProgressDialog, data, false);
                break;

            case PICK_FROM_GALLERY:
                Uri extras2 = data.getData();
                if (extras2 != null) {
                    final Bitmap selectedImage;
                    try {
                        selectedImage = mUtils.decodeUri(this, extras2, 100);
                        mUtils.postWithPhoto(selectedImage, null, mProgressDialog, null, false);
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                    }
                }
                break;
        }
    }

    public void cameraPermissionCheck() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.CAMERA},
                    MY_PERMISSIONS_REQUEST_READ_CAMERA);
        } else {
            storagePermissionCheck();
        }
    }

    public void storagePermissionCheck() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                    MY_PERMISSIONS_REQUEST_READ_CONTENT);

        } else {
            if (isCameraOption)mUtils.callCamera();
            else mUtils.callGallery();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_READ_CAMERA: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    storagePermissionCheck();

                }
                return;

            }
            case MY_PERMISSIONS_REQUEST_READ_CONTENT: {
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (isCameraOption) mUtils.callCamera();
                    else mUtils.callGallery();
                }
                break;
            }
        }
    }
}
