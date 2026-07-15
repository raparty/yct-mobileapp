// ─────────────────────────────────────────
// YCT App — Google Sheets Data Service
// Reads directly from Google Sheets (no backend needed)
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'models.dart';

class SheetsService {
  // Parse the Google Sheets GViz JSON response
  static List<List<dynamic>> _parseRows(String rawBody) {
    // GViz wraps response in: google.visualization.Query.setResponse({...})
    final start = rawBody.indexOf('{');
    final end   = rawBody.lastIndexOf('}') + 1;
    if (start == -1 || end == 0) return [];

    final json = jsonDecode(rawBody.substring(start, end));
    final rows = json['table']?['rows'] as List? ?? [];

    return rows.map<List<dynamic>>((row) {
      final cells = row['c'] as List? ?? [];
      return cells.map((cell) => cell?['v']).toList();
    }).toList();
  }

  static Future<List<Magazine>> fetchMagazines() async {
    try {
      final url = SheetConfig.tabUrl(SheetConfig.magazinesTab);
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final rows = _parseRows(response.body);
      // Skip header row (index 0)
      return rows
          .skip(1)
          .where((r) => r.isNotEmpty && r[0] != null)
          .map((r) => Magazine.fromRow(r))
          .where((m) => m.isPublished && m.id.isNotEmpty)
          .toList()
        ..sort((a, b) {
          final yearCmp = b.year.compareTo(a.year);
          if (yearCmp != 0) return yearCmp;
          return b.month.compareTo(a.month);
        });
    } catch (e) {
      return [];
    }
  }

  static Future<List<Book>> fetchBooks() async {
    try {
      final url = SheetConfig.tabUrl(SheetConfig.booksTab);
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final rows = _parseRows(response.body);
      return rows
          .skip(1)
          .where((r) => r.isNotEmpty && r[0] != null)
          .map((r) => Book.fromRow(r))
          .where((b) => b.isPublished && b.id.isNotEmpty)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (e) {
      return [];
    }
  }

  static Future<List<AudioTrack>> fetchAudio() async {
    try {
      final url = SheetConfig.tabUrl(SheetConfig.audioTab);
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final rows = _parseRows(response.body);
      return rows
          .skip(1)
          .where((r) => r.isNotEmpty && r[0] != null)
          .map((r) => AudioTrack.fromRow(r))
          .where((a) => a.isPublished && a.id.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<AppSettings> fetchSettings() async {
    try {
      final url = SheetConfig.tabUrl(SheetConfig.settingsTab);
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return AppSettings.defaults();

      final rows = _parseRows(response.body);
      final Map<String, String> settings = {};

      for (final row in rows.skip(1)) {
        if (row.length >= 2 && row[0] != null && row[1] != null) {
          settings[row[0].toString()] = row[1].toString();
        }
      }

      return AppSettings(
        dailyQuote:       settings['daily_quote']        ?? AppSettings.defaults().dailyQuote,
        dailyQuoteTelugu: settings['daily_quote_telugu'] ?? AppSettings.defaults().dailyQuoteTelugu,
        contactEmail:     settings['contact_email']      ?? AppSettings.defaults().contactEmail,
        websiteUrl:       settings['website_url']        ?? AppSettings.defaults().websiteUrl,
        whatsappNumber:   settings['whatsapp_number']    ?? AppSettings.defaults().whatsappNumber,
      );
    } catch (e) {
      return AppSettings.defaults();
    }
  }
}
