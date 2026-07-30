// ─────────────────────────────────────────
// YCT — Firebase Configuration
//
// ⚠️  This file is excluded from Git via .gitignore
//     Never commit real API keys to source control.
//
// For local dev: this file is provided separately.
// For CI/CD: injected via GitHub Actions secrets.
// ─────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';

class YCTFirebaseConfig {
  static const FirebaseOptions android = FirebaseOptions(
    // Web API key — unrestricted, works for all build types
    // Restrict this key in Google Cloud Console to:
    // APIs: Firebase Installations API, Cloud Firestore API,
    //       Firebase Remote Config API, Firebase Auth API
    apiKey:            'AIzaSyBF7Qn4Ytrys9WLuBU41G2KOuxBN0GWGO8',
    appId:             '1:881638212469:android:89bfa42941ad7945b7893c',
    messagingSenderId: '881638212469',
    projectId:         'yct-app',
    storageBucket:     'yct-app.firebasestorage.app',
  );
}
