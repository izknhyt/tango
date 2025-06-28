import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the app.
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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'example-api-key',
    appId: 'example-app-id',
    messagingSenderId: 'example-msg-sender-id',
    projectId: 'example-project-id',
    authDomain: 'example-auth-domain',
    storageBucket: 'example-storage-bucket',
    measurementId: 'example-measurement-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'example-api-key',
    appId: 'example-app-id',
    messagingSenderId: 'example-msg-sender-id',
    projectId: 'example-project-id',
    storageBucket: 'example-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'example-api-key',
    appId: 'example-app-id',
    messagingSenderId: 'example-msg-sender-id',
    projectId: 'example-project-id',
    iosBundleId: 'example-ios-bundle-id',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'example-api-key',
    appId: 'example-app-id',
    messagingSenderId: 'example-msg-sender-id',
    projectId: 'example-project-id',
    iosBundleId: 'example-ios-bundle-id',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'example-api-key',
    appId: 'example-app-id',
    messagingSenderId: 'example-msg-sender-id',
    projectId: 'example-project-id',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'example-api-key',
    appId: 'example-app-id',
    messagingSenderId: 'example-msg-sender-id',
    projectId: 'example-project-id',
  );
}
