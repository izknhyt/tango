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
    apiKey: 'TODO', // TODO: replace with real keys
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    authDomain: 'TODO',
    storageBucket: 'TODO',
    measurementId: 'TODO',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO', // TODO: replace with real keys
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO', // TODO: replace with real keys
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    iosBundleId: 'TODO',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO', // TODO: replace with real keys
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    iosBundleId: 'TODO',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'TODO', // TODO: replace with real keys
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'TODO', // TODO: replace with real keys
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
  );
}
