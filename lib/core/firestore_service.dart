// YCT App — Firestore Service
// Replaces Google Sheets completely
// Content managed via admin page, served from Firestore + R2

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // Enable offline persistence (works without internet after first load)
  static void init() {
    _db.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  static Future<List<Magazine>> fetchMagazines() async {
    try {
      final snap = await _db.collection('magazines')
          .where('is_published', isEqualTo: true)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .get();
      return snap.docs.map((d) => Magazine.fromFirestore(d)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> fetchBooks() async {
    try {
      final snap = await _db.collection('books')
          .where('is_published', isEqualTo: true)
          .orderBy('sort_order')
          .get();
      return snap.docs.map((d) => Book.fromFirestore(d)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<AudioTrack>> fetchAudio() async {
    try {
      final snap = await _db.collection('audio')
          .where('is_published', isEqualTo: true)
          .orderBy('title')
          .get();
      return snap.docs.map((d) => AudioTrack.fromFirestore(d)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<AppSettings> fetchSettings() async {
    try {
      final doc = await _db.collection('settings').doc('main').get();
      if (doc.exists) return AppSettings.fromFirestore(doc);
      return AppSettings.defaults();
    } catch (e) {
      return AppSettings.defaults();
    }
  }

  // Real-time streams — UI updates automatically when content changes
  static Stream<List<Magazine>> magazineStream() =>
      _db.collection('magazines')
          .where('is_published', isEqualTo: true)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => Magazine.fromFirestore(d)).toList());

  static Stream<List<AudioTrack>> audioStream() =>
      _db.collection('audio')
          .where('is_published', isEqualTo: true)
          .orderBy('title')
          .snapshots()
          .map((s) => s.docs.map((d) => AudioTrack.fromFirestore(d)).toList());
}
