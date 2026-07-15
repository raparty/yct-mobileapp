import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'models.dart';

class SheetsService {
  static const _cacheExpiry = Duration(hours: 6);

  static Future<String?> _getCached(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('${key}_ts') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - ts > _cacheExpiry.inMilliseconds) return null;
    return prefs.getString(key);
  }

  static Future<void> _setCache(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  static List<List<dynamic>> _parseRows(String rawBody) {
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

  static Future<String?> _fetch(String tab) async {
    try {
      final cached = await _getCached(tab);
      if (cached != null) return cached;
      final response = await http.get(Uri.parse(SheetConfig.tabUrl(tab)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      await _setCache(tab, response.body);
      return response.body;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tab);
    }
  }

  static Future<List<Magazine>> fetchMagazines() async {
    final body = await _fetch(SheetConfig.magazinesTab);
    if (body == null) return [];
    return _parseRows(body).skip(1)
        .where((r) => r.isNotEmpty && r[0] != null)
        .map((r) => Magazine.fromRow(r))
        .where((m) => m.isPublished && m.id.isNotEmpty)
        .toList()
      ..sort((a, b) { final y = b.year.compareTo(a.year); return y != 0 ? y : b.month.compareTo(a.month); });
  }

  static Future<List<Book>> fetchBooks() async {
    final body = await _fetch(SheetConfig.booksTab);
    if (body == null) return [];
    return _parseRows(body).skip(1)
        .where((r) => r.isNotEmpty && r[0] != null)
        .map((r) => Book.fromRow(r))
        .where((b) => b.isPublished && b.id.isNotEmpty)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  static Future<List<AudioTrack>> fetchAudio() async {
    final body = await _fetch(SheetConfig.audioTab);
    if (body == null) return [];
    return _parseRows(body).skip(1)
        .where((r) => r.isNotEmpty && r[0] != null)
        .map((r) => AudioTrack.fromRow(r))
        .where((a) => a.isPublished && a.id.isNotEmpty)
        .toList();
  }

  static Future<AppSettings> fetchSettings() async {
    final body = await _fetch(SheetConfig.settingsTab);
    if (body == null) return AppSettings.defaults();
    final Map<String, String> s = {};
    for (final row in _parseRows(body).skip(1)) {
      if (row.length >= 2 && row[0] != null && row[1] != null) {
        s[row[0].toString()] = row[1].toString();
      }
    }
    return AppSettings(
      dailyQuote: s['daily_quote'] ?? AppSettings.defaults().dailyQuote,
      dailyQuoteTelugu: s['daily_quote_telugu'] ?? AppSettings.defaults().dailyQuoteTelugu,
      contactEmail: s['contact_email'] ?? AppSettings.defaults().contactEmail,
      websiteUrl: s['website_url'] ?? AppSettings.defaults().websiteUrl,
      whatsappNumber: s['whatsapp_number'] ?? AppSettings.defaults().whatsappNumber,
    );
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final tab in [SheetConfig.magazinesTab, SheetConfig.booksTab, SheetConfig.audioTab, SheetConfig.settingsTab]) {
      await prefs.remove(tab);
      await prefs.remove('${tab}_ts');
    }
  }
}
