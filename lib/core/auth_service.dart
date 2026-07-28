// ─────────────────────────────────────────
// YCT — Auth Service (R2)
//
// Silent anonymous auth — no login UI shown.
// Foundation for future subscription gating.
// All content is free for everyone right now.
// ─────────────────────────────────────────
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Sign in anonymously — runs silently in background at app start.
  /// If already signed in, returns existing user immediately.
  static Future<void> init() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      // Tag crashes with anonymous user ID for easier debugging
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(uid);
      }
    } catch (e, stack) {
      // Auth failure is non-fatal — app works without auth for now
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
    }
  }

  static String? get userId => _auth.currentUser?.uid;
  static bool get isSignedIn => _auth.currentUser != null;
}
