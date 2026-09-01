// ─────────────────────────────────────────
// YCT — Access Service
//
// All content is freely available to all
// devotees. No subscriptions or payments.
// ─────────────────────────────────────────

enum ContentType { magazine, audio, book, center, gurudev }

class AccessService {
  /// All content is freely accessible to everyone.
  /// YCT is a non-profit spiritual organisation.
  static bool hasAccess(ContentType type) => true;

  /// No content is locked — everything is free.
  static bool get anyContentLocked => false;
}
