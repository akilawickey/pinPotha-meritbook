package asak.pro.pinPotha;


import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;

public class about extends Activity {
    android.widget.Button btnDelete;
    ImageView imageDetail;
    int imageId;
    Bitmap theImage;
    TextView text1;
    String imgdata;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.about);

        text1 = (TextView) findViewById(R.id.tv);
        /**
         * getting intent data from search and previous screen
         */
    }
    @Override
    public void onBackPressed() {
        // TODO Auto-generated method stub
        Intent i = new Intent(about.this,
                SampleActivity.class);
        startActivity(i);
        finish();
    }

}