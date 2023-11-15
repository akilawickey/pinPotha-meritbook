package asak.pro.pinPotha.models;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ServerValue;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Random;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.activities.AddActivity;
import asak.pro.pinPotha.activities.DashboardActivity;

/**
 * Created by ZarSaeed on 6/24/2018.
 */

public class Utils {

    private Activity mActivity;
    private String millis;

    public Utils(Activity activity,String millis) {
        this.mActivity=activity;
        this.millis=millis;
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

    public void postWithPhoto(Bitmap data, final EditText edtNote, final ProgressDialog mProgressDialog, Intent intentData, final boolean isFromAdd) {
        Bundle extras=null;
        if (intentData!=null) extras=intentData.getExtras();
        if (data != null || extras!=null) {
            mProgressDialog.show();
            if (extras!=null) data=extras.getParcelable("data");
            String date="";
            if (millis!=null)date = formatDate(new Date(Long.parseLong(millis)),"dd-MM-yyyy");
            else date = formatDate(new Date(Calendar.getInstance().getTimeInMillis()),"dd-MM-yyyy");
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            data.compress(Bitmap.CompressFormat.PNG, 100, stream);
            byte imageInByte[] = stream.toByteArray();
            StorageReference reference= FirebaseStorage.getInstance().getReference().child("photos").child(getStringName());
            UploadTask task=reference.putBytes(imageInByte);
            final String finalDate = date;
            task.addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                @Override
                public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                    String downloadUrl=taskSnapshot.getUploadSessionUri().toString();
                    Post post=new Post();
                    HashMap<String,Object> timeStamp=new HashMap<>();
                    if (millis!=null)timeStamp.put("server_time",millis);
                    else timeStamp.put("server_time",ServerValue.TIMESTAMP);
                    post.setTimeStamp(timeStamp);
                    post.setPhotoUrl(downloadUrl);
                    if (edtNote != null && !edtNote.getText().toString().equals("")) {
                        post.setNote(edtNote.getText().toString());
                        InputMethodManager imm = (InputMethodManager)mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(edtNote.getWindowToken(), 0);
                        edtNote.setText("");
                    }
                    DatabaseReference refData= FirebaseDatabase.getInstance().getReference().child("posts")
                            .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",",")).child(finalDate);
                    refData.keepSynced(true);
                    DatabaseReference reference1=refData.push();
                    post.setPostId(reference1.getKey());
                    reference1.setValue(post);
                    mProgressDialog.dismiss();
                    showToastMessage(mActivity.getString(R.string.posted_successfully));
                    if (isFromAdd) {
                        Intent intent = new Intent(mActivity, DashboardActivity.class);
                        intent.setFlags( Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        mActivity.startActivity(intent);
                        mActivity.finish();
                    }
                }
            }).addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                    showToastMessage(mActivity.getString(R.string.something_went_wrong));
                    mProgressDialog.dismiss();
                }
            });

        }
    }

    public void showToastMessage(String message) {
        Toast.makeText(mActivity,message,Toast.LENGTH_SHORT).show();
    }

    /**
     * open camera method
     */
    public void callCamera() {
        int CAMERA_REQUEST=1;
        Intent cameraIntent = new Intent(
                android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
        /*cameraIntent.putExtra("crop", "true");
        cameraIntent.putExtra("aspectX", 0);
        cameraIntent.putExtra("aspectY", 0);
        cameraIntent.putExtra("outputX", 500);
        cameraIntent.putExtra("outputY", 400);*/
        mActivity.startActivityForResult(cameraIntent, CAMERA_REQUEST);

    }

    /**
     * open gallery method
     */

    public void callGallery() {
        int PICK_FROM_GALLERY=2;
        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
       /* intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 0);
        intent.putExtra("aspectY", 0);
        intent.putExtra("outputX", 500);
        intent.putExtra("outputY", 400);
        intent.putExtra("return-data", true);*/
        mActivity.startActivityForResult(
                Intent.createChooser(intent, "Complete action using"),
                PICK_FROM_GALLERY);

    }

    public void addNote(final ProgressDialog mProgressDialog, final EditText edtNote, final boolean isFromAdd) {
        mProgressDialog.show();
        String date="";
        if (millis!=null)date = formatDate(new Date(Long.parseLong(millis)),"dd-MM-yyyy");
        else date = formatDate(new Date(Calendar.getInstance().getTimeInMillis()),"dd-MM-yyyy");
        Post post=new Post();
        post.setNote(edtNote.getText().toString());

        HashMap<String,Object> timeStamp=new HashMap<>();
        if (millis!=null)timeStamp.put("server_time",millis);
        else timeStamp.put("server_time",ServerValue.TIMESTAMP);
        post.setTimeStamp(timeStamp);
        DatabaseReference reference= FirebaseDatabase.getInstance().getReference().child("posts")
                .child(FirebaseAuth.getInstance().getCurrentUser().getEmail().replace(".",",")).child(date);
        DatabaseReference reference1=reference.push();
        post.setPostId(reference1.getKey());
        reference1.setValue(post).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                mProgressDialog.dismiss();
                showToastMessage(mActivity.getString(R.string.posted_successfully));
                InputMethodManager imm = (InputMethodManager)mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(edtNote.getWindowToken(), 0);
                edtNote.setText("");
                if (isFromAdd) {
                    Intent intent = new Intent(mActivity, AddActivity.class);
                    intent.setFlags( Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NO_HISTORY);
                    mActivity.startActivity(intent);
                   mActivity.finish();
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                mProgressDialog.dismiss();
                showToastMessage(mActivity.getString(R.string.something_went_wrong));
            }
        });
    }

    public String formatDate(Date date, String type) {
        SimpleDateFormat simpleDateFormat=new SimpleDateFormat(type);
        return simpleDateFormat.format(date);
    }

    public static Bitmap decodeUri(Context c, Uri uri, final int requiredSize)
            throws FileNotFoundException {

        BitmapFactory.Options o = new BitmapFactory.Options();
        o.inJustDecodeBounds = true;
        BitmapFactory.decodeStream(c.getContentResolver().openInputStream(uri), null, o);

        int width_tmp = o.outWidth
                , height_tmp = o.outHeight;
        int scale = 1;

        while(true) {
            if(width_tmp / 2 < requiredSize || height_tmp / 2 < requiredSize)
                break;
            width_tmp /= 2;
            height_tmp /= 2;
            scale *= 2;
        }

        BitmapFactory.Options o2 = new BitmapFactory.Options();
        o2.inSampleSize = scale;
        return BitmapFactory.decodeStream(c.getContentResolver().openInputStream(uri), null, o2);
    }
}
