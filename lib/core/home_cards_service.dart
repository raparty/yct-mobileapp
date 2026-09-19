// ─────────────────────────────────────────
// YCT — Home Cards Service
// Fetches card images and config from
// Firestore settings/home_cards
// Update via admin panel — no code change needed
// ─────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'constants.dart';

class HomeCard {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool enabled;

  const HomeCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.enabled,
  });

  factory HomeCard.fromFirestore(String id, Map<String, dynamic> d) => HomeCard(
    id:       id,
    title:    d['title']    as String? ?? '',
    subtitle: d['subtitle'] as String? ?? '',
    imageUrl: d['image_url'] as String? ?? '',
    enabled:  d['enabled']  as bool?   ?? true,
  );
}

class HomeCardsService {
  static final _db = FirebaseFirestore.instance;
  static const _timeout = Duration(seconds: 10);
  static List<HomeCard>? _cache;

  // Default cards — shown if Firestore unavailable
  static List<HomeCard> _defaults() => [
    HomeCard(
      id: 'publications',
      title: 'Publications',
      subtitle: 'Books & Magazines',
      imageUrl: '${R2Config.baseUrl}/images/cards/publications.jpg',
      enabled: true),
    HomeCard(
      id: 'gurudev',
      title: 'About Gurudev',
      subtitle: 'Life & Teachings',
      imageUrl: '${R2Config.baseUrl}/images/cards/gurudev.jpg',
      enabled: true),
    HomeCard(
      id: 'programs',
      title: 'Programs',
      subtitle: 'Programmes',
      imageUrl: '${R2Config.baseUrl}/images/cards/programs.jpg',
      enabled: true),
    HomeCard(
      id: 'centers',
      title: 'Centers',
      subtitle: 'Find an Ashram',
      imageUrl: '${R2Config.baseUrl}/images/cards/centers.jpg',
      enabled: true),
  ];

  static Future<List<HomeCard>> fetch() async {
    if (_cache != null) return _cache!;
    try {
      final doc = await _db.collection('settings').doc('home_cards')
          .get().timeout(_timeout);
      if (!doc.exists || doc.data() == null) {
        _cache = _defaults();
        return _cache!;
      }
      final data = doc.data()!;
      final cards = <HomeCard>[];
      for (final id in ['publications','gurudev','programs','centers']) {
        if (data[id] is Map) {
          cards.add(HomeCard.fromFirestore(id, Map<String,dynamic>.from(data[id])));
        }
      }
      _cache = cards.isEmpty ? _defaults() : cards;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      _cache = _defaults();
    }
    return _cache!;
  }

  static void clearCache() => _cache = null;
}
