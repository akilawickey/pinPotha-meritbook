import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth? _auth;
  FirebaseAuth get _firebase => _auth ?? FirebaseAuth.instance;
  final GoogleSignIn? _google;
  late final GoogleSignIn _googleClient = _google ?? GoogleSignIn();
  final Future<void> Function()? _signInAction;
  final Future<void> Function()? _signOutAction;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  bool _loading = true;
  bool _initializing = true;
  bool _disposed = false;

  AuthProvider(
      {FirebaseAuth? auth,
      GoogleSignIn? google,
      Stream<User?>? authChanges,
      Future<void> Function()? signInAction,
      Future<void> Function()? signOutAction})
      : _auth = auth,
        _google = google,
        _signInAction = signInAction,
        _signOutAction = signOutAction {
    _subscription =
        (authChanges ?? _firebase.authStateChanges()).listen((user) {
      _initializing = false;
      _user = user;
      _loading = false;
      _notify();
      unawaited(_setAnalyticsUser(user?.uid));
    }, onError: (Object error) {
      _user = null;
      _initializing = false;
      _loading = false;
      _notify();
    });
  }
  User? get user => _user;
  bool get initializing => _initializing;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _setAnalyticsUser(String? uid) async {
    try {
      await FirebaseAnalytics.instance.setUserId(id: uid);
    } catch (_) {/* Analytics must not block authentication. */}
  }

  Future<void> signInWithGoogle() async {
    if (_loading) return;
    _loading = true;
    _notify();
    try {
      if (_signInAction != null) {
        await _signInAction();
        return;
      }
      final account = await _googleClient.signIn();
      if (account == null) return;
      final tokens = await account.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: tokens.accessToken, idToken: tokens.idToken);
      await _firebase.signInWithCredential(credential);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> signOut() async {
    if (_signOutAction != null) {
      await _signOutAction();
      return;
    }
    await _firebase
        .signOut(); // Do not pretend a failed Firebase sign-out succeeded.
    try {
      await _googleClient.signOut();
    } catch (_) {/* Firebase session is already cleared. */}
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
