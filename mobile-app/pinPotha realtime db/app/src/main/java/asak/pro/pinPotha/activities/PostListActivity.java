package asak.pro.pinPotha.activities;

import android.Manifest;
import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.FileNotFoundException;
import java.util.Calendar;
import java.util.Date;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.models.Utils;

public class PostListActivity extends AppCompatActivity {
    private String date;
    private EditText edtNote;
    private Utils mUtils;
    private ProgressDialog mProgressDialog;
    private boolean isCameraOption = false;
    private TextView selectedDateText;
    private ImageView previewImage;
    private Bitmap selectedImageBitmap;
    private long selectedDateMillis;

    private static final int CAMERA_REQUEST = 1;
    private static final int PICK_FROM_GALLERY = 2;
    private static final int MY_PERMISSIONS_REQUEST_READ_CAMERA = 3;
    private static final int MY_PERMISSIONS_REQUEST_READ_CONTENT = 4;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_list);
        date = getIntent().getStringExtra("MILLIS");
        if (date == null) {
            date = String.valueOf(Calendar.getInstance().getTimeInMillis());
        }
        selectedDateMillis = Long.parseLong(date);
        mUtils = new Utils(this, date);
        setTitle("Add Good Thought");

        selectedDateText = findViewById(R.id.txt_selected_date);
        previewImage = findViewById(R.id.img_preview);
        edtNote = findViewById(R.id.edt_note);
        Button btnGallery = findViewById(R.id.btn_gallery);
        Button btnCamera = findViewById(R.id.btn_camera);
        Button btnPost = findViewById(R.id.btn_post);

        updateSelectedDateView();
        selectedDateText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openDatePicker();
            }
        });

        mProgressDialog = new ProgressDialog(this);
        mProgressDialog.setMessage("Posting...");
        mProgressDialog.setTitle("Loading...");

        btnGallery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                isCameraOption = false;
                storagePermissionCheck();
            }
        });
        btnCamera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                isCameraOption = true;
                cameraPermissionCheck();
            }
        });
        btnPost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                postGoodThought();
            }
        });
    }

    private void updateSelectedDateView() {
        selectedDateText.setText(mUtils.formatDate(new Date(selectedDateMillis), "yyyy-MM-dd"));
    }

    private void openDatePicker() {
        final Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(selectedDateMillis);
        DatePickerDialog pickerDialog = new DatePickerDialog(this,
                new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(android.widget.DatePicker view, int year, int month, int dayOfMonth) {
                        Calendar picked = Calendar.getInstance();
                        picked.set(Calendar.YEAR, year);
                        picked.set(Calendar.MONTH, month);
                        picked.set(Calendar.DAY_OF_MONTH, dayOfMonth);
                        selectedDateMillis = picked.getTimeInMillis();
                        date = String.valueOf(selectedDateMillis);
                        mUtils = new Utils(PostListActivity.this, date);
                        updateSelectedDateView();
                    }
                },
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH));
        pickerDialog.show();
    }

    private void postGoodThought() {
        if (!isNetworkAvailable()) {
            Toast.makeText(this, "No internet connection. Please connect and try again.", Toast.LENGTH_LONG).show();
            return;
        }
        if (selectedImageBitmap != null) {
            mUtils.postWithPhoto(selectedImageBitmap, edtNote, mProgressDialog, null, true);
            return;
        }
        if (edtNote.getText().toString().trim().length() > 0) {
            mUtils.addNote(mProgressDialog, edtNote, true);
        } else {
            edtNote.setError(getString(R.string.please_type_good_work));
            Toast.makeText(this, "Add note or photo before posting", Toast.LENGTH_SHORT).show();
        }
    }

    private boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager =
                (ConnectivityManager) getSystemService(CONNECTIVITY_SERVICE);
        if (connectivityManager == null) {
            return false;
        }
        NetworkInfo activeNetwork = connectivityManager.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnected();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case CAMERA_REQUEST:
                if (data != null && data.getExtras() != null) {
                    selectedImageBitmap = data.getExtras().getParcelable("data");
                    if (selectedImageBitmap != null) {
                        previewImage.setVisibility(View.VISIBLE);
                        previewImage.setImageBitmap(selectedImageBitmap);
                    }
                }
                break;

            case PICK_FROM_GALLERY:
                Uri extras2 = data.getData();
                if (extras2 != null) {
                    final Bitmap selectedImage;
                    try {
                        selectedImage = mUtils.decodeUri(this,extras2,100);
                        selectedImageBitmap = selectedImage;
                        previewImage.setVisibility(View.VISIBLE);
                        previewImage.setImageBitmap(selectedImageBitmap);
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
            mUtils.callCamera();
        }
    }

    public void storagePermissionCheck() {
        String storagePermission = Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
                ? Manifest.permission.READ_MEDIA_IMAGES
                : Manifest.permission.READ_EXTERNAL_STORAGE;
        if (ContextCompat.checkSelfPermission(this,
                storagePermission)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{storagePermission},
                    MY_PERMISSIONS_REQUEST_READ_CONTENT);

        } else {
            mUtils.callGallery();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_READ_CAMERA: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    mUtils.callCamera();

                }
                return;

            }
            case MY_PERMISSIONS_REQUEST_READ_CONTENT: {
                if (grantResults.length>0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    mUtils.callGallery();
                }
                break;
            }
        }

    }

}
