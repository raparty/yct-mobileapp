// ─────────────────────────────────────────
// YCT — Remote Config Service (R2)
//
// Controls:
//   subscription_enabled  bool  false   → future payment gating
//   force_update_version  String ""     → minimum app version
//   force_update_message  String ""     → message shown to user
//   maintenance_mode      bool  false   → show maintenance screen
//   daily_quote_override  String ""     → override quote remotely
// ─────────────────────────────────────────
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class RemoteConfigService {
  static final _rc = FirebaseRemoteConfig.instance;

  // ── Default values — all safe for new installs ──────────────
  static const _defaults = {
    'subscription_enabled':  false,
    'force_update_version':  '',
    'force_update_message':  '',
    'maintenance_mode':      false,
    'daily_quote_override':  '',
  };

  static Future<void> init() async {
    try {
      await _rc.setDefaults(_defaults);
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout:      const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _rc.fetchAndActivate();
    } catch (e, stack) {
      // Remote Config failure is non-fatal — app works with defaults
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
    }
  }

  // ── Accessors ────────────────────────────────────────────────

  /// Whether subscription/payment is enabled (always false for now)
  static bool get subscriptionEnabled =>
      _rc.getBool('subscription_enabled');

  /// Minimum version required to use the app (empty = no requirement)
  static String get forceUpdateVersion =>
      _rc.getString('force_update_version');

  /// Message to show users who need to update
  static String get forceUpdateMessage =>
      _rc.getString('force_update_message');

  /// Whether app is in maintenance mode
  static bool get maintenanceMode =>
      _rc.getBool('maintenance_mode');

  /// Override the daily quote from remote (empty = use Firestore value)
  static String get dailyQuoteOverride =>
      _rc.getString('daily_quote_override');

  /// Refresh config in background — call on app resume
  static Future<void> refresh() async {
    try {
      await _rc.fetchAndActivate();
    } catch (_) {}
  }
}
