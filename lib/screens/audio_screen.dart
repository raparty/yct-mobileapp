// Audio screen — auto-reads MP3 files directly from Google Drive folder
// No manual Google Sheet entry needed!

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants.dart';
import '../core/drive_service.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  List<DriveAudioFile> _files = [];
  List<DriveAudioFile> _filtered = [];
  bool _loading = true;
  bool _folderConfigured = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _folderConfigured = DriveService.audiofolderId != 'REPLACE_WITH_YOUR_AUDIO_FOLDER_ID';
    if (_folderConfigured) _load();
    else setState(() => _loading = false);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final files = await DriveService.fetchAudioFiles();
    if (mounted) setState(() {
      _files = files;
      _filtered = files;
      _loading = false;
    });
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      _filtered = q.isEmpty
          ? _files
          : _files.where((f) =>
              f.displayName.toLowerCase().contains(q.toLowerCase()) ||
              f.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  Future<void> _play(DriveAudioFile file) async {
    final uri = Uri.parse(file.streamUrl);
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
        actions: [
          if (_folderConfigured && !_loading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () async {
                await DriveService.clearCache();
                await _load();
              },
            ),
        ],
      ),
      body: !_folderConfigured
          ? _notConfigured()
          : _loading
              ? const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Scanning Drive folder for audio files...',
                      style: TextStyle(color: AppColors.textMid)),
                  ]))
              : Column(children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search discourses...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                    ),
                  ),
                  // Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(children: [
                      Text('${_filtered.length} discourses',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMid, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                  // List
                  Expanded(
                    child: _filtered.isEmpty
                        ? _empty()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) => _TrackTile(
                              file: _filtered[i],
                              index: i + 1,
                              onPlay: () => _play(_filtered[i]),
                              onShare: () => Share.share(
                                '${_filtered[i].displayName}\n${_filtered[i].streamUrl}\n\nYoga Consciousness Trust\n${AppStrings.website}'),
                            ),
                          ),
                  ),
                ]),
    );
  }

  Widget _notConfigured() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
        decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
        child: const Icon(Icons.headphones_outlined, size: 40, color: AppColors.primary)),
      const SizedBox(height: 20),
      const Text('Audio Setup Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('To enable audio:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('1. Open lib/core/drive_service.dart\n'
            '2. Find the line:\n   audiofolderId = \'REPLACE_WITH...\'\n'
            '3. Replace with your Drive folder ID\n'
            '   (the ID of your audio/discourses/ folder)\n'
            '4. Drop all your MP3 files into that folder\n'
            '5. The app will auto-display them!',
            style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.6)),
          const SizedBox(height: 12),
          const Text('No manual entry needed — just drop MP3s into Drive!',
            style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ])),
    ]),
  ));

  Widget _empty() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.music_off_outlined, size: 48, color: AppColors.textMuted),
      const SizedBox(height: 16),
      Text(_search.isEmpty
          ? 'No audio files found in Drive folder.\nDrop MP3 files into your Google Drive audio/discourses/ folder.'
          : 'No results for "$_search"',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMid, height: 1.5)),
    ]),
  ));
}

class _TrackTile extends StatelessWidget {
  final DriveAudioFile file;
  final int index;
  final VoidCallback onPlay;
  final VoidCallback onShare;

  const _TrackTile({
    required this.file, required this.index,
    required this.onPlay, required this.onShare,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: GestureDetector(
          onTap: onPlay,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 26))),
        title: Text(file.displayName,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark),
          maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('#$index · Tap to play', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        trailing: IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textMuted, size: 20),
          onPressed: onShare),
        onTap: onPlay,
      ),
    );
  }
}
