// Audio screen — v1 placeholder
// Audio packages removed to simplify build.
// Will be added in v2 when discourses are organised.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/sheets_service.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> _playTrack(AudioTrack track) async {
    // Open MP3 directly in device's native player / browser
    final uri = Uri.parse(track.mp3Url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Audio Discourses'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary))
          : _tracks.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _TrackCard(
                    track: _tracks[i],
                    onTap: () => _playTrack(_tracks[i]),
                    onShare: () => Share.share(
                      '${_tracks[i].title}\n${_tracks[i].mp3Url}'),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headphones_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Audio Coming Soon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
            const SizedBox(height: 10),
            const Text(
              'Gurudev\'s discourses are being organised and '
              'will be available here soon.\n\n'
              'To add audio: upload MP3s to Google Drive and '
              'add rows to the audio tab in your Google Sheet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13,
                  color: AppColors.textLight, height: 1.6)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(AppStrings.website),
                mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.language, color: AppColors.primary),
              label: const Text('Visit Website',
                style: TextStyle(color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final AudioTrack track;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _TrackCard({
    required this.track,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        leading: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow,
                color: AppColors.primary, size: 24),
          ),
        ),
        title: Text(track.title,
          style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w500, color: AppColors.textDark),
          maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (track.titleTelugu.isNotEmpty)
              Text(track.titleTelugu,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMid)),
            const SizedBox(height: 4),
            Row(children: [
              if (track.topic.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(track.topic,
                    style: const TextStyle(fontSize: 9,
                        color: AppColors.primaryDark)),
                ),
                const SizedBox(width: 6),
              ],
              if (track.formattedDuration.isNotEmpty)
                Text(track.formattedDuration,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textLight)),
            ]),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.share_outlined,
              color: AppColors.textMuted, size: 20),
          onPressed: onShare,
        ),
        onTap: onTap,
      ),
    );
  }
}
