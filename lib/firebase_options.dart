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
    apiKey: 'AIzaSyDojIekeQxpScfNUQNxq6SXJmGbXqxuwlA',
    appId: '1:1057692047745:web:289bac26d62538db927080',
    messagingSenderId: '1057692047745',
    projectId: 'safe-mother-app',
    authDomain: 'safe-mother-app.firebaseapp.com',
    storageBucket: 'safe-mother-app.firebasestorage.app',
    measurementId: 'G-3ETTKJNNDH',
    // Add the web client ID for Google Sign-In
    // You need to get this from Firebase Console > Authentication > Sign-in method > Google > Web SDK configuration
    // For now, using a placeholder - replace with actual web client ID
    // androidClientId: 'your-web-client-id-here.apps.googleusercontent.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2a8mSJ7bO-w4sNAmpzNIFSuhhkhUaZEc',
    appId: '1:1057692047745:android:bea4c4d4137973e1927080',
    messagingSenderId: '1057692047745',
    projectId: 'safe-mother-app',
    storageBucket: 'safe-mother-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDKR1jE87AmQi2sMxEiexCGjcDkQAvqs2w',
    appId: '1:1057692047745:ios:07e0661b6964a381927080',
    messagingSenderId: '1057692047745',
    projectId: 'safe-mother-app',
    storageBucket: 'safe-mother-app.firebasestorage.app',
    iosClientId: '1057692047745-h4qlf16rec2sfvragapcd00u6afgmrmg.apps.googleusercontent.com',
    iosBundleId: 'com.example.safemothermobapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDKR1jE87AmQi2sMxEiexCGjcDkQAvqs2w',
    appId: '1:1057692047745:ios:07e0661b6964a381927080',
    messagingSenderId: '1057692047745',
    projectId: 'safe-mother-app',
    storageBucket: 'safe-mother-app.firebasestorage.app',
    iosClientId: '1057692047745-h4qlf16rec2sfvragapcd00u6afgmrmg.apps.googleusercontent.com',
    iosBundleId: 'com.example.safemothermobapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDojIekeQxpScfNUQNxq6SXJmGbXqxuwlA',
    appId: '1:1057692047745:web:7bd5f677338012f1927080',
    messagingSenderId: '1057692047745',
    projectId: 'safe-mother-app',
    authDomain: 'safe-mother-app.firebaseapp.com',
    storageBucket: 'safe-mother-app.firebasestorage.app',
    measurementId: 'G-DR1M6LPQER',
  );

}
