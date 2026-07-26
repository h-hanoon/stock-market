// File generated based on the Firebase project's registered Android/iOS apps
// (see android/app/google-services.json and ios/Runner/GoogleService-Info.plist).
// If you add more platforms, regenerate this with `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run `flutterfire configure` to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAbg8lz1xYvU2Xw_RmD1JidYcc2H6IgcM',
    appId: '1:104900682440:android:871ea246efafe70ec93bfd',
    messagingSenderId: '104900682440',
    projectId: 'financial-fdfb8',
    storageBucket: 'financial-fdfb8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHb6rf3tfhpZ_oEtBJm0P_aXXa1_-_zdU',
    appId: '1:104900682440:ios:d442edb182c4dc88c93bfd',
    messagingSenderId: '104900682440',
    projectId: 'financial-fdfb8',
    storageBucket: 'financial-fdfb8.firebasestorage.app',
    iosBundleId: 'com.example.stocksapp',
  );
}
