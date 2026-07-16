import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Magazine {
  final String id;
  final String titleTelugu;
  final String titleEnglish;
  final int month, year, volume, pages;
  final String pdfPath;   // R2 path e.g. publications/magazines/2026/2026-03-March.pdf
  final String pdfUrl;    // Full R2 URL
  final bool isPublished;

  const Magazine({
    required this.id, required this.titleTelugu, required this.titleEnglish,
    required this.month, required this.year, required this.volume,
    required this.pages, required this.pdfPath, required this.pdfUrl,
    required this.isPublished,
  });

  factory Magazine.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final path = d['pdf_path'] as String? ?? '';
    final url  = d['pdf_url']  as String? ?? (path.isNotEmpty ? R2Config.url(path) : '');
    return Magazine(
      id:           doc.id,
      titleTelugu:  d['title_telugu']  as String? ?? '',
      titleEnglish: d['title_english'] as String? ?? '',
      month:        (d['month']  as num?)?.toInt() ?? 0,
      year:         (d['year']   as num?)?.toInt() ?? 0,
      volume:       (d['volume'] as num?)?.toInt() ?? 0,
      pages:        (d['pages']  as num?)?.toInt() ?? 0,
      pdfPath:      path,
      pdfUrl:       url,
      isPublished:  d['is_published'] as bool? ?? true,
    );
  }

  Color get coverColor {
    final idx = ((month - 1) % AppColors.coverColors.length).abs();
    return AppColors.coverColors[idx];
  }

  String get displayMonth {
    const m = ['','January','February','March','April','May','June',
                'July','August','September','October','November','December'];
    return month > 0 && month <= 12 ? m[month] : '';
  }

  bool get hasPdf => pdfUrl.isNotEmpty;
}

class Book {
  final String id, title, titleTelugu, language, description, pdfPath, pdfUrl;
  final bool isPublished;
  final int sortOrder;

  const Book({
    required this.id, required this.title, required this.titleTelugu,
    required this.language, required this.description,
    required this.pdfPath, required this.pdfUrl,
    required this.isPublished, required this.sortOrder,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final path = d['pdf_path'] as String? ?? '';
    final url  = d['pdf_url']  as String? ?? (path.isNotEmpty ? R2Config.url(path) : '');
    return Book(
      id: doc.id, title: d['title'] as String? ?? '',
      titleTelugu: d['title_telugu'] as String? ?? '',
      language: d['language'] as String? ?? 'English',
      description: d['description'] as String? ?? '',
      pdfPath: path, pdfUrl: url,
      isPublished: d['is_published'] as bool? ?? true,
      sortOrder: (d['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Color get coverColor {
    if (language == 'Telugu') return AppColors.blue;
    if (language == 'Bilingual') return AppColors.purple;
    return AppColors.primary;
  }
}

class AudioTrack {
  final String id, title, titleTelugu, topic, audioPath, audioUrl, fileName;
  final int year, durationMins;
  final bool isPublished;

  const AudioTrack({
    required this.id, required this.title, required this.titleTelugu,
    required this.topic, required this.audioPath, required this.audioUrl,
    required this.fileName, required this.year, required this.durationMins,
    required this.isPublished,
  });

  factory AudioTrack.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final path = d['audio_path'] as String? ?? '';
    final url  = d['audio_url']  as String? ?? (path.isNotEmpty ? R2Config.url(path) : '');
    return AudioTrack(
      id: doc.id,
      title:        d['title']       as String? ?? '',
      titleTelugu:  d['title_telugu'] as String? ?? '',
      topic:        d['topic']       as String? ?? '',
      audioPath:    path, audioUrl: url,
      fileName:     d['file_name']   as String? ?? '',
      year:         (d['year']         as num?)?.toInt() ?? 0,
      durationMins: (d['duration_mins'] as num?)?.toInt() ?? 0,
      isPublished:  d['is_published'] as bool? ?? true,
    );
  }

  String get formattedDuration {
    if (durationMins == 0) return '';
    final h = durationMins ~/ 60; final m = durationMins % 60;
    return h > 0 ? '${h}h ${m}m' : '$m min';
  }
}

class AppSettings {
  final String dailyQuote, dailyQuoteTelugu, contactEmail, websiteUrl, whatsappNumber;
  const AppSettings({
    required this.dailyQuote, required this.dailyQuoteTelugu,
    required this.contactEmail, required this.websiteUrl, required this.whatsappNumber,
  });
  factory AppSettings.defaults() => const AppSettings(
    dailyQuote: 'The real yoga is not in the posture of the body, but in the stillness of the mind.',
    dailyQuoteTelugu: 'యోగం శరీరం యొక్క భంగిమలో కాదు, మనస్సు యొక్క నిశ్శబ్దంలో ఉంది.',
    contactEmail: 'yctdesk@gmail.com',
    websiteUrl: 'https://www.yogaconsciousness.org',
    whatsappNumber: '+918966268680',
  );
  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppSettings(
      dailyQuote:       d['daily_quote']        as String? ?? AppSettings.defaults().dailyQuote,
      dailyQuoteTelugu: d['daily_quote_telugu'] as String? ?? AppSettings.defaults().dailyQuoteTelugu,
      contactEmail:     d['contact_email']      as String? ?? AppSettings.defaults().contactEmail,
      websiteUrl:       d['website_url']        as String? ?? AppSettings.defaults().websiteUrl,
      whatsappNumber:   d['whatsapp_number']    as String? ?? AppSettings.defaults().whatsappNumber,
    );
  }
}
