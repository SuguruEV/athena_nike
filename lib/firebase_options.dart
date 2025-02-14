// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDli9H0Y4shtAAP8WP6eKqXZkpklC25PqU',
    appId: '1:738254835702:web:0d9702f834df545af8c1d7',
    messagingSenderId: '738254835702',
    projectId: 'athenachat-28cba',
    authDomain: 'athenachat-28cba.firebaseapp.com',
    storageBucket: 'athenachat-28cba.appspot.com',
    measurementId: 'G-R0E514VS7S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvvZfmP80q7L4UvPs_iQWQYtie1h5G5-o',
    appId: '1:738254835702:android:cb5ec6d7b981f79ef8c1d7',
    messagingSenderId: '738254835702',
    projectId: 'athenachat-28cba',
    storageBucket: 'athenachat-28cba.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAf-bXwk5EP4KFWIr6Xv8_QOptN-T-EdpU',
    appId: '1:738254835702:ios:11be6baf9fb6b402f8c1d7',
    messagingSenderId: '738254835702',
    projectId: 'athenachat-28cba',
    storageBucket: 'athenachat-28cba.appspot.com',
    iosBundleId: 'es.suguruev.athenanike',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDli9H0Y4shtAAP8WP6eKqXZkpklC25PqU',
    appId: '1:738254835702:web:c229c932936dbbf1f8c1d7',
    messagingSenderId: '738254835702',
    projectId: 'athenachat-28cba',
    authDomain: 'athenachat-28cba.firebaseapp.com',
    storageBucket: 'athenachat-28cba.appspot.com',
    measurementId: 'G-5JMNW6BT07',
  );
}
