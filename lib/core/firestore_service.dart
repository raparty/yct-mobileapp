import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static void init() {
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  static Future<List<Magazine>> fetchMagazines() async {
    try {
      // Simple query — no composite index needed
      final snap = await _db.collection('magazines')
          .where('is_published', isEqualTo: true)
          .get();
      final list = snap.docs.map((d) => Magazine.fromFirestore(d)).toList();
      // Sort in Dart instead of Firestore
      list.sort((a, b) {
        final y = b.year.compareTo(a.year);
        return y != 0 ? y : b.month.compareTo(a.month);
      });
      return list;
    } catch (e) {
      print('fetchMagazines error: $e');
      return [];
    }
  }

  static Future<List<Book>> fetchBooks() async {
    try {
      final snap = await _db.collection('books')
          .where('is_published', isEqualTo: true)
          .get();
      final list = snap.docs.map((d) => Book.fromFirestore(d)).toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    } catch (e) {
      print('fetchBooks error: $e');
      return [];
    }
  }

  static Future<List<AudioTrack>> fetchAudio() async {
    try {
      final snap = await _db.collection('audio')
          .where('is_published', isEqualTo: true)
          .get();
      final list = snap.docs.map((d) => AudioTrack.fromFirestore(d)).toList();
      list.sort((a, b) => a.title.compareTo(b.title));
      return list;
    } catch (e) {
      print('fetchAudio error: $e');
      return [];
    }
  }

  static Future<AppSettings> fetchSettings() async {
    try {
      final doc = await _db.collection('settings').doc('main').get();
      if (doc.exists) return AppSettings.fromFirestore(doc);
      return AppSettings.defaults();
    } catch (e) {
      print('fetchSettings error: $e');
      return AppSettings.defaults();
    }
  }

  // Fetch WITHOUT any filter — useful for debugging
  static Future<int> countAll(String collection) async {
    try {
      final snap = await _db.collection(collection).get();
      return snap.docs.length;
    } catch (e) {
      return -1;
    }
  }
}
