// ─────────────────────────────────────────
// YCT — Firestore Service (R1: timeouts + error handling)
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

  static Future<List<AudioTrack>> fetchAudio() async {
    final snap = await _db.collection('audio')
        .where('is_published', isEqualTo: true)
        .get()
        .timeout(_timeout);
    final list = snap.docs.map((d) => AudioTrack.fromFirestore(d)).toList();
    list.sort((a, b) => a.title.compareTo(b.title));
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
}
