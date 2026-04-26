package asak.pro.pinPotha.activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.BottomNavigationView;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import com.github.sundeepk.compactcalendarview.CompactCalendarView;
import com.github.sundeepk.compactcalendarview.domain.Event;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import asak.pro.pinPotha.R;
import asak.pro.pinPotha.models.Post;

public class DashboardActivity extends AppCompatActivity {
    private static final String POSTS_PATH = "posts";
    private FirebaseAuth mFirebaseAuth;
    private DatabaseReference postsReference;
    private ValueEventListener postsListener;
    private final List<Post> allPosts = new ArrayList<>();
    private CompactCalendarView compactCalendarView;
    private TextView selectedDayText;
    private TextView calendarMonthText;
    private Toolbar toolbar;
    private long calendarDisplayMillis;
    private long selectedDayStartMillis;
    private final SimpleDateFormat dayLabelFormat = new SimpleDateFormat("EEE, dd MMM yyyy", Locale.getDefault());
    private final SimpleDateFormat monthLabelFormat = new SimpleDateFormat("MMMM yyyy", Locale.getDefault());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dashboard);
        toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        mFirebaseAuth = FirebaseAuth.getInstance();
        selectedDayStartMillis = getInitialSelectedDay(getIntent());
        compactCalendarView = findViewById(R.id.compact_calendar);
        selectedDayText = findViewById(R.id.txt_selected_day);
        calendarMonthText = findViewById(R.id.txt_calendar_month);
        setUpCalendar();
        setUpCalendarNavigation();
        setUpBottomNavigation();
        subscribePosts();

        Button addButton = findViewById(R.id.button2);
        Button viewGoodThingsButton = findViewById(R.id.btn_view_good_things);
        addButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openAddScreenForSelectedDate();
            }
        });
        viewGoodThingsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(DashboardActivity.this, GoodThingsActivity.class));
            }
        });
    }

    private long getInitialSelectedDay(Intent intent) {
        if (intent != null) {
            String millis = intent.getStringExtra("MILLIS");
            if (millis != null) {
                try {
                    return normalizeDay(Long.parseLong(millis));
                } catch (NumberFormatException ignored) {
                    // Fallback to today.
                }
            }
        }
        return normalizeDay(Calendar.getInstance().getTimeInMillis());
    }

    private void setUpCalendar() {
        compactCalendarView.setShouldDrawDaysHeader(false);
        compactCalendarView.setUseThreeLetterAbbreviation(true);
        compactCalendarView.setCurrentDate(new Date(selectedDayStartMillis));
        calendarDisplayMillis = selectedDayStartMillis;
        calendarMonthText.setText(monthLabelFormat.format(new Date(calendarDisplayMillis)));
        selectedDayText.setText("Selected: " + dayLabelFormat.format(new Date(selectedDayStartMillis)));
        compactCalendarView.setListener(new CompactCalendarView.CompactCalendarViewListener() {
            @Override
            public void onDayClick(Date dateClicked) {
                selectedDayStartMillis = normalizeDay(dateClicked.getTime());
                calendarDisplayMillis = selectedDayStartMillis;
                selectedDayText.setText("Selected: " + dayLabelFormat.format(new Date(selectedDayStartMillis)));
                showGoodThingsForSelectedDay();
            }

            @Override
            public void onMonthScroll(Date firstDayOfNewMonth) {
                calendarDisplayMillis = firstDayOfNewMonth.getTime();
                calendarMonthText.setText(monthLabelFormat.format(firstDayOfNewMonth));
            }
        });
    }

    private void setUpCalendarNavigation() {
        Button prevMonth = findViewById(R.id.btn_prev_month);
        Button nextMonth = findViewById(R.id.btn_next_month);
        Button prevYear = findViewById(R.id.btn_prev_year);
        Button nextYear = findViewById(R.id.btn_next_year);
        prevMonth.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                shiftCalendarBy(0, -1);
            }
        });
        nextMonth.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                shiftCalendarBy(0, 1);
            }
        });
        prevYear.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                shiftCalendarBy(-1, 0);
            }
        });
        nextYear.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                shiftCalendarBy(1, 0);
            }
        });
    }

    private void shiftCalendarBy(int yearDelta, int monthDelta) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(calendarDisplayMillis);
        if (yearDelta != 0) {
            calendar.add(Calendar.YEAR, yearDelta);
        }
        if (monthDelta != 0) {
            calendar.add(Calendar.MONTH, monthDelta);
        }
        calendarDisplayMillis = calendar.getTimeInMillis();
        compactCalendarView.setCurrentDate(new Date(calendarDisplayMillis));
        calendarMonthText.setText(monthLabelFormat.format(new Date(calendarDisplayMillis)));
    }

    private void setUpBottomNavigation() {
        BottomNavigationView bottomNavigationView = findViewById(R.id.bottom_navigation);
        bottomNavigationView.setSelectedItemId(R.id.nav_home);
        bottomNavigationView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem item) {
                if (item.getItemId() == R.id.nav_home) {
                    return true;
                }
                if (item.getItemId() == R.id.nav_add) {
                    openAddScreenForSelectedDate();
                    return true;
                }
                if (item.getItemId() == R.id.nav_view) {
                    startActivity(new Intent(DashboardActivity.this, GoodThingsActivity.class));
                    return true;
                }
                if (item.getItemId() == R.id.nav_settings) {
                    startActivity(new Intent(DashboardActivity.this, SettingsActivity.class));
                    return true;
                }
                return false;
            }
        });
    }

    private void openAddScreenForSelectedDate() {
        Intent intent = new Intent(DashboardActivity.this, PostListActivity.class);
        intent.putExtra("MILLIS", String.valueOf(selectedDayStartMillis));
        startActivity(intent);
    }

    private void subscribePosts() {
        FirebaseUser user = mFirebaseAuth.getCurrentUser();
        if (user == null || user.getEmail() == null) {
            goToSignIn();
            return;
        }
        postsReference = FirebaseDatabase.getInstance().getReference()
                .child(POSTS_PATH)
                .child(user.getEmail().replace(".", ","));
        postsListener = postsReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                allPosts.clear();
                for (DataSnapshot dateNode : dataSnapshot.getChildren()) {
                    for (DataSnapshot postNode : dateNode.getChildren()) {
                        Post post = postNode.getValue(Post.class);
                        if (post != null) {
                            allPosts.add(post);
                        }
                    }
                }
                Collections.sort(allPosts, new Comparator<Post>() {
                    @Override
                    public int compare(Post left, Post right) {
                        return Long.valueOf(getTimestamp(right)).compareTo(getTimestamp(left));
                    }
                });
                renderCalendarDots();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // No-op: empty state remains visible when read fails.
            }
        });
    }

    private void renderCalendarDots() {
        compactCalendarView.removeAllEvents();
        Map<Long, Integer> dateCounts = new HashMap<>();
        for (Post post : allPosts) {
            long day = normalizeDay(getTimestamp(post));
            Integer count = dateCounts.get(day);
            dateCounts.put(day, count == null ? 1 : count + 1);
        }
        for (Map.Entry<Long, Integer> entry : dateCounts.entrySet()) {
            long dayMillis = entry.getKey();
            int count = entry.getValue();
            compactCalendarView.addEvent(new Event(getResources().getColor(R.color.colorPrimary), dayMillis));
            if (count > 1) {
                // Second dot for multiple good things on the same day.
                compactCalendarView.addEvent(new Event(getResources().getColor(R.color.colorPrimaryDark), dayMillis + 1));
            }
        }
    }

    private void showGoodThingsForSelectedDay() {
        List<Post> dayPosts = new ArrayList<>();
        for (Post post : allPosts) {
            if (normalizeDay(getTimestamp(post)) == selectedDayStartMillis) {
                dayPosts.add(post);
            }
        }

        if (dayPosts.isEmpty()) {
            new AlertDialog.Builder(this)
                    .setTitle(dayLabelFormat.format(new Date(selectedDayStartMillis)))
                    .setMessage("No good things recorded for this day yet.")
                    .setPositiveButton("Add Good Thing", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            openAddScreenForSelectedDate();
                        }
                    })
                    .setNegativeButton("Close", null)
                    .show();
            return;
        }

        String[] notes = new String[dayPosts.size()];
        for (int i = 0; i < dayPosts.size(); i++) {
            String note = dayPosts.get(i).getNote();
            if (note == null || note.trim().equals("")) {
                notes[i] = (i + 1) + ". (No note text)";
            } else {
                String trimmed = note.trim();
                if (trimmed.length() > 70) {
                    trimmed = trimmed.substring(0, 70) + "...";
                }
                notes[i] = (i + 1) + ". " + trimmed;
            }
        }

        new AlertDialog.Builder(this)
                .setTitle("Good things on " + dayLabelFormat.format(new Date(selectedDayStartMillis)))
                .setItems(notes, null)
                .setPositiveButton("Close", null)
                .show();
    }

    private long normalizeDay(long millis) {
        if (millis <= 0) {
            return 0L;
        }
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(millis);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTimeInMillis();
    }

    private long getTimestamp(Post post) {
        if (post.getTimeStamp() == null || post.getTimeStamp().get("server_time") == null) {
            return 0L;
        }
        Object value = post.getTimeStamp().get("server_time");
        if (value instanceof Long) {
            return (Long) value;
        }
        if (value instanceof String) {
            try {
                return Long.parseLong((String) value);
            } catch (NumberFormatException ignored) {
                return 0L;
            }
        }
        return 0L;
    }

    private void showProfileDialog() {
        FirebaseUser user = mFirebaseAuth.getCurrentUser();
        String name = user != null && user.getDisplayName() != null ? user.getDisplayName() : "Not available";
        String email = user != null && user.getEmail() != null ? user.getEmail() : "Not available";
        new AlertDialog.Builder(this)
                .setTitle("Profile")
                .setMessage("Name: " + name + "\nEmail: " + email)
                .setPositiveButton("OK", null)
                .show();
    }

    private void signOut() {
        GoogleSignInClient googleSignInClient = GoogleSignIn.getClient(this,
                new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail().build());
        mFirebaseAuth.signOut();
        googleSignInClient.signOut();
        goToSignIn();
    }

    private void goToSignIn() {
        Intent intent = new Intent(this, SignInActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.dashboard_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_view_good_things) {
            startActivity(new Intent(DashboardActivity.this, GoodThingsActivity.class));
            return true;
        } else if (item.getItemId() == R.id.action_profile) {
            showProfileDialog();
            return true;
        } else if (item.getItemId() == R.id.action_settings) {
            startActivity(new Intent(DashboardActivity.this, SettingsActivity.class));
            return true;
        } else if (item.getItemId() == R.id.action_logout) {
            new AlertDialog.Builder(this)
                    .setTitle("Logout")
                    .setMessage("Do you want to sign out?")
                    .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            signOut();
                        }
                    })
                    .setNegativeButton("No", null)
                    .show();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (postsListener == null) {
            subscribePosts();
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        long newSelectedDay = getInitialSelectedDay(intent);
        if (newSelectedDay > 0) {
            selectedDayStartMillis = newSelectedDay;
            calendarDisplayMillis = newSelectedDay;
            compactCalendarView.setCurrentDate(new Date(newSelectedDay));
            calendarMonthText.setText(monthLabelFormat.format(new Date(newSelectedDay)));
            selectedDayText.setText("Selected: " + dayLabelFormat.format(new Date(newSelectedDay)));
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (postsReference != null && postsListener != null) {
            postsReference.removeEventListener(postsListener);
            postsListener = null;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (postsReference != null && postsListener != null) {
            postsReference.removeEventListener(postsListener);
            postsListener = null;
        }
    }

}
