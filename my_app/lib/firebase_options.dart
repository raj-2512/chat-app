// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDtqr6TOGUkn-pereG2giq4wEk0Hldgdas',
    appId: '1:84100298205:web:66a817a0a23593d7f1b234',
    messagingSenderId: '84100298205',
    projectId: 'my-cool-project-123',
    authDomain: 'my-cool-project-123.firebaseapp.com',
    storageBucket: 'my-cool-project-123.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRVWfmvfRnU0vshG1xEvtp9jIa6YVuOVw',
    appId: '1:84100298205:android:c2e6b45c9415e9cbf1b234',
    messagingSenderId: '84100298205',
    projectId: 'my-cool-project-123',
    storageBucket: 'my-cool-project-123.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCSYlNoUMBSa9tRyJXzrQiKb8qRvoC-l0Y',
    appId: '1:84100298205:ios:56a9d99f9182b740f1b234',
    messagingSenderId: '84100298205',
    projectId: 'my-cool-project-123',
    storageBucket: 'my-cool-project-123.appspot.com',
    iosClientId: '84100298205-idr97geiornh2b4evh07f609c3a1eb8s.apps.googleusercontent.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCSYlNoUMBSa9tRyJXzrQiKb8qRvoC-l0Y',
    appId: '1:84100298205:ios:8f37d20ad8596addf1b234',
    messagingSenderId: '84100298205',
    projectId: 'my-cool-project-123',
    storageBucket: 'my-cool-project-123.appspot.com',
    iosClientId: '84100298205-ns3ongaluj5mlidtnofga43al1cs1tsm.apps.googleusercontent.com',
    iosBundleId: 'com.example.myApp.RunnerTests',
  );
}