import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY_WEB'] ?? '',
    appId: '1:848710174872:web:efa883ec3ea4bd7037e8ed',
    messagingSenderId: '848710174872',
    projectId: 'tasklance-579d3',
    authDomain: 'tasklance-579d3.firebaseapp.com',
    storageBucket: 'tasklance-579d3.firebasestorage.app',
    measurementId: 'G-17FDK7DWLC',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '',
    appId: '1:848710174872:android:fec553aa7c79db6c37e8ed',
    messagingSenderId: '848710174872',
    projectId: 'tasklance-579d3',
    storageBucket: 'tasklance-579d3.firebasestorage.app',
  );
}
