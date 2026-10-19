// ─────────────────────────────────────────────────────────────────────────────
// NewContentService
//
// On app launch (once per session) this service checks Firestore for audio
// tracks and magazine issues uploaded AFTER the timestamps the user last saw.
// If new items are found it returns a summary for display as an in-app popup.
//
// Timestamps are stored in SharedPreferences:
//   last_seen_audio_at    — epoch ms of the newest audio the user has been shown
//   last_seen_magazine_at — epoch ms of the newest magazine the user has been shown
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAudioKey    = 'last_seen_audio_at';
const _kMagazineKey = 'last_seen_magazine_at';

class NewContentResult {
  final int newAudioCount;
  final int newMagazineCount;

  const NewContentResult({
    required this.newAudioCount,
    required this.newMagazineCount,
  });

  bool get hasNew => newAudioCount > 0 || newMagazineCount > 0;

  String get message {
    final parts = <String>[];
    if (newAudioCount > 0) {
      parts.add('$newAudioCount new audio discourse${newAudioCount > 1 ? 's' : ''}');
    }
    if (newMagazineCount > 0) {
      parts.add('$newMagazineCount new magazine issue${newMagazineCount > 1 ? 's' : ''}');
    }
    return parts.join(' and ');
  }
}

class NewContentService {
  NewContentService._();

  /// Call once at app startup. Returns a [NewContentResult] describing any new
  /// content since the user last saw it.  Also advances the stored timestamps
  /// so the same items are not shown again.
  static Future<NewContentResult> check() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAudio    = prefs.getInt(_kAudioKey);
      final lastMagazine = prefs.getInt(_kMagazineKey);

      final now = DateTime.now().millisecondsSinceEpoch;

      final results = await Future.wait([
        _countNew('audio_tracks',  'uploaded_at', lastAudio),
        _countNew('magazines',     'created_at',  lastMagazine),
      ]);

      final newAudio    = results[0].$1;
      final newAudioMs  = results[0].$2;
      final newMag      = results[1].$1;
      final newMagMs    = results[1].$2;

      // Advance timestamps even when count is 0, so the baseline is always fresh.
      if (newAudioMs != null) {
        await prefs.setInt(_kAudioKey, newAudioMs);
      } else if (lastAudio == null) {
        // First-ever launch — mark now so only future uploads trigger the popup.
        await prefs.setInt(_kAudioKey, now);
      }

      if (newMagMs != null) {
        await prefs.setInt(_kMagazineKey, newMagMs);
      } else if (lastMagazine == null) {
        await prefs.setInt(_kMagazineKey, now);
      }

      // On first-ever launch (both timestamps were null), do NOT show popup —
      // there is no meaningful "since last time" yet.
      if (lastAudio == null && lastMagazine == null) {
        return const NewContentResult(newAudioCount: 0, newMagazineCount: 0);
      }

      return NewContentResult(
        newAudioCount:    newAudio,
        newMagazineCount: newMag,
      );
    } catch (_) {
      // Non-fatal — silently skip the popup on any error.
      return const NewContentResult(newAudioCount: 0, newMagazineCount: 0);
    }
  }

  /// Query [collection] for docs where [field] > [afterMs] and is_published == true.
  /// Returns (count, newestTimestampMs).
  static Future<(int, int?)> _countNew(
    String collection,
    String field,
    int? afterMs,
  ) async {
    Query q = FirebaseFirestore.instance
        .collection(collection)
        .where('is_published', isEqualTo: true)
        .orderBy(field, descending: true)
        .limit(50);

    if (afterMs != null) {
      final after = Timestamp.fromMillisecondsSinceEpoch(afterMs);
      q = q.where(field, isGreaterThan: after);
    }

    final snap = await q.get();
    if (snap.docs.isEmpty) return (0, null);

    // Newest is first (descending order).
    final newest = snap.docs.first.data() as Map<String, dynamic>;
    final ts = newest[field] as Timestamp?;

    return (snap.docs.length, ts?.millisecondsSinceEpoch);
  }
}
