package asak.pro.pinPotha;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;

import asak.pro.ddbs.DriveSyncController;
import asak.pro.ddbs.NewerDatabaseCallback;

public class Main2Activity extends AppCompatActivity implements NewerDatabaseCallback {

    private DataBaseHandler mDbHelper;

    /**
     * Reference to the library DriveSyncController that handles interfacing the local SQLite DB and
     * the Drive backup.
     */
    private DriveSyncController mSyncController;
    private Button buttonPush;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mDbHelper = new DataBaseHandler(this);

        // Init the ddbs DriveSyncController
        mSyncController = DriveSyncController.get(this, mDbHelper, null).setDebug(true);

        setContentView(R.layout.activity_main2);
        buttonPush = (Button) findViewById(R.id.buttonPush);

        buttonPush.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                pushLocal();
            }
        });
    }

    public void pushLocal() {
        mSyncController.putDbInDrive();
    }

    public void driveNewer() {
    }
    public void localNewer() {
    }
}
