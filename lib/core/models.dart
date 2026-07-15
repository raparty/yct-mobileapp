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
    required this.id, required this.titleTelugu, required this.titleEnglish,
    required this.month, required this.year, required this.volume,
    required this.pages, required this.pdfUrl, required this.coverColor,
    required this.isPublished,
  });

  // GViz returns numbers as doubles like 7.0, 2026.0 — handle both int and double
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().split('.').first) ?? 0;
  }

  factory Magazine.fromRow(List<dynamic> row) {
    Color color = AppColors.primary;
    try {
      if (row.length > 8 && row[8] != null) {
        final hex = row[8].toString().replaceAll('#', '').trim();
        if (hex.length == 6) color = Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}

    return Magazine(
      id:           row[0]?.toString() ?? '',
      titleTelugu:  row[1]?.toString() ?? '',
      titleEnglish: row[2]?.toString() ?? '',
      month:        _parseInt(row.length > 3 ? row[3] : null),
      year:         _parseInt(row.length > 4 ? row[4] : null),
      volume:       _parseInt(row.length > 5 ? row[5] : null),
      pages:        _parseInt(row.length > 6 ? row[6] : null),
      pdfUrl:       row.length > 7 ? (row[7]?.toString() ?? '') : '',
      coverColor:   color,
      isPublished:  row.length > 9 ? row[9]?.toString().toUpperCase() == 'TRUE' : true,
    );
  }

  String get displayMonth {
    const months = ['','January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return month > 0 && month <= 12 ? months[month] : '';
  }

  // Extract Drive file ID from any Drive URL format
  static String? _extractDriveId(String url) {
    // Format 1: https://drive.google.com/file/d/FILE_ID/view
    var m = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (m != null) return m.group(1);
    // Format 2: https://drive.google.com/open?id=FILE_ID
    m = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
    if (m != null) return m.group(1);
    // Format 3: raw file ID
    if (RegExp(r'^[a-zA-Z0-9_-]{25,}$').hasMatch(url.trim())) return url.trim();
    return null;
  }

  // For in-app PDF viewer — use export=download with confirm bypass
  // Google Drive requires special handling to get actual PDF bytes
  String get directPdfUrl {
    final id = _extractDriveId(pdfUrl);
    if (id != null) {
      return 'https://drive.google.com/uc?export=download&id=$id&confirm=t&authuser=0';
    }
    return pdfUrl;
  }

  // For viewing in browser
  String get viewUrl {
    final id = _extractDriveId(pdfUrl);
    if (id != null) return 'https://drive.google.com/file/d/$id/view';
    return pdfUrl;
  }

  // Preview URL — Google Docs viewer (renders PDF in WebView)
  String get previewUrl {
    final id = _extractDriveId(pdfUrl);
    if (id != null) return 'https://drive.google.com/file/d/$id/preview';
    return pdfUrl;
  }

  bool get hasPdf => pdfUrl.isNotEmpty && pdfUrl != 'PASTE_GOOGLE_DRIVE_LINK_HERE';
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
    required this.id, required this.title, required this.titleTelugu,
    required this.language, required this.description, required this.pdfUrl,
    required this.coverColor, required this.isPublished, required this.sortOrder,
  });

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().split('.').first) ?? 0;
  }

  factory Book.fromRow(List<dynamic> row) {
    Color color = AppColors.primary;
    try {
      if (row.length > 6 && row[6] != null) {
        final hex = row[6].toString().replaceAll('#', '').trim();
        if (hex.length == 6) color = Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return Book(
      id: row[0]?.toString() ?? '',
      title: row[1]?.toString() ?? '',
      titleTelugu: row.length > 2 ? (row[2]?.toString() ?? '') : '',
      language: row.length > 3 ? (row[3]?.toString() ?? 'English') : 'English',
      description: row.length > 4 ? (row[4]?.toString() ?? '') : '',
      pdfUrl: row.length > 5 ? (row[5]?.toString() ?? '') : '',
      coverColor: color,
      isPublished: row.length > 7 ? row[7]?.toString().toUpperCase() == 'TRUE' : true,
      sortOrder: _parseInt(row.length > 8 ? row[8] : null),
    );
  }

  String get viewUrl {
    final m = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(pdfUrl);
    if (m != null) return 'https://drive.google.com/file/d/${m.group(1)}/view';
    return pdfUrl;
  }

  String get directPdfUrl {
    final m = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(pdfUrl);
    if (m != null) return 'https://drive.google.com/uc?export=download&id=${m.group(1)}&confirm=t';
    return pdfUrl;
  }

  bool get hasPdf => pdfUrl.isNotEmpty && pdfUrl != 'PASTE_GOOGLE_DRIVE_LINK_HERE';
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
    required this.id, required this.title, required this.titleTelugu,
    required this.topic, required this.year, required this.durationMins,
    required this.mp3Url, required this.isPublished,
  });

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().split('.').first) ?? 0;
  }

  factory AudioTrack.fromRow(List<dynamic> row) => AudioTrack(
    id: row[0]?.toString() ?? '',
    title: row[1]?.toString() ?? '',
    titleTelugu: row.length > 2 ? (row[2]?.toString() ?? '') : '',
    topic: row.length > 3 ? (row[3]?.toString() ?? '') : '',
    year: _parseInt(row.length > 4 ? row[4] : null),
    durationMins: _parseInt(row.length > 5 ? row[5] : null),
    mp3Url: row.length > 6 ? (row[6]?.toString() ?? '') : '',
    isPublished: row.length > 7 ? row[7]?.toString().toUpperCase() == 'TRUE' : true,
  );

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
}
