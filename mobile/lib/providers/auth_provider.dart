import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/token_debug.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    // Get initial auth state immediately
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _loading = false;
      notifyListeners();
    } else {
      // If no current user, set loading to false after a short delay
      // This prevents infinite spinner on first load
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_user == null && _loading) {
          _loading = false;
          notifyListeners();
        }
      });
    }
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _loading = false;
      notifyListeners();
      
      if (user != null) {
        _analytics.setUserId(id: user.email ?? user.uid);
        _analytics.logLogin(loginMethod: 'google');
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();

      // Ensure Google Sign-In is properly reset before signing in
      // This helps with subsequent logins after logout
      try {
        await _googleSignIn.signOut();
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        // Ignore errors if already signed out
        debugPrint('Google Sign-In reset (expected if already signed out): $e');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _loading = false;
        notifyListeners();
        throw Exception('Failed to get Google authentication tokens. Please try again.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Update user state immediately
      _user = userCredential.user;
      
      // Force token refresh to ensure email is in the token for database rules
      if (userCredential.user != null) {
        // Wait for token to be properly set
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Debug token contents
        try {
          await TokenDebug.printTokenInfo(userCredential.user!);
          await TokenDebug.testDatabaseAccess(userCredential.user!);
        } catch (e) {
          debugPrint('Error in token debug: $e');
        }
        
        // Debug token contents
        try {
          await TokenDebug.printTokenInfo(userCredential.user!);
          await TokenDebug.testDatabaseAccess(userCredential.user!);
        } catch (e) {
          debugPrint('Error in token debug: $e');
        }
        
        // Get fresh token a couple more times to ensure it's stable
        for (int i = 0; i < 2; i++) {
          try {
            await userCredential.user!.getIdToken(true);
            await Future.delayed(const Duration(milliseconds: 300));
          } catch (e) {
            debugPrint('Error refreshing token: $e');
          }
        }
      }
      
      // Clear loading state after sign-in completes
      _loading = false;
      notifyListeners();
      
      _analytics.logEvent(name: 'sign_in', parameters: {'method': 'google'});
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage = 'Sign in failed. Please try again.';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'An account already exists with a different sign-in method.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials. Please try signing in again.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Google sign-in is not enabled. Please contact support.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      _loading = false;
      notifyListeners();
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _loading = true;
      notifyListeners();
      
      // Sign out from Firebase Auth first
      await _auth.signOut();
      
      // Then sign out from Google Sign-In
      await _googleSignIn.signOut();
      
      // Wait a moment to ensure sign-out completes
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Clear user state
      _user = null;
      _loading = false;
      
      // Log analytics event
      _analytics.logEvent(name: 'sign_out');
      _analytics.setUserId(id: null);
      
      notifyListeners();
    } catch (e) {
      // Even if there's an error, clear the state
      _user = null;
      _loading = false;
      notifyListeners();
      debugPrint('Sign out error: $e');
      // Don't rethrow - allow sign out to complete even if there are errors
    }
  }
}

