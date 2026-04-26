package asak.pro.pinPotha.activities;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.design.widget.BottomNavigationView;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.widget.TextView;

import asak.pro.pinPotha.R;

public class SettingsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        setTitle("Settings");
        setVersionText();
        setUpBottomNavigation();
    }

    private void setVersionText() {
        TextView versionText = findViewById(R.id.txt_app_version);
        String versionLabel = "Version: N/A";
        try {
            PackageInfo packageInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
            versionLabel = "Version: " + packageInfo.versionName + " (" + packageInfo.versionCode + ")";
        } catch (PackageManager.NameNotFoundException ignored) {
            // Keep fallback label if package info cannot be resolved.
        }
        versionText.setText(versionLabel);
    }

    private void setUpBottomNavigation() {
        BottomNavigationView bottomNavigationView = findViewById(R.id.bottom_navigation);
        bottomNavigationView.setSelectedItemId(R.id.nav_settings);
        bottomNavigationView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem item) {
                int itemId = item.getItemId();
                if (itemId == R.id.nav_settings) {
                    return true;
                }
                if (itemId == R.id.nav_home) {
                    startActivity(new Intent(SettingsActivity.this, DashboardActivity.class));
                    return true;
                }
                if (itemId == R.id.nav_add) {
                    Intent intent = new Intent(SettingsActivity.this, PostListActivity.class);
                    intent.putExtra("MILLIS", String.valueOf(System.currentTimeMillis()));
                    startActivity(intent);
                    return true;
                }
                if (itemId == R.id.nav_view) {
                    startActivity(new Intent(SettingsActivity.this, GoodThingsActivity.class));
                    return true;
                }
                return false;
            }
        });
    }
}
