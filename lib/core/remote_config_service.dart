import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class RemoteConfigService {
  static final _rc = FirebaseRemoteConfig.instance;

  static const _defaults = {
    'subscription_enabled':  false,
    'publications_enabled':  false, // Books tab — off by default
    'force_update_version':  '',
    'force_update_message':  '',
    'maintenance_mode':      false,
    'daily_quote_override':  '',
  };

  static Future<void> init() async {
    try {
      await _rc.setDefaults(_defaults);
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout:         const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _rc.fetchAndActivate();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
    }
  }

  static bool   get subscriptionEnabled => _rc.getBool('subscription_enabled');
  static bool   get publicationsEnabled => _rc.getBool('publications_enabled');
  static String get forceUpdateVersion  => _rc.getString('force_update_version');
  static String get forceUpdateMessage  => _rc.getString('force_update_message');
  static bool   get maintenanceMode     => _rc.getBool('maintenance_mode');
  static String get dailyQuoteOverride  => _rc.getString('daily_quote_override');

  static Future<void> refresh() async {
    try { await _rc.fetchAndActivate(); } catch (_) {}
  }
}
