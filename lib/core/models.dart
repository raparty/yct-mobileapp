// ─────────────────────────────────────────
// YCT App — Data Models
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'constants.dart';

class Magazine {
  final String id;
  final String titleTelugu;
  final String titleEnglish;
  final int month;
  final int year;
  final int volume;
  final int pages;
  final String pdfUrl;
  final Color coverColor;
  final bool isPublished;

  const Magazine({
    required this.id,
    required this.titleTelugu,
    required this.titleEnglish,
    required this.month,
    required this.year,
    required this.volume,
    required this.pages,
    required this.pdfUrl,
    required this.coverColor,
    required this.isPublished,
  });

  factory Magazine.fromRow(List<dynamic> row) {
    Color color = AppColors.primary;
    try {
      final hex = row[8].toString().replaceAll('#', '');
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

    return Magazine(
      id:            row[0]?.toString() ?? '',
      titleTelugu:   row[1]?.toString() ?? '',
      titleEnglish:  row[2]?.toString() ?? '',
      month:         int.tryParse(row[3]?.toString() ?? '0') ?? 0,
      year:          int.tryParse(row[4]?.toString() ?? '0') ?? 0,
      volume:        int.tryParse(row[5]?.toString() ?? '0') ?? 0,
      pages:         int.tryParse(row[6]?.toString() ?? '0') ?? 0,
      pdfUrl:        row[7]?.toString() ?? '',
      coverColor:    color,
      isPublished:   row[9]?.toString().toUpperCase() == 'TRUE',
    );
  }

  String get displayMonth {
    const months = ['', 'January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return month > 0 && month <= 12 ? months[month] : '';
  }

  // Convert Google Drive share link to direct download link
  String get directPdfUrl {
    final uri = Uri.tryParse(pdfUrl);
    if (uri == null) return pdfUrl;
    if (pdfUrl.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'/d/([^/]+)').firstMatch(pdfUrl);
      if (match != null) {
        return 'https://drive.google.com/uc?export=download&id=${match.group(1)}';
      }
    }
    return pdfUrl;
  }

  // View link (opens in browser/PDF viewer)
  String get viewUrl {
    if (pdfUrl.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'/d/([^/]+)').firstMatch(pdfUrl);
      if (match != null) {
        return 'https://drive.google.com/file/d/${match.group(1)}/view';
      }
    }
    return pdfUrl;
  }
}

class Book {
  final String id;
  final String title;
  final String titleTelugu;
  final String language;
  final String description;
  final String pdfUrl;
  final Color coverColor;
  final bool isPublished;
  final int sortOrder;

  const Book({
    required this.id,
    required this.title,
    required this.titleTelugu,
    required this.language,
    required this.description,
    required this.pdfUrl,
    required this.coverColor,
    required this.isPublished,
    required this.sortOrder,
  });

  factory Book.fromRow(List<dynamic> row) {
    Color color = AppColors.primary;
    try {
      final hex = row[6].toString().replaceAll('#', '');
      color = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

    return Book(
      id:           row[0]?.toString() ?? '',
      title:        row[1]?.toString() ?? '',
      titleTelugu:  row[2]?.toString() ?? '',
      language:     row[3]?.toString() ?? 'English',
      description:  row[4]?.toString() ?? '',
      pdfUrl:       row[5]?.toString() ?? '',
      coverColor:   color,
      isPublished:  row[7]?.toString().toUpperCase() == 'TRUE',
      sortOrder:    int.tryParse(row[8]?.toString() ?? '0') ?? 0,
    );
  }

  String get viewUrl {
    if (pdfUrl.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'/d/([^/]+)').firstMatch(pdfUrl);
      if (match != null) {
        return 'https://drive.google.com/file/d/${match.group(1)}/view';
      }
    }
    return pdfUrl;
  }
}

class AudioTrack {
  final String id;
  final String title;
  final String titleTelugu;
  final String topic;
  final int year;
  final int durationMins;
  final String mp3Url;
  final bool isPublished;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.titleTelugu,
    required this.topic,
    required this.year,
    required this.durationMins,
    required this.mp3Url,
    required this.isPublished,
  });

  factory AudioTrack.fromRow(List<dynamic> row) {
    return AudioTrack(
      id:           row[0]?.toString() ?? '',
      title:        row[1]?.toString() ?? '',
      titleTelugu:  row[2]?.toString() ?? '',
      topic:        row[3]?.toString() ?? '',
      year:         int.tryParse(row[4]?.toString() ?? '0') ?? 0,
      durationMins: int.tryParse(row[5]?.toString() ?? '0') ?? 0,
      mp3Url:       row[6]?.toString() ?? '',
      isPublished:  row[7]?.toString().toUpperCase() == 'TRUE',
    );
  }

  String get formattedDuration {
    if (durationMins == 0) return '';
    final h = durationMins ~/ 60;
    final m = durationMins % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m} min';
  }
}

class AppSettings {
  final String dailyQuote;
  final String dailyQuoteTelugu;
  final String contactEmail;
  final String websiteUrl;
  final String whatsappNumber;

  const AppSettings({
    required this.dailyQuote,
    required this.dailyQuoteTelugu,
    required this.contactEmail,
    required this.websiteUrl,
    required this.whatsappNumber,
  });

  factory AppSettings.defaults() => const AppSettings(
    dailyQuote: 'The real yoga is not in the posture of the body, but in the stillness of the mind.',
    dailyQuoteTelugu: 'యోగం శరీరం యొక్క భంగిమలో కాదు, మనస్సు యొక్క నిశ్శబ్దంలో ఉంది.',
    contactEmail: 'info@yogaconsciousness.org',
    websiteUrl: 'https://www.yogaconsciousness.org',
    whatsappNumber: '+918966268680',
  );
}
