import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/sheets_service.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  List<AudioTrack> _tracks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tracks = await SheetsService.fetchAudio();
    if (mounted) setState(() { _tracks = tracks; _loading = false; });
  }

  Future<void> _play(AudioTrack track) async {
    final uri = Uri.parse(track.mp3Url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Audio Discourses'), backgroundColor: AppColors.primary),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _tracks.isEmpty ? _empty() : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _tracks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _card(_tracks[i]),
            ),
    );
  }

  Widget _empty() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.headphones_outlined, size: 40, color: AppColors.primary)),
        const SizedBox(height: 20),
        const Text('Audio Coming Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 10),
        const Text("Gurudev's discourses are being organised and will appear here soon.\n\nUpload MP3s to Google Drive and add rows to the audio tab in your Google Sheet.",
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.6)),
      ]),
    ));
  }

  Widget _card(AudioTrack track) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: GestureDetector(
          onTap: () => _play(track),
          child: Container(width: 44, height: 44,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 24))),
        title: Text(track.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: track.titleTelugu.isNotEmpty ? Text(track.titleTelugu, style: const TextStyle(fontSize: 11, color: AppColors.textMid)) : null,
        trailing: IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textMuted, size: 20),
          onPressed: () => Share.share('${track.title}\n${track.mp3Url}')),
        onTap: () => _play(track),
      ),
    );
  }
}
