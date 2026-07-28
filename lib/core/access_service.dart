// ─────────────────────────────────────────
// YCT — Access Service (R2)
//
// Single hasAccess() function wraps ALL
// content access decisions.
//
// TODAY: returns true for everyone — all
// content is freely available to all devotees.
//
// FUTURE: when subscription_enabled = true in
// Remote Config, this is the only place to
// change — everything else stays the same.
// ─────────────────────────────────────────
import 'remote_config_service.dart';

enum ContentType { magazine, audio, book, center, gurudev }

class AccessService {
  /// Returns true if the current user can access this content.
  /// Currently always true — subscription not yet enabled.
  static bool hasAccess(ContentType type) {
    // If subscription is not enabled, everything is free
    if (!RemoteConfigService.subscriptionEnabled) return true;

    // Future logic goes here when subscription launches:
    // switch (type) {
    //   case ContentType.magazine: return AuthService.isPremium;
    //   case ContentType.audio:    return AuthService.isPremium;
    //   default:                   return true;
    // }
    return true;
  }

  /// Convenience — check if any premium content is locked
  static bool get anyContentLocked =>
      RemoteConfigService.subscriptionEnabled;
}
