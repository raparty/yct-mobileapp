// ─────────────────────────────────────────
// YCT — Force Update Service (R2)
//
// Compares current app version against
// Remote Config minimum version.
// Shows blocking dialog if update required.
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'remote_config_service.dart';
import 'constants.dart';

class UpdateService {
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=org.yogaconsciousness.app';
  static const _appStoreUrl =
      'https://apps.apple.com/app/yoga-consciousness-trust/id0000000000';

  /// Compares version strings. Returns true if [current] < [minimum].
  static bool _needsUpdate(String current, String minimum) {
    if (minimum.isEmpty) return false;
    final c = current.split('.').map(int.tryParse).toList();
    final m = minimum.split('.').map(int.tryParse).toList();
    for (int i = 0; i < m.length; i++) {
      final cv = i < c.length ? (c[i] ?? 0) : 0;
      final mv = m[i] ?? 0;
      if (cv < mv) return true;
      if (cv > mv) return false;
    }
    return false;
  }

  /// Call this after Remote Config is loaded.
  /// Shows a blocking dialog if the app needs updating.
  static Future<void> checkAndShowIfRequired(BuildContext context) async {
    try {
      final minVersion = RemoteConfigService.forceUpdateVersion;
      if (minVersion.isEmpty) return;

      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (!_needsUpdate(current, minVersion)) return;

      final message = RemoteConfigService.forceUpdateMessage.isNotEmpty
          ? RemoteConfigService.forceUpdateMessage
          : 'A new version of the YCT app is available with important improvements. '
            'Please update to continue.';

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false, // Cannot dismiss — must update
          builder: (_) => PopScope(
            canPop: false, // Back button also blocked
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Icons.system_update,
                  color: AppColors.primary, size: 40),
              title: const Text('Update Required',
                style: TextStyle(fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
              content: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textLight, height: 1.5)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // Try Play Store first, fall back to App Store
                    final uri = Uri.parse(_playStoreUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      final iosUri = Uri.parse(_appStoreUrl);
                      if (await canLaunchUrl(iosUri)) {
                        await launchUrl(iosUri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  child: const Text('Update Now',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {
      // Update check failure is never fatal
    }
  }
}
