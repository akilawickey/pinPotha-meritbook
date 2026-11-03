import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbz7tp2TJV0xQkbaI1fkpGz3ixejiCkCA',
    appId: '1:313883222202:android:a950d816b991eb32',
    messagingSenderId: '313883222202',
    projectId: 'pinpotha-1295',
    storageBucket: 'pinpotha-1295.appspot.com',
    databaseURL: 'https://pinpotha-1295.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqCgemYGGM4jvg-lxWg07HXoepPMG8yrM',
    appId: '1:313883222202:ios:38756472ddb83770d36283',
    messagingSenderId: '313883222202',
    projectId: 'pinpotha-1295',
    storageBucket: 'pinpotha-1295.appspot.com',
    iosBundleId: 'com.leafylanka.pinpotha',
    iosClientId:
        '313883222202-beuoh172ubnsmghq1s7q6e9i9p51c2oh.apps.googleusercontent.com',
    databaseURL: 'https://pinpotha-1295.firebaseio.com',
  );
}
