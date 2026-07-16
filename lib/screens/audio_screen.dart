// Audio screen — in-app streaming using audioplayers
// Reads file list directly from Google Drive folder
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

  // Player state
  final AudioPlayer _player = AudioPlayer();
  DriveAudioFile? _currentFile;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _buffering = false;

  @override
  void initState() {
    super.initState();
    _folderConfigured = DriveService.audiofolderId != 'REPLACE_WITH_YOUR_AUDIO_FOLDER_ID';
    if (_folderConfigured) _load();
    else setState(() => _loading = false);

    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
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
      _filtered = q.isEmpty ? _files
          : _files.where((f) => f.displayName.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  Future<void> _playOrPause(DriveAudioFile file) async {
    if (_currentFile?.id == file.id) {
      // Toggle play/pause for current track
      if (_playerState == PlayerState.playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      return;
    }

    // Play new track
    setState(() { _currentFile = file; _buffering = true; _position = Duration.zero; });
    try {
      // Use the direct stream URL for audioplayers
      final streamUrl = 'https://drive.google.com/uc?export=open&id=${file.id}';
      await _player.play(UrlSource(streamUrl));
      setState(() => _buffering = false);
    } catch (e) {
      setState(() => _buffering = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not play "${file.displayName}". Check Drive sharing settings.'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() { _currentFile = null; _position = Duration.zero; });
  }

  Future<void> _seek(double value) async {
    await _player.seek(Duration(seconds: value.toInt()));
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
              onPressed: () async { await DriveService.clearCache(); _load(); }),
        ],
      ),
      body: !_folderConfigured
          ? _setupScreen()
          : _loading
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Scanning Google Drive for audio...', style: TextStyle(color: AppColors.textMid)),
                ]))
              : Column(children: [
                  // Mini player
                  if (_currentFile != null) _miniPlayer(),
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search discourses...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                        filled: true, fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(children: [
                      Text('${_filtered.length} discourses',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMid, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? _emptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final file = _filtered[i];
                              final isPlaying = _currentFile?.id == file.id && _playerState == PlayerState.playing;
                              final isCurrent = _currentFile?.id == file.id;
                              return _TrackTile(
                                file: file, index: i + 1,
                                isPlaying: isPlaying, isCurrent: isCurrent,
                                isBuffering: isCurrent && _buffering,
                                onTap: () => _playOrPause(file),
                                onShare: () => Share.share(
                                  '${file.displayName}\n\nYoga Consciousness Trust\n${AppStrings.website}'),
                              );
                            },
                          ),
                  ),
                ]),
    );
  }

  Widget _miniPlayer() {
    final file = _currentFile!;
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inSeconds > 0
        ? _position.inSeconds / _duration.inSeconds
        : 0.0;

    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(children: [
        Row(children: [
          // Artwork placeholder
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.music_note, color: AppColors.saffron, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(file.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(_buffering ? 'Buffering...' : '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
          ])),
          // Play/Pause
          IconButton(
            icon: _buffering
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
            onPressed: _buffering ? null : () => _playOrPause(file)),
          // Stop
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.white70, size: 22),
            onPressed: _stop),
        ]),
        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            trackHeight: 2,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: _duration.inSeconds > 0
                ? (v) => _seek(v * _duration.inSeconds)
                : null,
            activeColor: AppColors.saffron,
            inactiveColor: Colors.white.withOpacity(0.2),
          ),
        ),
      ]),
    );
  }

  Widget _setupScreen() => Center(child: Padding(
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
        child: const Text(
          'Open lib/core/drive_service.dart\n'
          'Replace REPLACE_WITH_YOUR_AUDIO_FOLDER_ID\n'
          'with your Google Drive folder ID.\n\n'
          'Then drop MP3 files into that folder —\n'
          'they appear automatically in the app!',
          style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.6))),
    ])));

  Widget _emptyState() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.music_off_outlined, size: 48, color: AppColors.textMuted),
      const SizedBox(height: 16),
      Text(_search.isEmpty
          ? 'No audio files found in Drive folder.\nDrop MP3 files into your audio/discourses/ folder.'
          : 'No results for "$_search"',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMid, height: 1.5)),
    ])));
}

class _TrackTile extends StatelessWidget {
  final DriveAudioFile file;
  final int index;
  final bool isPlaying, isCurrent, isBuffering;
  final VoidCallback onTap, onShare;

  const _TrackTile({
    required this.file, required this.index,
    required this.isPlaying, required this.isCurrent, required this.isBuffering,
    required this.onTap, required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : AppColors.primaryLight,
              shape: BoxShape.circle),
            child: isBuffering
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isCurrent ? Colors.white : AppColors.primary,
                    size: 26))),
        title: Text(file.displayName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textDark),
          maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('#$index', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        trailing: IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textMuted, size: 20),
          onPressed: onShare),
        onTap: onTap,
      ),
    );
  }
}
