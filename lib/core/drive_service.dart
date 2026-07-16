import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriveAudioFile {
  final String id;
  final String name;
  final String displayName;

  const DriveAudioFile({
    required this.id,
    required this.name,
    required this.displayName,
  });

  // Direct streaming URL for audioplayers — works for publicly shared files
  // Uses the export=view format which returns the actual file bytes
  String get streamUrl =>
      'https://drive.google.com/uc?export=view&id=$id';

  // Fallback: open in browser
  String get browserUrl =>
      'https://drive.google.com/file/d/$id/view';

  static String _cleanName(String filename) {
    String n = filename.replaceAll(RegExp(r'\.(mp3|m4a|wav|ogg|aac)$', caseSensitive: false), '');
    n = n.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    return n.split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  factory DriveAudioFile.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    return DriveAudioFile(id: id, name: name, displayName: _cleanName(name));
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DriveService {
  // Your audio folder ID — set from the Colab setup
  static const String audiofolderId = '1Rf9pGQeIf2nyiR7oXOkUX8f52APSwbE3';

  static const _cacheKey = 'drive_audio_v2';
  static const _cacheExpiry = Duration(hours: 2);

  static Future<List<DriveAudioFile>> fetchAudioFiles() async {
    // Try cache first
    final cached = await _getCached();
    if (cached != null && cached.isNotEmpty) return cached;

    // Method 1: Google Drive API v3 (public API key — read-only for public folders)
    final files = await _fetchViaApi();
    if (files.isNotEmpty) {
      await _setCache(files);
      return files;
    }

    return [];
  }

  static Future<List<DriveAudioFile>> _fetchViaApi() async {
    try {
      // Google Drive API v3 — lists files in a public folder
      // Using a public API key that only allows read access to Drive metadata
      const apiKey = 'AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY';
      final query = Uri.encodeComponent("'$audiofolderId' in parents and trashed=false");
      final fields = Uri.encodeComponent('files(id,name,mimeType)');
      final url = 'https://www.googleapis.com/drive/v3/files'
          '?q=$query&fields=$fields&orderBy=name&pageSize=1000&key=$apiKey';

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final filesList = data['files'] as List? ?? [];
        final audioExtensions = RegExp(r'\.(mp3|m4a|wav|ogg|aac)$', caseSensitive: false);
        return filesList
            .map((f) => DriveAudioFile.fromJson(f as Map<String, dynamic>))
            .where((f) => audioExtensions.hasMatch(f.name))
            .toList();
      }

      // If API key fails, try without key (works for some public folders)
      final url2 = 'https://www.googleapis.com/drive/v3/files'
          '?q=$query&fields=$fields&orderBy=name&pageSize=1000';
      final response2 = await http.get(Uri.parse(url2))
          .timeout(const Duration(seconds: 15));

      if (response2.statusCode == 200) {
        final data = jsonDecode(response2.body) as Map<String, dynamic>;
        final filesList = data['files'] as List? ?? [];
        final audioExtensions = RegExp(r'\.(mp3|m4a|wav|ogg|aac)$', caseSensitive: false);
        return filesList
            .map((f) => DriveAudioFile.fromJson(f as Map<String, dynamic>))
            .where((f) => audioExtensions.hasMatch(f.name))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<DriveAudioFile>?> _getCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt('${_cacheKey}_ts') ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts > _cacheExpiry.inMilliseconds) return null;
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List;
      return list.map((e) => DriveAudioFile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) { return null; }
  }

  static Future<void> _setCache(List<DriveAudioFile> files) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(files.map((f) => f.toJson()).toList()));
      await prefs.setInt('${_cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove('${_cacheKey}_ts');
  }
}
