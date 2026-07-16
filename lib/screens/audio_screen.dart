import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  List<AudioTrack> _tracks = [];
  List<AudioTrack> _filtered = [];
  bool _loading = true;
  String _search = '';

  final AudioPlayer _player = AudioPlayer();
  AudioTrack? _current;
  PlayerState _state = PlayerState.stopped;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  bool _buffering = false;
  bool _seeking = false;

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() { _state = s; if (s == PlayerState.playing) _buffering = false; });
    });
    _player.onPositionChanged.listen((p) {
      if (mounted && !_seeking) setState(() => _pos = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _dur = d);
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tracks = await FirestoreService.fetchAudio();
    if (mounted) setState(() { _tracks = tracks; _filtered = tracks; _loading = false; });
  }

  void _doSearch(String q) => setState(() {
    _search = q;
    _filtered = q.isEmpty ? _tracks
        : _tracks.where((t) => t.title.toLowerCase().contains(q.toLowerCase()) ||
            t.titleTelugu.contains(q)).toList();
  });

  Future<void> _play(AudioTrack track) async {
    if (_current?.id == track.id) {
      _state == PlayerState.playing ? await _player.pause() : await _player.resume();
      return;
    }
    setState(() { _current = track; _buffering = true; _pos = Duration.zero; _dur = Duration.zero; });
    try {
      await _player.play(UrlSource(track.audioUrl));
    } catch (e) {
      if (mounted) setState(() => _buffering = false);
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() { _current = null; _pos = Duration.zero; _buffering = false; });
  }

  Future<void> _seekTo(double seconds) async {
    setState(() => _seeking = true);
    await _player.seek(Duration(milliseconds: (seconds * 1000).toInt()));
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _seeking = false);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2,'0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2,'0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Audio Discourses'), backgroundColor: AppColors.primary,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              if (_current != null) _miniPlayer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16,12,16,4),
                child: TextField(
                  onChanged: _doSearch,
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
                  Text('${_filtered.length} discourse${_filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMid, fontWeight: FontWeight.w500)),
                ])),
              Expanded(
                child: _filtered.isEmpty ? _empty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16,4,16,100),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final t = _filtered[i];
                          final isCur  = _current?.id == t.id;
                          final isPlay = isCur && _state == PlayerState.playing;
                          return _Tile(
                            track: t, index: i+1,
                            isCurrent: isCur, isPlaying: isPlay,
                            isBuffering: isCur && _buffering,
                            onTap: () => _play(t));
                        })),
            ]),
    );
  }

  Widget _miniPlayer() {
    final isPlaying = _state == PlayerState.playing;
    final totalMs = _dur.inMilliseconds.toDouble();
    final posMs   = _pos.inMilliseconds.toDouble();
    final progress = totalMs > 0 ? (posMs / totalMs).clamp(0.0, 1.0) : 0.0;

    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 4),
      child: Column(children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.music_note, color: AppColors.saffron, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_current!.title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(_buffering ? 'Buffering...' : '${_fmt(_pos)} / ${_fmt(_dur)}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
          ])),
          // -10s
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white70, size: 22),
            onPressed: () => _seekTo(((posMs - 10000) / 1000).clamp(0, totalMs / 1000)),
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 2),
          // Play/Pause
          IconButton(
            icon: _buffering
                ? const SizedBox(width: 26, height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white, size: 36),
            onPressed: _buffering ? null : () => _play(_current!),
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 2),
          // +10s
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white70, size: 22),
            onPressed: () => _seekTo(((posMs + 10000) / 1000).clamp(0, totalMs / 1000)),
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          // Stop
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.white38, size: 22),
            onPressed: _stop,
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        // Seek slider
        SizedBox(
          height: 28,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackHeight: 3,
              thumbColor: AppColors.saffron,
              activeTrackColor: AppColors.saffron,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              overlayColor: AppColors.saffron.withOpacity(0.2),
            ),
            child: Slider(
              value: progress,
              min: 0.0, max: 1.0,
              onChangeStart: (_) => setState(() => _seeking = true),
              onChanged: (v) => setState(() => _pos = Duration(milliseconds: (v * totalMs).toInt())),
              onChangeEnd: (v) => _seekTo(v * totalMs / 1000),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _empty() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.library_music_outlined, size: 56, color: AppColors.textMuted),
      const SizedBox(height: 16),
      Text(_search.isEmpty
          ? 'No discourses yet.\n\nUpload MP3 files via the admin page.'
          : 'No results for "$_search"',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMid, height: 1.6)),
    ])));
}

class _Tile extends StatelessWidget {
  final AudioTrack track; final int index;
  final bool isCurrent, isPlaying, isBuffering;
  final VoidCallback onTap;
  const _Tile({required this.track, required this.index,
    required this.isCurrent, required this.isPlaying,
    required this.isBuffering, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary : AppColors.primaryLight,
            shape: BoxShape.circle),
          child: isBuffering
              ? const Padding(padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isCurrent ? Colors.white : AppColors.primary, size: 26)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(track.title,
            style: TextStyle(fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textDark),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          if (track.titleTelugu.isNotEmpty)
            Text(track.titleTelugu,
              style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
          if (track.topic.isNotEmpty || track.formattedDuration.isNotEmpty)
            const SizedBox(height: 4),
          Row(children: [
            if (track.topic.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: Text(track.topic, style: const TextStyle(fontSize: 9, color: AppColors.primaryDark))),
              const SizedBox(width: 6),
            ],
            if (track.formattedDuration.isNotEmpty)
              Text(track.formattedDuration, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          ]),
        ])),
        Text('#$index', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
    ));
}
