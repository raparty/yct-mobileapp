import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Magazine {
  final String id;
  final String titleTelugu;
  final String titleEnglish;
  final int month, year, volume, pages;
  final String pdfPath, pdfUrl;
  final String coverImagePath, coverImageUrl; // NEW
  final bool isPublished;

  const Magazine({
    required this.id, required this.titleTelugu, required this.titleEnglish,
    required this.month, required this.year, required this.volume,
    required this.pages, required this.pdfPath, required this.pdfUrl,
    required this.coverImagePath, required this.coverImageUrl,
    required this.isPublished,
  });

  factory Magazine.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final pdfPath  = d['pdf_path']          as String? ?? '';
    final pdfUrl   = d['pdf_url']           as String? ?? (pdfPath.isNotEmpty ? R2Config.url(pdfPath) : '');
    final imgPath  = d['cover_image_path']  as String? ?? '';
    final imgUrl   = d['cover_image_url']   as String? ?? (imgPath.isNotEmpty ? R2Config.url(imgPath) : '');
    return Magazine(
      id:             doc.id,
      titleTelugu:    d['title_telugu']  as String? ?? '',
      titleEnglish:   d['title_english'] as String? ?? '',
      month:          (d['month']  as num?)?.toInt() ?? 0,
      year:           (d['year']   as num?)?.toInt() ?? 0,
      volume:         (d['volume'] as num?)?.toInt() ?? 0,
      pages:          (d['pages']  as num?)?.toInt() ?? 0,
      pdfPath:        pdfPath,   pdfUrl:        pdfUrl,
      coverImagePath: imgPath,   coverImageUrl: imgUrl,
      isPublished:    d['is_published'] as bool? ?? true,
    );
  }

  bool get hasPdf        => pdfUrl.isNotEmpty;
  bool get hasCoverImage => coverImageUrl.isNotEmpty;
  String get viewUrl     => pdfUrl;

  Color get coverColor {
    final idx = ((month - 1) % AppColors.coverColors.length).abs();
    return AppColors.coverColors[idx];
  }

  String get displayMonth {
    const m = ['','January','February','March','April','May','June',
                'July','August','September','October','November','December'];
    return month > 0 && month <= 12 ? m[month] : '';
  }
}

class Book {
  final String id, title, titleTelugu, language, description;
  final String pdfPath, pdfUrl;
  final String coverImagePath, coverImageUrl; // NEW
  final bool isPublished;
  final int sortOrder;

  const Book({
    required this.id, required this.title, required this.titleTelugu,
    required this.language, required this.description,
    required this.pdfPath, required this.pdfUrl,
    required this.coverImagePath, required this.coverImageUrl,
    required this.isPublished, required this.sortOrder,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final pdfPath = d['pdf_path']         as String? ?? '';
    final pdfUrl  = d['pdf_url']          as String? ?? (pdfPath.isNotEmpty ? R2Config.url(pdfPath) : '');
    final imgPath = d['cover_image_path'] as String? ?? '';
    final imgUrl  = d['cover_image_url']  as String? ?? (imgPath.isNotEmpty ? R2Config.url(imgPath) : '');
    return Book(
      id:             doc.id,
      title:          d['title']       as String? ?? '',
      titleTelugu:    d['title_telugu'] as String? ?? '',
      language:       d['language']    as String? ?? 'English',
      description:    d['description'] as String? ?? '',
      pdfPath:        pdfPath,  pdfUrl:        pdfUrl,
      coverImagePath: imgPath,  coverImageUrl: imgUrl,
      isPublished:    d['is_published'] as bool? ?? true,
      sortOrder:      (d['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasPdf        => pdfUrl.isNotEmpty;
  bool get hasCoverImage => coverImageUrl.isNotEmpty;

  Color get coverColor {
    if (language == 'Telugu')   return AppColors.blue;
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
      id:           doc.id,
      title:        d['title']        as String? ?? '',
      titleTelugu:  d['title_telugu'] as String? ?? '',
      topic:        d['topic']        as String? ?? '',
      audioPath:    path, audioUrl: url,
      fileName:     d['file_name']    as String? ?? '',
      year:         (d['year']          as num?)?.toInt() ?? 0,
      durationMins: (d['duration_mins'] as num?)?.toInt() ?? 0,
      isPublished:  d['is_published']   as bool? ?? true,
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
    required this.contactEmail, required this.websiteUrl,
    required this.whatsappNumber,
  });
  factory AppSettings.defaults() => const AppSettings(
    dailyQuote:       'The real yoga is not in the posture of the body, but in the stillness of the mind.',
    dailyQuoteTelugu: 'యోగం శరీరం యొక్క భంగిమలో కాదు, మనస్సు యొక్క నిశ్శబ్దంలో ఉంది.',
    contactEmail:     'info@yogaconsciousness.org',
    websiteUrl:       'https://www.yogaconsciousness.org',
    whatsappNumber:   '+918966268680',
  );
  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final def = AppSettings.defaults();
    return AppSettings(
      dailyQuote:       d['daily_quote']        as String? ?? def.dailyQuote,
      dailyQuoteTelugu: d['daily_quote_telugu'] as String? ?? def.dailyQuoteTelugu,
      contactEmail:     d['contact_email']      as String? ?? def.contactEmail,
      websiteUrl:       d['website_url']        as String? ?? def.websiteUrl,
      whatsappNumber:   d['whatsapp_number']    as String? ?? def.whatsappNumber,
    );
  }
}
