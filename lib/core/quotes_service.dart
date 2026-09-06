// ─────────────────────────────────────────
// YCT — Quotes Service
// Fetches daily quotes from Firestore.
// Falls back to built-in quotes if Firestore unavailable.
//
// Firestore: quotes collection
//   text (string)        — English quote
//   text_telugu (string) — Telugu quote
//   author (string)      — defaults to Gurudev
//   sort_order (number)  — optional
// ─────────────────────────────────────────
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class DailyQuote {
  final String text;
  final String textTelugu;
  final String author;

  const DailyQuote({
    required this.text,
    required this.textTelugu,
    required this.author,
  });

  factory DailyQuote.fromFirestore(Map<String, dynamic> d) => DailyQuote(
    text:       d['text']        as String? ?? '',
    textTelugu: d['text_telugu'] as String? ?? '',
    author:     d['author']      as String? ?? 'Yogacharya Sri Raparthi Rama Rao',
  );
}

class QuotesService {
  static final _db = FirebaseFirestore.instance;
  static const _timeout = Duration(seconds: 10);
  static List<DailyQuote>? _cache;

  static const _fallbackQuotes = [
    DailyQuote(
      text: 'The real yoga is not in the posture of the body, but in the stillness of the mind.',
      textTelugu: 'నిజమైన యోగం శరీరం యొక్క భంగిమలో కాదు, మనస్సు యొక్క నిశ్శబ్దంలో ఉంది.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
    DailyQuote(
      text: 'Self-realisation is not a destination to reach, but a truth to be recognised.',
      textTelugu: 'ఆత్మసాక్షాత్కారం చేరుకోవలసిన గమ్యం కాదు, గుర్తించవలసిన సత్యం.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
    DailyQuote(
      text: 'Integration of four paths — Karma Yoga, Raja Yoga, Bhakti Yoga and Jnana Yoga — leads to liberation.',
      textTelugu: 'కర్మ యోగ, రాజ యోగ, భక్తి యోగ మరియు జ్ఞాన యోగల సమన్వయం మోక్షానికి నడిపిస్తుంది.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
    DailyQuote(
      text: 'The Guru is not a person but a principle — the light of knowledge that removes darkness.',
      textTelugu: 'గురువు వ్యక్తి కాదు, సూత్రం — చీకటిని తొలగించే జ్ఞాన జ్యోతి.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
    DailyQuote(
      text: 'Pranayama purifies the nadis and prepares the mind for deeper meditation.',
      textTelugu: 'ప్రాణాయామం నాడులను శుద్ధి చేసి మనస్సును లోతైన ధ్యానానికి సిద్ధం చేస్తుంది.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
    DailyQuote(
      text: 'Viveka — discriminative wisdom — is the most essential quality on the spiritual path.',
      textTelugu: 'వివేకం ఆధ్యాత్మిక మార్గంలో అత్యంత అవసరమైన గుణం.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
    DailyQuote(
      text: 'The body is the temple; keep it pure so the Divine may dwell within.',
      textTelugu: 'శరీరం ఆలయం; దానిని పవిత్రంగా ఉంచండి, తద్వారా దివ్యత్వం లోపల నివసించగలదు.',
      author: 'Yogacharya Sri Raparthi Rama Rao'),
  ];

  static Future<List<DailyQuote>> _fetchAll() async {
    if (_cache != null) return _cache!;
    try {
      final snap = await _db.collection('quotes').get().timeout(_timeout);
      final list = snap.docs
          .map((d) => DailyQuote.fromFirestore(d.data()))
          .where((q) => q.text.isNotEmpty)
          .toList();
      _cache = list.isEmpty ? List.from(_fallbackQuotes) : list;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      _cache = List.from(_fallbackQuotes);
    }
    return _cache!;
  }

  /// Same quote for everyone on the same day
  static Future<DailyQuote> getTodaysQuote() async {
    final quotes = await _fetchAll();
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return quotes[dayOfYear % quotes.length];
  }

  /// Random quote — for refresh
  static Future<DailyQuote> getRandomQuote() async {
    final quotes = await _fetchAll();
    return quotes[Random().nextInt(quotes.length)];
  }

  static void clearCache() => _cache = null;
}
