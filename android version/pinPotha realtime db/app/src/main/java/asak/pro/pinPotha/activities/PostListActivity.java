package asak.pro.pinPotha.activities;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Date;
import asak.pro.pinPotha.R;
import asak.pro.pinPotha.adapters.CustomRecyclerView;
import asak.pro.pinPotha.adapters.PostsAdapter;
import asak.pro.pinPotha.adapters.PostsViewHolder;
import asak.pro.pinPotha.models.Post;
import asak.pro.pinPotha.models.Utils;

public class PostListActivity extends AppCompatActivity {
    private FirebaseRecyclerAdapter adapter;
    private CustomRecyclerView recyclerView;
    private String date;
    private boolean isFabOpen=false;
    private FloatingActionButton fab;
    private Animation rotate_backward,rotate_forward;
    private RelativeLayout addLayout;
    private EditText edtNote;
    private Utils mUtils;
    private ProgressDialog mProgressDialog;
    private boolean isCameraOption=false;
    private static final int CAMERA_REQUEST = 1;
    private static final int PICK_FROM_GALLERY = 2;
    private static final int MY_PERMISSIONS_REQUEST_READ_CAMERA = 3;
    private static final int MY_PERMISSIONS_REQUEST_READ_CONTENT = 4 ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_list);
        date=getIntent().getStringExtra("MILLIS");
        mUtils=new Utils(this,date);
        setTitle(mUtils.formatDate(new Date(Long.parseLong(date)),"dd-MM-yyyy"));
        recyclerView=findViewById(R.id.recycler_view);
        recyclerView.setEmptyView(findViewById(R.id.empty_view));
        setUpPostList();
        addLayout=findViewById(R.id.r);
        fab=findViewById(R.id.fab);
        rotate_forward = AnimationUtils.loadAnimation(this,R.anim.rotate_forward);
        rotate_backward = AnimationUtils.loadAnimation(this,R.anim.rotate_backward);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                animateFAB();
            }
        });
        edtNote=findViewById(R.id.edt_note);
        Button btnAdd=findViewById(R.id.btn_add);
        mProgressDialog=new ProgressDialog(this);
        mProgressDialog.setMessage("Posting...");
        mProgressDialog.setTitle("Loading...");
        btnAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPostsDialog();
            }
        });
    }

    private void setUpPostList() {
        DatabaseReference reference= FirebaseDatabase.getInstance().getReference()
                .child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","))
                .child(mUtils.formatDate(new Date(Long.parseLong(date)),"dd-MM-yyyy"));
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

    public void animateFAB(){

        if(isFabOpen){
            fab.startAnimation(rotate_backward);
            addLayout.setVisibility(View.GONE);
            isFabOpen = false;
        } else {
            fab.startAnimation(rotate_forward);
            addLayout.setVisibility(View.VISIBLE);
            isFabOpen = true;
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
                        mUtils.addNote(mProgressDialog,edtNote);
                    } else {
                        /*AlertDialog alert = new AlertDialog.Builder(CalenderActivity.this).create();
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
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case CAMERA_REQUEST:
                mUtils.postWithPhoto(null,edtNote,mProgressDialog,data);
                break;

            case PICK_FROM_GALLERY:
                Uri extras2 = data.getData();
                if (extras2 != null) {
                    final Bitmap selectedImage;
                    try {
                        selectedImage = mUtils.decodeUri(this,extras2,100);
                        mUtils.postWithPhoto(selectedImage,edtNote,mProgressDialog,null);
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
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_READ_CAMERA: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    storagePermissionCheck();

                }
                return;

            }
            case MY_PERMISSIONS_REQUEST_READ_CONTENT: {
                if (grantResults.length>0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (isCameraOption)mUtils.callCamera();
                    else mUtils.callGallery();
                }
                break;
            }
        }

    }

}
