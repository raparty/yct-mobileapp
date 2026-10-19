import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class RemoteConfigService {
  static final _rc = FirebaseRemoteConfig.instance;

  static const _defaults = {
    'publications_enabled':  false,
    'force_update_version':  '',
    'force_update_message':  '',
    'maintenance_mode':      false,
    'daily_quote_override':  '',
    'show_launch_countdown': false, // flip to true on Sep 25 to show countdown
  };

  static Future<void> init() async {
    try {
      await _rc.setDefaults(_defaults);
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout:         const Duration(seconds: 3),   // was 10 — prevents ANR
        minimumFetchInterval: const Duration(hours: 1),
      ));
      // Activate the values cached from the last launch IMMEDIATELY
      // (no network needed), so the app can open right away.
      await _rc.activate();
      // Then try to fetch fresh values in the background; if the
      // network is slow or unavailable the app is already running.
      _rc.fetchAndActivate().catchError((e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
    }
  }

  static bool   get publicationsEnabled  => _rc.getBool('publications_enabled');
  static String get forceUpdateVersion   => _rc.getString('force_update_version');
  static String get forceUpdateMessage   => _rc.getString('force_update_message');
  static bool   get maintenanceMode      => _rc.getBool('maintenance_mode');
  static String get dailyQuoteOverride   => _rc.getString('daily_quote_override');
  static bool   get showLaunchCountdown  => _rc.getBool('show_launch_countdown');

  static Future<void> refresh() async {
    try { await _rc.fetchAndActivate(); } catch (_) {}
  }
}
