// File generated for PulseTrack Firebase configuration.
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
  /// Resolves the platform-specific [FirebaseOptions] for the active target.
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

  /// Android Firebase configuration options.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHdQ-lcfcK4JQgiNCj5wj5LA-SpCJ7_b4',
    appId: '1:1002565185056:android:00b121f2ac237846da9645',
    messagingSenderId: '1002565185056',
    projectId: 'pulsetrack-app',
    storageBucket: 'pulsetrack-app.firebasestorage.app',
  );

  /// iOS Firebase configuration options.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4zKUrr4_XDj0ikLK5pPkBnv_vGaiNywM',
    appId: '1:1002565185056:ios:d370d7bedb7efd1fda9645',
    messagingSenderId: '1002565185056',
    projectId: 'pulsetrack-app',
    storageBucket: 'pulsetrack-app.firebasestorage.app',
    iosBundleId: 'com.ekerstudio.pulsetrack',
  );
}
