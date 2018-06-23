package asak.pro.pinPotha.activities;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.github.sundeepk.compactcalendarview.CompactCalendarView;
import com.github.sundeepk.compactcalendarview.domain.Event;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ServerValue;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.squareup.picasso.Picasso;

import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Random;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.models.Post;
import de.hdodenhof.circleimageview.CircleImageView;

public class CalenderActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener,GoogleApiClient.OnConnectionFailedListener {
    private CompactCalendarView calendarView;
    private TextView txtMonth;
    private EditText edtNote;
    private Button btnAdd;
    private ProgressDialog mProgressDialog;
    private static final int CAMERA_REQUEST = 1;
    private static final int PICK_FROM_GALLERY = 2;
    private static final int MY_PERMISSIONS_REQUEST_READ_CAMERA = 3;
    private static final int MY_PERMISSIONS_REQUEST_READ_CONTENT = 4 ;
    boolean isCameraOption=true;
    protected GoogleApiClient mGoogleApiClient;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_calender);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        edtNote=findViewById(R.id.edt_note);
        btnAdd=findViewById(R.id.btn_add);
        mProgressDialog =new ProgressDialog(this);
        mProgressDialog.setTitle("Loading...");
        mProgressDialog.setMessage("Posting.....");
        btnAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showPostsDialog();
            }
        });
        setTitle(getString(R.string.app_name));
        setUpCalendar();
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        CircleImageView proImage=navigationView.getHeaderView(0).findViewById(R.id.imageView);
        TextView txtName=navigationView.getHeaderView(0).findViewById(R.id.txt_name);
        TextView txtEmail=navigationView.getHeaderView(0).findViewById(R.id.txt_email);
        Picasso.get().load(FirebaseAuth.getInstance().getCurrentUser().getPhotoUrl()).into(proImage);
        txtName.setText(FirebaseAuth.getInstance().getCurrentUser().getDisplayName());
        txtEmail.setText(FirebaseAuth.getInstance().getCurrentUser().getEmail());
        navigationView.setNavigationItemSelectedListener(this);
        getAllPostsTimes();
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(getString(R.string.default_web_client_id))
                .requestEmail()
                .build();
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .enableAutoManage(this /* FragmentActivity */, this /* OnConnectionFailedListener */)
                .addApi(Auth.GOOGLE_SIGN_IN_API, gso)
                .build();
    }

    public void setUpCalendar() {
        calendarView=findViewById(R.id.compactcalendar_view);
        txtMonth=findViewById(R.id.txt_month);
        Date currentDate=new Date(Calendar.getInstance().getTimeInMillis());
        txtMonth.setText(formatDate(currentDate,"MMM-yyyy"));
        calendarView.setListener(new CompactCalendarView.CompactCalendarViewListener() {
            @Override
            public void onDayClick(Date dateClicked) {
                Intent intent=new Intent(CalenderActivity.this,PostListActivity.class);
                intent.putExtra("DATE",formatDate(dateClicked,"dd-MM-yyyy"));
                startActivity(intent);
            }

            @Override
            public void onMonthScroll(Date firstDayOfNewMonth) {
                txtMonth.setText(formatDate(firstDayOfNewMonth,"MMM-yyyy"));
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
                    showToastMessage(getString(R.string.not_posted));
                }
                allPostsRef.removeEventListener(this);
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                showToastMessage(getString(R.string.something_went_wrong));
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

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.nav_camera) {
            isCameraOption=true;
            cameraPermissionCheck();
        } else if (id == R.id.nav_gallery) {
            isCameraOption=false;
            cameraPermissionCheck();
        } else if (id == R.id.nav_sign_out) {
            FirebaseAuth.getInstance().signOut();
            if (mGoogleApiClient!=null) Auth.GoogleSignInApi.signOut(mGoogleApiClient);
            Intent i = new Intent(this,SignInActivity.class);
            startActivity(i);
            finish();
        }

        DrawerLayout drawer =findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    public String formatDate(Date date, String type) {
        SimpleDateFormat simpleDateFormat=new SimpleDateFormat(type);
        return simpleDateFormat.format(date);
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
                // TODO Auto-generated method stub
                if (which == 0) {


                    if (edtNote.getText().toString().trim().length() > 0) {
                        addNote();
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

    /**
     * open camera method
     */
    public void callCamera() {
        Intent cameraIntent = new Intent(
                android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
        cameraIntent.putExtra("crop", "true");
        cameraIntent.putExtra("aspectX", 0);
        cameraIntent.putExtra("aspectY", 0);
        cameraIntent.putExtra("outputX", 500);
        cameraIntent.putExtra("outputY", 400);
        startActivityForResult(cameraIntent, CAMERA_REQUEST);

    }

    /**
     * open gallery method
     */

    public void callGallery() {
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 0);
        intent.putExtra("aspectY", 0);
        intent.putExtra("outputX", 500);
        intent.putExtra("outputY", 400);
        intent.putExtra("return-data", true);
        startActivityForResult(
                Intent.createChooser(intent, "Complete action using"),
                PICK_FROM_GALLERY);

    }

    public void addNote() {
        mProgressDialog.show();
        String date = formatDate(new Date(Calendar.getInstance().getTimeInMillis()),"dd-MM-yyyy");
        Post post=new Post();
        post.setNote(edtNote.getText().toString());
        HashMap<String,Object> timeStamp=new HashMap<>();
        timeStamp.put("server_time",ServerValue.TIMESTAMP);
        post.setTimeStamp(timeStamp);
        DatabaseReference reference= FirebaseDatabase.getInstance().getReference().child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",",")).child(date);
        DatabaseReference reference1=reference.push();
        post.setPostId(reference1.getKey());
        reference1.setValue(post).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                mProgressDialog.dismiss();
                showToastMessage(getString(R.string.posted_successfully));
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                mProgressDialog.dismiss();
                showToastMessage(getString(R.string.something_went_wrong));
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case CAMERA_REQUEST:
                postWithPhoto(data);
                break;

            case PICK_FROM_GALLERY:
                Bundle extras2 = data.getExtras();
                if (extras2 != null) {
                    postWithPhoto(data);
                }
                break;
        }
    }

    protected String getStringName() {
        String SALTCHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        StringBuilder salt = new StringBuilder();
        Random rnd = new Random();
        while (salt.length() < 18) { // length of the random string.
            int index = (int) (rnd.nextFloat() * SALTCHARS.length());
            salt.append(SALTCHARS.charAt(index));
        }
        String saltStr = salt.toString();
        return saltStr;

    }

    public void postWithPhoto(Intent data) {

        Bundle extras = data.getExtras();
        if (extras != null) {
            mProgressDialog.show();
            Bitmap yourImage = extras.getParcelable("data");
            final String date = formatDate(new Date(Calendar.getInstance().getTimeInMillis()),"dd-MM-yyyy");
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            yourImage.compress(Bitmap.CompressFormat.PNG, 100, stream);
            byte imageInByte[] = stream.toByteArray();
            StorageReference reference= FirebaseStorage.getInstance().getReference().child("photos").child(getStringName());
            UploadTask task=reference.putBytes(imageInByte);
            task.addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                @Override
                public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                    String downloadUrl=taskSnapshot.getDownloadUrl().toString();
                    Post post=new Post();
                    HashMap<String,Object> timeStamp=new HashMap<>();
                    timeStamp.put("server_time",ServerValue.TIMESTAMP);
                    post.setTimeStamp(timeStamp);
                    post.setPhotoUrl(downloadUrl);
                    if (!edtNote.getText().toString().equals("")) {
                        post.setNote(edtNote.getText().toString());
                    }
                    DatabaseReference refData=FirebaseDatabase.getInstance().getReference().child("posts")
                            .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",",")).child(date);
                    DatabaseReference reference1=refData.push();
                    post.setPostId(reference1.getKey());
                    reference1.setValue(post);
                    mProgressDialog.dismiss();
                    showToastMessage(getString(R.string.posted_successfully));
                }
            }).addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                    showToastMessage(getString(R.string.something_went_wrong));
                    mProgressDialog.dismiss();
                }
            });

        }
    }

    public void showToastMessage(String message) {
        Toast.makeText(this,message,Toast.LENGTH_SHORT).show();
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
            if (isCameraOption)callCamera();
            else callGallery();
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
                    if (isCameraOption)callCamera();
                    else callGallery();
                }
                break;
            }
        }

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }
}
