// ─────────────────────────────────────────
// YCT — Firestore Service
// ─────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static const _timeout = Duration(seconds: 12);

  static void init() {
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  static Future<List<Magazine>> fetchMagazines() async {
    final snap = await _db.collection('magazines')
        .where('is_published', isEqualTo: true)
        .get()
        .timeout(_timeout);
    final list = snap.docs.map((d) => Magazine.fromFirestore(d)).toList();
    list.sort((a, b) {
      final y = b.year.compareTo(a.year);
      return y != 0 ? y : b.month.compareTo(a.month);
    });
    return list;
  }

  static Future<List<Book>> fetchBooks() async {
    final snap = await _db.collection('books')
        .where('is_published', isEqualTo: true)
        .get()
        .timeout(_timeout);
    final list = snap.docs.map((d) => Book.fromFirestore(d)).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// Fetch published audio tracks.
  /// [userEmail] — if provided, tracks with is_preview=true are included
  /// only when the email is in the 'preview_whitelist' Firestore document.
  static Future<List<AudioTrack>> fetchAudio({String? userEmail}) async {
    // Always fetch all published tracks; filter preview client-side.
    final snap = await _db.collection('audio')
        .where('is_published', isEqualTo: true)
        .get()
        .timeout(_timeout);

    // Check whether this user is whitelisted for preview content.
    bool previewAllowed = false;
    if (userEmail != null && userEmail.isNotEmpty) {
      try {
        final wlDoc = await _db.collection('settings')
            .doc('preview_whitelist')
            .get()
            .timeout(_timeout);
        if (wlDoc.exists) {
          final emails = List<String>.from(
              wlDoc.data()?['emails'] as List? ?? []);
          previewAllowed = emails
              .map((e) => e.trim().toLowerCase())
              .contains(userEmail.trim().toLowerCase());
        }
      } catch (_) {}
    }

    final list = snap.docs
        .map((d) => AudioTrack.fromFirestore(d))
        .where((t) => !t.isPreview || previewAllowed)
        .toList();

    // Latest first: tracks with uploadedAt sort by date desc,
    // those without uploadedAt fall back to title asc at the end.
    list.sort((a, b) {
      if (a.uploadedAt != null && b.uploadedAt != null) {
        return b.uploadedAt!.compareTo(a.uploadedAt!);
      }
      if (a.uploadedAt != null) return -1;
      if (b.uploadedAt != null) return 1;
      return a.title.compareTo(b.title);
    });
    return list;
  }

  static Future<AppSettings> fetchSettings() async {
    final doc = await _db.collection('settings').doc('main')
        .get()
        .timeout(_timeout);
    if (doc.exists) return AppSettings.fromFirestore(doc);
    return AppSettings.defaults();
  }

  static Future<int> countAll(String collection) async {
    final snap = await _db.collection(collection).get().timeout(_timeout);
    return snap.docs.length;
  }

  // ── Programs ──────────────────────────────────────────────────────────
  static Future<List<YearlyProgram>> fetchPrograms() async {
    final snap = await _db.collection('programs')
        .where('is_published', isEqualTo: true)
        .get()
        .timeout(_timeout);
    final list = snap.docs.map((d) => YearlyProgram.fromFirestore(d)).toList();
    list.sort((a, b) => a.startDate.compareTo(b.startDate));
    return list;
  }

  // ── Feedback ──────────────────────────────────────────────────────────
  static Future<void> submitFeedback({
    required String name,
    required String phone,
    required String message,
    required String category,
  }) async {
    await _db.collection('feedback').add({
      'name':         name,
      'phone':        phone,
      'message':      message,
      'category':     category,
      'submitted_at': FieldValue.serverTimestamp(),
      'read':         false,
    }).timeout(_timeout);
  }
}
