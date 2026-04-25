package asak.pro.pinPotha.activities;

import android.app.ProgressDialog;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.SignInButton;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthProvider;

import asak.pro.pinPotha.R;

public class SignInActivity extends AppCompatActivity {

    private FirebaseAuth mFirebaseAuth;
    public static final int RC_GOOGLE_LOGIN = 1;
    public GoogleSignInAccount mGoogleAccount;
    private GoogleSignInClient googleSignInClient;
    private FirebaseUser user;
    private ProgressDialog mAuthProgressDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(asak.pro.pinPotha.R.layout.activity_main);
        initComponent();
    }

    public void initComponent() {
        mFirebaseAuth=FirebaseAuth.getInstance();
        user=mFirebaseAuth.getCurrentUser();
        if (user!=null) {
            onSuccessfullAuthentication();
            return;
        }
        /**
         * Setup the Google API object to allow Google log in
         * */
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(getString(R.string.default_web_client_id))
                .requestEmail()
                .build();
        googleSignInClient = GoogleSignIn.getClient(this, gso);
        if (user!=null) {

        }
        mAuthProgressDialog = new ProgressDialog(this);
        mAuthProgressDialog.setTitle(getString(R.string.progress_dialog_loading));
        mAuthProgressDialog.setMessage(getString(R.string.progress_dialog_authenticating_with_firebase));
        mAuthProgressDialog.setCancelable(false);

        /**
         * google sign in button configuration below, start activity for result
         * */

        SignInButton signInButton = findViewById(R.id.login_with_google);
        signInButton.setSize(SignInButton.SIZE_WIDE);
        signInButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent=googleSignInClient.getSignInIntent();
                startActivityForResult(intent,RC_GOOGLE_LOGIN);
                mAuthProgressDialog.show();
            }
        });
    }

    /**
     * When google user account select an activity result get triggered
     * */

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        // Result returned from launching the Intent from GoogleSignInClient.getSignInIntent
        if (requestCode==RC_GOOGLE_LOGIN) {
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            try {
                mGoogleAccount = task.getResult(ApiException.class);
                firebaseAuthWithGoogle(mGoogleAccount);
            } catch (ApiException e) {
                mAuthProgressDialog.dismiss();
                Toast.makeText(this,"Something may wrong",Toast.LENGTH_SHORT).show();
                Log.w("GoogleLogin", "Google sign in failed", e);
            }
        }
    }

    /**
     * After successfully user account selected from dialog, Account details used
     * to authenticate with firebase
     * */

    private void firebaseAuthWithGoogle(GoogleSignInAccount acct) {
        Log.d("GoogleLogin", "firebaseAuthWithGoogle:" + acct.getId());
        Log.e("start","done");
        mAuthProgressDialog.show();
        AuthCredential credential = GoogleAuthProvider.getCredential(acct.getIdToken(), null);
        mFirebaseAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        Log.d("Google sign In", "signInWithCredential:onComplete:" + task.isSuccessful());

                        // If sign in fails, display a message to the user. If sign in succeeds
                        // the auth state listener will be notified and logic to handle the
                        // signed in user can be handled in the listener.
                        if (!task.isSuccessful()) {
                            Log.w("google sign in", "signInWithCredential", task.getException());
                            Toast.makeText(SignInActivity.this, "Authentication failed.",
                                    Toast.LENGTH_SHORT).show();
                        }
                        else if(task.isSuccessful())
                        {
                            onSuccessfullAuthentication();
                        }
                        mAuthProgressDialog.dismiss();

                    }
                });
    }

    /**
     * After successfully authenticated with firebase for details provided from selected google account
     * */
    public void onSuccessfullAuthentication() {
       Intent intent=new Intent(this,DashboardActivity.class);
       startActivity(intent);
       finish();
    }
}
