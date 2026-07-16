import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerStateChanged.listen((s) { if (mounted) setState(() => _state = s); });
    _player.onPositionChanged.listen((p) { if (mounted) setState(() => _pos = p); });
    _player.onDurationChanged.listen((d) { if (mounted) setState(() => _dur = d); });
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
            t.titleTelugu.contains(q) || t.topic.toLowerCase().contains(q.toLowerCase())).toList();
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
      // Fallback to browser
      final uri = Uri.parse(track.audioUrl);
      if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (mounted) setState(() => _buffering = false);
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() { _current = null; _pos = Duration.zero; });
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
                    hintText: 'Search discourses...', hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                ])),
              Expanded(
                child: _filtered.isEmpty
                    ? _empty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16,4,16,100),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final t = _filtered[i];
                          final isCur = _current?.id == t.id;
                          final isPlay = isCur && _state == PlayerState.playing;
                          return _Tile(
                            track: t, index: i+1, isCurrent: isCur, isPlaying: isPlay,
                            isBuffering: isCur && _buffering,
                            onTap: () => _play(t),
                            onShare: () => Share.share('${t.title}\n\nYoga Consciousness Trust\n${AppStrings.website}'));
                        })),
            ]),
    );
  }

  Widget _miniPlayer() {
    final isPlaying = _state == PlayerState.playing;
    final progress = _dur.inSeconds > 0 ? (_pos.inSeconds / _dur.inSeconds).clamp(0.0, 1.0) : 0.0;
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(16,10,8,0),
      child: Column(children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.music_note, color: AppColors.saffron, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_current!.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(_buffering ? 'Buffering...' : '${_fmt(_pos)} / ${_fmt(_dur)}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
          ])),
          IconButton(
            icon: _buffering
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 32),
            onPressed: _buffering ? null : () => _play(_current!)),
          IconButton(icon: const Icon(Icons.stop_circle_outlined, color: Colors.white60, size: 26), onPressed: _stop),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10), trackHeight: 2),
          child: Slider(
            value: progress,
            onChanged: _dur.inSeconds > 0 ? (v) => _player.seek(Duration(seconds: (v * _dur.inSeconds).toInt())) : null,
            activeColor: AppColors.saffron, inactiveColor: Colors.white.withOpacity(0.2))),
      ]));
  }

  Widget _empty() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.library_music_outlined, size: 56, color: AppColors.textMuted),
      const SizedBox(height: 16),
      Text(_search.isEmpty
          ? 'No discourses yet.\n\nUpload MP3 files via the admin page\nat admin.yogaconsciousness.org'
          : 'No results for "$_search"',
        textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMid, height: 1.6)),
    ])));
}

class _Tile extends StatelessWidget {
  final AudioTrack track; final int index;
  final bool isCurrent, isPlaying, isBuffering;
  final VoidCallback onTap, onShare;
  const _Tile({required this.track, required this.index, required this.isCurrent,
    required this.isPlaying, required this.isBuffering, required this.onTap, required this.onShare});
  @override
  Widget build(BuildContext context) => Container(
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
          decoration: BoxDecoration(color: isCurrent ? AppColors.primary : AppColors.primaryLight, shape: BoxShape.circle),
          child: isBuffering
              ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: isCurrent ? Colors.white : AppColors.primary, size: 26))),
      title: Text(track.title, style: TextStyle(fontSize: 13, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500, color: AppColors.textDark),
        maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Row(children: [
        if (track.topic.isNotEmpty) ...[
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Text(track.topic, style: const TextStyle(fontSize: 9, color: AppColors.primaryDark))),
          const SizedBox(width: 6),
        ],
        if (track.formattedDuration.isNotEmpty)
          Text(track.formattedDuration, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ]),
      trailing: IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textMuted, size: 20), onPressed: onShare),
      onTap: onTap,
    ));
}
