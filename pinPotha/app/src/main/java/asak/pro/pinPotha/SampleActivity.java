package asak.pro.pinPotha;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.text.format.Time;
import android.util.Log;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;

import asak.pro.pinPotha.R;

public class SampleActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {


    android.widget.Button addImage;
    ArrayList<Contact> imageArry = new ArrayList<Contact>();
    ContactImageAdapter imageAdapter;
    private static final int CAMERA_REQUEST = 1;
    private static final int PICK_FROM_GALLERY = 2;
    private static final int NOTE_REQUEST = 0;
    Time today = new Time(Time.getCurrentTimezone());
    ListView dataList;
    byte[] imageName;
    int imageId;
    Bitmap theImage;
    DataBaseHandler db;
    private EditText et;
    String imgdata;
    private DrawerLayout mDrawerLayout;
    private ActionBarDrawerToggle drawerToggle;

    private ListView mDrawerList;
    ViewPager pager;
    private String titles[] = new String[]{"Sample Tab 1", "Sample Tab 2", "Sample Tab 3", "Sample Tab 4"
            , "Sample Tab 5", "Sample Tab 6", "Sample Tab 7", "Sample Tab 8"};
    private Toolbar toolbar;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);


        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        dataList = (ListView) findViewById(R.id.list);
        et = (EditText) findViewById(R.id.ed1);

        /**
         * create DatabaseHandler object
         */
        db = new DataBaseHandler(this);
        /**
         * Reading and getting all records from database
         */
        List<Contact> contacts = db.getAllContacts();
        for (Contact cn : contacts) {
            String log = "ID:" + cn.getID() + " Name: " + cn.getName()
                    + " ,Image: " + cn.getImage();

            // Writing Contacts to log
            Log.d("Result: ", log);
            // add contacts data in arrayList
            imageArry.add(cn);

        }
        /**
         * Set Data base Item into listview
         */
        imageAdapter = new ContactImageAdapter(this, R.layout.screen_list,
                imageArry);
        dataList.setAdapter(imageAdapter);
        /**
         * go to next activity for detail image
         */
        dataList.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View v,
                                    final int position, long id) {
                imageName = imageArry.get(position).getImage();
                imageId = imageArry.get(position).getID();
                imgdata = imageArry.get(position).getName();
                Log.d("Before Send:****", imageName + "-" + imageId+ "-" + imgdata);
                // convert byte to bitmap
                ByteArrayInputStream imageStream = new ByteArrayInputStream(
                        imageName);
                theImage = BitmapFactory.decodeStream(imageStream);
                Intent intent = new Intent(SampleActivity.this,
                        DisplayImageActivity.class);
                intent.putExtra("imagename", theImage);
                intent.putExtra("imageid", imageId);
                intent.putExtra("imagedata", imgdata);
                startActivity(intent);
                finish();
            }
        });
        /**
         * open dialog for choose camera/gallery
         */

        final String[] option = new String[] {"Take a Note", "Get From Camera",
                "Get From the Phone" };
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.select_dialog_item, option);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setTitle("Select Option");
        builder.setAdapter(adapter, new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                // TODO Auto-generated method stub
                Log.e("Selected Item", String.valueOf(which));
                if (which == 0) {


                    if (et.getText().toString().trim().length() > 0) {
                        addNote();
                    } else {
                        AlertDialog alert = new AlertDialog.Builder(SampleActivity.this).create();
                        alert.setMessage("Please Type Some good work !!!");
                        alert.show();
                    }
                }

                if (which == 1) {
                    callCamera();
                }
                if (which == 2) {
                    callGallery();
                }

            }

        });
        final AlertDialog dialog = builder.create();

        addImage = (Button) findViewById(R.id.btnAdd);

        addImage.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                dialog.show();
            }
        });


        /////////////////////////////////////////////////////////////
        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        mDrawerList = (ListView) findViewById(R.id.navdrawer);
//        toolbar = (Toolbar) findViewById(R.id.toolbar);
//        if (toolbar != null) {
//            setSupportActionBar(toolbar);
//            toolbar.setNavigationIcon(R.drawable.ic_ab_drawer);
//        }
        pager = (ViewPager) findViewById(R.id.viewpager);
        //  slidingTabLayout = (SlidingTabLayout) findViewById(R.id.sliding_tabs);
       // pager.setAdapter(new ViewPagerAdapter(getSupportFragmentManager(), titles));

        // slidingTabLayout.setViewPager(pager);
        //   slidingTabLayout.setCustomTabColorizer(new SlidingTabLayout.TabColorizer() {
//            @Override
//            public int getIndicatorColor(int position) {
//                return Color.WHITE;
//            }
//        });
        drawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout, toolbar, R.string.app_name, R.string.app_name);
        mDrawerLayout.setDrawerListener(drawerToggle);
        String[] values = new String[]{
                "Help", "About pinpotha", "Rate this App"
        };

    }

    @Override
    protected void onDestroy() {

        super.onDestroy();

    }
//    @Override
//    public void onBackPressed() {
//        // TODO Auto-generated method stub
//        createDialog();
//    }


    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        // Inflate the menu; this adds items to the action bar if it is present.
//        getMenuInflater().inflate(R.menu.main, menu);
//        return true;
//    }

    private void createDialog() {
        // TODO Auto-generated method stub
        AlertDialog.Builder alert = new AlertDialog.Builder(this);
        alert.setMessage("Do you want to exit");
        alert.setCancelable(false);

        alert.setPositiveButton("Yes්", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
                // TODO Auto-generated method stub
                SampleActivity.super.onBackPressed();
            }
        });
        alert.setNegativeButton("No", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
                // TODO Auto-generated method stub

            }
        });

        alert.create().show();
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK)
            return;

        switch (requestCode) {
            case CAMERA_REQUEST:

                Bundle extras = data.getExtras();

                if (extras != null) {
                    Bitmap yourImage = extras.getParcelable("data");
                    today.setToNow();
                    String date = today.format("%Y-%m-%d %H:%M:%S");
                    // convert bitmap to byte
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    yourImage.compress(Bitmap.CompressFormat.PNG, 100, stream);
                    byte imageInByte[] = stream.toByteArray();
                    Log.e("output before conversion", imageInByte.toString());
                    // Inserting Contacts
                    Log.d("Insert: ", "Inserting ..");
                    db.addContact(new Contact(date+"\n"+et.getText().toString(), imageInByte));
                    Intent i = new Intent(SampleActivity.this,
                            SampleActivity.class);
                    startActivity(i);
                    finish();

                }
                break;
            case NOTE_REQUEST:
                Bundle extras3 = data.getExtras();

                if (extras3 != null) {
                    Bitmap yourImage = extras3.getParcelable("data");

                    today.setToNow();
                    String date = today.format("%Y-%m-%d %H:%M:%S");

                    // convert bitmap to byte
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    yourImage.compress(Bitmap.CompressFormat.PNG, 100, stream);
                    byte imageInByte[] = stream.toByteArray();
                    Log.e("output before conversion", imageInByte.toString());
                    // Inserting Contacts
                    Log.d("Insert: ", "Inserting ..");
                    db.addContact(new Contact(date+"\n"+et.getText().toString(), imageInByte));
                    Intent i = new Intent(SampleActivity.this,
                            SampleActivity.class);
                    startActivity(i);
                    finish();
                }

                break;

            case PICK_FROM_GALLERY:
                Bundle extras2 = data.getExtras();

                if (extras2 != null) {
                    Bitmap yourImage = extras2.getParcelable("data");

                    today.setToNow();
                    String date = today.format("%Y-%m-%d %H:%M:%S");

                    // convert bitmap to byte
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    yourImage.compress(Bitmap.CompressFormat.PNG, 100, stream);
                    byte imageInByte[] = stream.toByteArray();
                    Log.e("output before conversion", imageInByte.toString());
                    // Inserting Contacts
                    Log.d("Insert: ", "Inserting ..");
                    db.addContact(new Contact(date+"\n"+et.getText().toString(), imageInByte));
                    Intent i = new Intent(SampleActivity.this,
                            SampleActivity.class);
                    startActivity(i);
                    finish();
                }

                break;
        }
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
        cameraIntent.putExtra("outputX", 200);
        cameraIntent.putExtra("outputY", 150);
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
        intent.putExtra("outputX", 200);
        intent.putExtra("outputY", 150);
        intent.putExtra("return-data", true);
        startActivityForResult(
                Intent.createChooser(intent, "Complete action using"),
                PICK_FROM_GALLERY);

    }
    public void addNote() {
        today.setToNow();
        String date = today.format("%Y-%m-%d %H:%M:%S");
        Bitmap yourImage = Bitmap.createBitmap(200, 200, Bitmap.Config.ARGB_8888);

        // convert bitmap to byte
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        yourImage.compress(Bitmap.CompressFormat.PNG, 100, stream);
        byte imageInByte[] = stream.toByteArray();
        Log.e("output before conversion", imageInByte.toString());
        // Inserting Contacts
        Log.d("Insert: ", "Inserting ..");
        db.addContact(new Contact(date + "\n" + et.getText().toString(), imageInByte));
        Intent i = new Intent(SampleActivity.this,
                SampleActivity.class);
        startActivity(i);
        finish();


//		Intent sendIntent = new Intent();
//		sendIntent.setAction(Intent.ACTION_SEND);
//		sendIntent.putExtra(Intent.EXTRA_TEXT, et.getText().toString());
//		sendIntent.setType("text/plain");
//		//startActivity(sendIntent);
//		startActivityForResult(
//				Intent.createChooser(sendIntent, "Complete action using"),NOTE_REQUEST);
//

//		Intent intent = new Intent();
//		intent.setType("text/*");
//		intent.setAction(Intent.ACTION_GET_CONTENT);
//		intent.putExtra("crop", "true");
//		intent.putExtra("aspectX", 0);
//		intent.putExtra("aspectY", 0);
//		intent.putExtra("outputX", 200);
//		intent.putExtra("outputY", 150);
//		intent.putExtra("return-data", true);
//		startActivityForResult(
//				Intent.createChooser(intent, "Complete action using"),
//				NOTE_REQUEST);

        //startActivity(NOTE_REQUEST);

    }

//    @Override
//    public boolean onOptionsItemSelected(MenuItem item) {
//        // Handle action bar item clicks here. The action bar will
//        // automatically handle clicks on the Home/Up button, so long
//        // as you specify a parent activity in AndroidManifest.xml.
//        int id = item.getItemId();
//
//        //noinspection SimplifiableIfStatement
//        if (id == R.id.action_settings) {
//            return true;
//        }
//
//        return super.onOptionsItemSelected(item);
//    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.nav_camara) {

            callCamera();
            // Handle the camera action
        } else if (id == R.id.nav_gallery) {
            callGallery();

        } else if (id == R.id.nav_slideshow) {
            Intent intent1 = new Intent(SampleActivity.this,
                    about.class);

            startActivity(intent1);
            finish();
        } else if (id == R.id.nav_manage) {
            Intent intent1 = new Intent(SampleActivity.this,
                    help.class);

            startActivity(intent1);
            finish();


        } else if (id == R.id.nav_send) {
            String str ="https://play.google.com/store/apps/details?id=asak.pro.pinPotha";
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(str)));
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }
}
