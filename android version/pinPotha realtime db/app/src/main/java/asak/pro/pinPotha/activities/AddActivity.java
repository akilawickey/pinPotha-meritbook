package asak.pro.pinPotha.activities;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.github.sundeepk.compactcalendarview.CompactCalendarView;
import com.github.sundeepk.compactcalendarview.domain.Event;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.io.FileNotFoundException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.models.Post;
import asak.pro.pinPotha.models.Utils;

public class AddActivity extends AppCompatActivity implements GoogleApiClient.OnConnectionFailedListener {

    private CompactCalendarView calendarView;
    private TextView txtMonth;
    private EditText edtNote;
    private ProgressDialog mProgressDialog;
    private static final int CAMERA_REQUEST = 1;
    private static final int PICK_FROM_GALLERY = 2;
    private static final int MY_PERMISSIONS_REQUEST_READ_CAMERA = 3;
    private static final int MY_PERMISSIONS_REQUEST_READ_CONTENT = 4 ;
    boolean isCameraOption=true;
    protected GoogleApiClient mGoogleApiClient;
    private Utils mUtils;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add);
        mUtils=new Utils(this,null);
        edtNote=findViewById(R.id.edt_note);
        Button btnAdd=findViewById(R.id.btn_add);
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
        txtMonth.setText(mUtils.formatDate(currentDate,"MMM-yyyy"));
        calendarView.setListener(new CompactCalendarView.CompactCalendarViewListener() {
            @Override
            public void onDayClick(Date dateClicked) {
                Intent intent=new Intent(AddActivity.this,PostListActivity.class);
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
        final DatabaseReference allPostsRef= FirebaseDatabase.getInstance().getReference().child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",","));
        allPostsRef.keepSynced(true);
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
                        mUtils.addNote(mProgressDialog,edtNote,true);
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
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case CAMERA_REQUEST:
                mUtils.postWithPhoto(null,edtNote,mProgressDialog,data,true);
                break;

            case PICK_FROM_GALLERY:
                Uri extras2 = data.getData();
                if (extras2 != null) {
                    final Bitmap selectedImage;
                    try {
                        selectedImage = mUtils.decodeUri(this,extras2,100);
                        mUtils.postWithPhoto(selectedImage,edtNote,mProgressDialog,null,true);
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

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }
}
