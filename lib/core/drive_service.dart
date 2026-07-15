// ─────────────────────────────────────────
// YCT App — Google Drive Auto-Scanner
// Lists MP3 files directly from a Drive folder
// No manual Sheet entry needed for audio!
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriveAudioFile {
  final String id;
  final String name;
  final String displayName; // cleaned up name
  final String streamUrl;
  final String downloadUrl;

  const DriveAudioFile({
    required this.id,
    required this.name,
    required this.displayName,
    required this.streamUrl,
    required this.downloadUrl,
  });

  // Clean file name for display — remove extension, replace underscores/hyphens
  static String _cleanName(String filename) {
    String name = filename.replaceAll(RegExp(r'\.(mp3|m4a|wav|ogg)$', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'[_\-]+'), ' ');
    name = name.trim();
    // Capitalize first letter of each word
    return name.split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  factory DriveAudioFile.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final name = json['name'] as String? ?? '';
    return DriveAudioFile(
      id: id,
      name: name,
      displayName: _cleanName(name),
      streamUrl: 'https://drive.google.com/file/d/$id/view',
      downloadUrl: 'https://drive.google.com/uc?export=download&id=$id&confirm=t',
    );
  }
}

class DriveService {
  // Your Google Drive folder ID for audio/discourses
  // Set this to the folder ID from your Drive setup
  static const String audiofolderId = '1Rf9pGQeIf2nyiR7oXOkUX8f52APSwbE3';

  static const _cacheKey = 'drive_audio_files';
  static const _cacheExpiry = Duration(hours: 2);

  // Uses Google Drive's public sharing to list files in a folder
  // The folder must be shared publicly (which we did in the Colab setup)
  static Future<List<DriveAudioFile>> fetchAudioFiles() async {
    try {
      // Check cache first
      final cached = await _getCached();
      if (cached != null) return cached;

      // Google Drive folder listing via public API (no auth needed for public folders)
      final url = 'https://www.googleapis.com/drive/v3/files'
          '?q=%27$audiofolderId%27+in+parents+and+mimeType+contains+%27audio%27+and+trashed%3Dfalse'
          '&fields=files(id,name,mimeType,size)'
          '&orderBy=name'
          '&pageSize=1000'
          '&key=AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY'; // public API key for Drive listing

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = (data['files'] as List? ?? [])
            .map((f) => DriveAudioFile.fromJson(f as Map<String, dynamic>))
            .where((f) => f.name.toLowerCase().endsWith('.mp3') ||
                         f.name.toLowerCase().endsWith('.m4a') ||
                         f.name.toLowerCase().endsWith('.wav'))
            .toList();

        await _setCache(files);
        return files;
      }

      // Fallback: try alternative listing method
      return await _fetchViaShareLink();
    } catch (e) {
      return await _fetchViaShareLink();
    }
  }

  // Alternative: scrape the public folder share page
  // This works even without an API key
  static Future<List<DriveAudioFile>> _fetchViaShareLink() async {
    try {
      final cached = await _getCached();
      if (cached != null) return cached;

      // Use the GDrive folder URL format that returns JSON
      final url = 'https://drive.google.com/drive/folders/$audiofolderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Parse the folder contents from the response
        // Drive embeds file data as JSON in the HTML
        final body = response.body;
        final files = <DriveAudioFile>[];

        // Extract file IDs and names from Drive's embedded data
        final regex = RegExp(r'\["([a-zA-Z0-9_-]{25,})".*?"([^"]+\.mp3)"', multiLine: true);
        for (final match in regex.allMatches(body)) {
          final id = match.group(1)!;
          final name = match.group(2)!;
          files.add(DriveAudioFile.fromJson({'id': id, 'name': name}));
        }

        if (files.isNotEmpty) await _setCache(files);
        return files;
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
      await prefs.setString(_cacheKey, jsonEncode(files.map((f) => {
        'id': f.id, 'name': f.name,
      }).toList()));
      await prefs.setInt('${_cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove('${_cacheKey}_ts');
  }
}
