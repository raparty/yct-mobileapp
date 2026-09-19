import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import '../core/connectivity_service.dart';
import '../core/quotes_service.dart';
import '../core/remote_config_service.dart';
import '../core/home_cards_service.dart';
import '../widgets/error_view.dart';
import '../widgets/cover_image.dart';
import 'magazine_archive_screen.dart';
import 'issue_detail_screen.dart';
import 'gurudev_screen.dart';
import 'programs_screen.dart';
import 'centers_screen.dart';

typedef TabSwitcher = void Function(int index);

class HomeScreen extends StatefulWidget {
  final TabSwitcher? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Magazine> _magazines = [];
  DailyQuote? _quote;
  List<HomeCard> _cards = [];
  bool _loading = true;
  String? _error;

  static final _launchDate = DateTime(2026, 9, 30, 6, 0, 0);
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  bool get _showCountdown =>
      RemoteConfigService.showLaunchCountdown &&
      DateTime.now().isBefore(_launchDate);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _updateRemaining();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1), (_) { if (mounted) _updateRemaining(); });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = _launchDate.isAfter(now)
          ? _launchDate.difference(now) : Duration.zero;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        FirestoreService.fetchMagazines(),
        QuotesService.getTodaysQuote(),
        HomeCardsService.fetch(),
      ]);
      if (mounted) setState(() {
        _magazines = (results[0] as List<Magazine>).take(4).toList();
        _quote     = results[1] as DailyQuote;
        _cards     = (results[2] as List<HomeCard>).where((c) => c.enabled).toList();
        _loading   = false;
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      if (mounted) setState(() {
        _error = ConnectivityService.friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _switchTab(int i) { if (widget.onSwitchTab != null) widget.onSwitchTab!(i); }

  void _onCardTap(BuildContext context, HomeCard card) {
    switch (card.id) {
      case 'publications':
        Navigator.push(context, MaterialPageRoute(builder: (_) => MagazineArchiveScreen()));
        break;
      case 'gurudev':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GurudevScreen()));
        break;
      case 'programs':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramsScreen()));
        break;
      case 'centers':
        _switchTab(3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: RefreshIndicator(
        color: const Color(0xFF2D5A46),
        onRefresh: () async {
          HomeCardsService.clearCache();
          QuotesService.clearCache();
          await _load();
        },
        child: CustomScrollView(slivers: [
          _header(),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_showCountdown) ...[_countdown(), const SizedBox(height: 20)],
              _sectionLabel('EXPLORE'),
              const SizedBox(height: 10),
              _loading
                  ? const SizedBox(height: 320,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2D5A46))))
                  : _cardGrid(context),
              const SizedBox(height: 20),
              _sectionLabel('LATEST ISSUES'),
              const SizedBox(height: 10),
              _loading ? const SizedBox(height: 160) : _latestMags(),
              const SizedBox(height: 20),
              _sectionLabel('ABOUT YCT'),
              const SizedBox(height: 10),
              _aboutCard(),
              const SizedBox(height: 100),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _header() => SliverAppBar(
    expandedHeight: 200, pinned: true,
    backgroundColor: const Color(0xFF2D5A46),
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF2D5A46), Color(0xFF1E3F31)])),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)]),
                child: ClipOval(child: Image.asset('assets/images/yct_logo.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Text('YCT',
                    style: TextStyle(color: Color(0xFF2D5A46), fontSize: 9, fontWeight: FontWeight.bold)))))),
              const SizedBox(width: 10),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Yoga Consciousness Trust',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('యోగ చైతన్య సంస్థ',
                  style: TextStyle(color: Color(0xFF80CBC4), fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.wb_sunny_outlined, color: Color(0xFF80CBC4), size: 12),
                  SizedBox(width: 4),
                  Text("Today's Teaching",
                    style: TextStyle(color: Color(0xFF80CBC4), fontSize: 10)),
                ]),
                const SizedBox(height: 6),
                Text('"${_quote?.text ?? 'The real yoga is not in the posture of the body, but in the stillness of the mind.'}"',
                  style: const TextStyle(color: Colors.white, fontSize: 11,
                    fontStyle: FontStyle.italic, height: 1.5)),
                const SizedBox(height: 4),
                Text('— ${_quote?.author ?? 'Yogacharya Sri Raparthi Rama Rao'}',
                  style: const TextStyle(color: Color(0xFFF9D371), fontSize: 10)),
              ]),
            ),
          ]),
        )),
      ),
    ),
  );

  // ── Photo Cards Grid ─────────────────────────────────────────────────────────
  Widget _cardGrid(BuildContext context) {
    final cards = _cards.isEmpty ? HomeCardsService._defaults() : _cards;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.88,
        crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: cards.length,
      itemBuilder: (ctx, i) => _PhotoCard(
        card: cards[i],
        onTap: () => _onCardTap(ctx, cards[i]),
      ),
    );
  }

  // ── Latest Magazines ────────────────────────────────────────────────────────
  Widget _latestMags() => _magazines.isEmpty
      ? Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8))),
          child: const Column(children: [
            Icon(Icons.menu_book_outlined, color: Color(0xFFB4B2A9), size: 36),
            SizedBox(height: 8),
            Text('Upload magazines via the admin page', textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888780), fontSize: 12)),
          ]))
      : SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _magazines.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              if (i == _magazines.length) {
                return GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MagazineArchiveScreen())),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2D5A46).withOpacity(0.3))),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.arrow_forward, color: Color(0xFF2D5A46)),
                      SizedBox(height: 6),
                      Text('View all', style: TextStyle(
                        color: Color(0xFF2D5A46), fontSize: 11, fontWeight: FontWeight.w500)),
                    ])));
              }
              final mag = _magazines[i];
              return GestureDetector(
                onTap: () => Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) => IssueDetailScreen(magazine: mag))),
                child: SizedBox(width: 100, child: Column(children: [
                  SizedBox(height: 120, width: 100,
                    child: MagazineCover(
                      imageUrl: mag.coverImageUrl,
                      fallbackColor: mag.coverColor,
                      month: mag.displayMonth,
                      year: mag.year,
                      monthNumber: mag.month,
                      borderRadius: 8)),
                  const SizedBox(height: 4),
                  Text(mag.titleTelugu,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF2C2C2A)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (i == 0) Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Text('Latest',
                      style: TextStyle(fontSize: 9, color: Color(0xFF1E3F31)))),
                ])));
            },
          ));

  // ── About Card ──────────────────────────────────────────────────────────────
  Widget _aboutCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE8E8E8))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Yoga Consciousness Trust',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E3F31))),
      const SizedBox(height: 6),
      const Text('Founded by Yogacharya Sri Raparthi Rama Rao, YCT has been spreading the teachings of Anushtana Yoga Vedanta since 1990.',
        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
      const SizedBox(height: 12),
      Row(children: [
        _chip(Icons.language, 'Website', () => _openUrl(AppStrings.website)),
        const SizedBox(width: 8),
        _chip(Icons.chat, 'WhatsApp', () => _openUrl(AppStrings.whatsapp)),
      ]),
    ]));

  Widget _chip(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, size: 14, color: const Color(0xFF2D5A46)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(
          fontSize: 11, color: Color(0xFF1E3F31), fontWeight: FontWeight.w500)),
      ])));

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: Color(0xFF9CA3AF), letterSpacing: 0.8));

  // ── Countdown ───────────────────────────────────────────────────────────────
  Widget _countdown() {
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3F31), Color(0xFF2D5A46)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF2D5A46).withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.celebration, color: Color(0xFFF9D371), size: 16),
          SizedBox(width: 6),
          Text('Official Launch',
            style: TextStyle(color: Color(0xFFF9D371),
              fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          SizedBox(width: 6),
          Icon(Icons.celebration, color: Color(0xFFF9D371), size: 16),
        ]),
        const SizedBox(height: 4),
        const Text('September 30, 2026',
          style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _unit(days, 'DAYS'), _div(),
          _unit(hours, 'HRS'), _div(),
          _unit(minutes, 'MIN'), _div(),
          _unit(seconds, 'SEC'),
        ]),
      ]),
    );
  }

  Widget _unit(int v, String l) => Column(children: [
    Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2))),
      child: Center(child: Text(v.toString().padLeft(2, '0'),
        style: const TextStyle(color: Colors.white,
          fontSize: 24, fontWeight: FontWeight.bold)))),
    const SizedBox(height: 4),
    Text(l, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.5)),
  ]);

  Widget _div() => const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Text(':', style: TextStyle(color: Colors.white54,
      fontSize: 22, fontWeight: FontWeight.bold)));
}

// ── Photo Card Widget ────────────────────────────────────────────────────────
class _PhotoCard extends StatelessWidget {
  final HomeCard card;
  final VoidCallback onTap;
  const _PhotoCard({required this.card, required this.onTap});

  // Fallback gradient per card when image fails
  static const _fallbacks = {
    'publications': [Color(0xFF1B4D1B), Color(0xFF2D7A2D)],
    'gurudev':      [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
    'programs':     [Color(0xFF6B3205), Color(0xFF9A5010)],
    'centers':      [Color(0xFF1F0A40), Color(0xFF3A1870)],
  };

  @override
  Widget build(BuildContext context) {
    final fallbackColors = _fallbacks[card.id] ??
        [const Color(0xFF2D5A46), const Color(0xFF1E3F31)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8, offset: const Offset(0, 3))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [

            // ── Background image ──────────────────────────
            Positioned.fill(
              child: card.imageUrl.isNotEmpty
                  ? Image.network(
                      card.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _fallbackBg(fallbackColors),
                      errorBuilder: (_, __, ___) => _fallbackBg(fallbackColors))
                  : _fallbackBg(fallbackColors)),

            // ── Bottom gradient overlay ───────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.72),
                    ],
                    stops: const [0.35, 0.60, 1.0])))),

            // ── Lotus watermark ───────────────────────────
            Positioned(
              right: -8, bottom: 28,
              child: Opacity(
                opacity: 0.10,
                child: Icon(Icons.spa, size: 80, color: Colors.white))),

            // ── Text + chevron ────────────────────────────
            Positioned(
              left: 12, right: 12, bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(card.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)])),
                      const SizedBox(height: 3),
                      Text(card.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          shadows: const [Shadow(color: Colors.black45, blurRadius: 4)])),
                    ])),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 18)),
                ])),
          ])));
  }

  Widget _fallbackBg(List<Color> colors) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: colors)));
}
