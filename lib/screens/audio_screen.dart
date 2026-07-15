import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  AudioTrack? _playing;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _load();
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() =>
        _isPlaying = state.playing);
    });
  }

  Future<void> _load() async {
    final tracks = await SheetsService.fetchAudio();
    if (mounted) setState(() { _tracks = tracks; _loading = false; });
  }

  Future<void> _playTrack(AudioTrack track) async {
    if (_playing?.id == track.id) {
      _isPlaying ? _player.pause() : _player.play();
      return;
    }
    setState(() => _playing = track);
    await _player.setUrl(track.mp3Url);
    _player.play();
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary))
          : Column(
              children: [
                // Mini player (shows when something is playing)
                if (_playing != null) _buildMiniPlayer(),
                Expanded(
                  child: _tracks.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tracks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) =>
                              _TrackCard(
                                track: _tracks[i],
                                isPlaying: _playing?.id == _tracks[i].id &&
                                    _isPlaying,
                                onTap: () => _playTrack(_tracks[i]),
                                onShare: () => Share.share(
                                  '${_tracks[i].title}\n${_tracks[i].mp3Url}'),
                              ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMiniPlayer() {
    final track = _playing!;
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.music_note,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (track.titleTelugu.isNotEmpty)
                    Text(track.titleTelugu,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white, size: 28),
              onPressed: () => _isPlaying
                  ? _player.pause()
                  : _player.play(),
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white, size: 22),
              onPressed: () {
                _player.stop();
                setState(() { _playing = null; _isPlaying = false; });
              },
            ),
          ]),
          // Progress bar
          if (_duration.inSeconds > 0)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                trackHeight: 2,
              ),
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                activeColor: AppColors.teal,
                inactiveColor: Colors.white.withOpacity(0.3),
                onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
              ),
            ),
        ],
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
            Icon(Icons.headphones_outlined,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('Audio Coming Soon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Gurudev\'s discourses are being organised and '
              'will be available here soon. Drop MP3s in Google Drive '
              'and add rows to the audio tab in your Google Sheet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13,
                  color: AppColors.textLight, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final AudioTrack track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _TrackCard({
    required this.track,
    required this.isPlaying,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaying ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isPlaying ? AppColors.primary : AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        leading: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isPlaying ? AppColors.primary : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: isPlaying ? Colors.white : AppColors.primary,
              size: 24,
            ),
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
      ),
    );
  }
}
