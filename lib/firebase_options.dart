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
    apiKey: 'AIzaSyBnO8WQFWKbFWik5y5nG-9GqFB68wTXLVg',
    appId: '1:535053027312:web:be4fa1e72d4cad9cbf7f35',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'flutter-ai-playground-8da85',
    authDomain: 'flutter-ai-playground-8da85.firebaseapp.com',
    databaseURL: 'https://flutter-ai-playground-8da85-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-ai-playground-8da85.firebasestorage.app',
    measurementId: '535053027312',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnO8WQFWKbFWik5y5nG-9GqFB68wTXLVg',
    appId: '1:535053027312:web:be4fa1e72d4cad9cbf7f35',
    messagingSenderId: '535053027312',
    projectId: 'flutter-ai-playground-8da85',
    databaseURL: 'https://flutter-ai-playground-8da85-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-ai-playground-8da85.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    databaseURL: 'REPLACE_WITH_YOUR_DATABASE_URL',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.monjesApp4',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_MACOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_MACOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    databaseURL: 'REPLACE_WITH_YOUR_DATABASE_URL',
    storageBucket: 'REPLACE_WITH_YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.monjesApp4.RunnerTests',
  );
}
