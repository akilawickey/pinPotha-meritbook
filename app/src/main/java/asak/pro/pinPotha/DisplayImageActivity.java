package asak.pro.pinPotha;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;


public class DisplayImageActivity extends Activity {
    Button btnDelete;
    ImageView imageDetail;
    int imageId;
    Bitmap theImage;
    TextView text1;
    String imgdata;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.display);
        btnDelete = (Button) findViewById(R.id.btnDelete);
        imageDetail = (ImageView) findViewById(R.id.imageView1);
        text1 = (TextView) findViewById(R.id.tv);
        /**
         * getting intent data from search and previous screen
         */
        Intent intnt = getIntent();
        theImage = (Bitmap) intnt.getParcelableExtra("imagename");
        imgdata = intnt.getStringExtra("imagedata");
        //text1.setText(imageId);
        imageId = intnt.getIntExtra("imageid", 20);
        Log.d("Image ID:****", String.valueOf(imageId));
        imageDetail.setImageBitmap(theImage);
        text1.setText(imgdata);

        btnDelete.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {


                AlertDialog.Builder alert = new AlertDialog.Builder(DisplayImageActivity.this);
                alert.setMessage("Are you sure ?");
                alert.setCancelable(false);

                alert.setPositiveButton("Yes", new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        // TODO Auto-generated method stub
                        DataBaseHandler db = new DataBaseHandler(
                                DisplayImageActivity.this);
                        /**
                         * Deleting records from database
                         */
                        Log.d("Delete Image: ", "Deleting.....");
                        db.deleteContact(new Contact(imageId));
                        // /after deleting data go to main page
                        Intent i = new Intent(DisplayImageActivity.this,
                                SampleActivity.class);
                        startActivity(i);
                        finish();
                    }
                });
                alert.setNegativeButton("No", new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        // TODO Auto-generated method stub

                    }
                });

                alert.create().show();
                /**
                 * create DatabaseHandler object
                 */

            }
        });

    }

    @Override
    public void onBackPressed() {
        // TODO Auto-generated method stub
        Intent i = new Intent(DisplayImageActivity.this,
                SampleActivity.class);
        startActivity(i);
        finish();

    }

}