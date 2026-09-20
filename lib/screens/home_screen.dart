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
  List<YearlyProgram> _programs = [];
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
        FirestoreService.fetchPrograms(),
      ]);
      if (mounted) setState(() {
        _magazines = (results[0] as List<Magazine>).take(4).toList();
        _quote     = results[1] as DailyQuote;
        _cards     = (results[2] as List<HomeCard>).where((c) => c.enabled).toList();
        final allPrograms = results[3] as List<YearlyProgram>;
        _programs  = allPrograms.where((p) => p.isUpcoming).take(3).toList();
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

  // Tab indices: Home=0 Library=1 Audio=2 Programs=3 Centers=4 More=5
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
        _switchTab(4); // Centers is tab index 4
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // shows bg_texture through
      body: RefreshIndicator(
        color: AppColors.primary,
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
              _quoteBox(),
              const SizedBox(height: 16),
              if (_showCountdown) ...[_countdown(), const SizedBox(height: 20)],
              _sectionLabel('EXPLORE'),
              const SizedBox(height: 10),
              _loading
                  ? const SizedBox(height: 320,
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                  : _cardGrid(context),
              const SizedBox(height: 20),
              _sectionLabel('LATEST ISSUES'),
              const SizedBox(height: 10),
              _loading ? const SizedBox(height: 160) : _latestMags(),
              if (_programs.isNotEmpty) ...[
                const SizedBox(height: 20),
                _sectionLabel('UPCOMING PROGRAMS'),
                const SizedBox(height: 10),
                _upcomingPrograms(),
              ],
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

  Widget _header() => SliverAppBar(
    pinned: true,
    backgroundColor: AppColors.primaryDark,
    toolbarHeight: 56,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white,
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
          child: ClipOval(child: Image.asset(
            'assets/images/yct_logo.png', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('YCT', style: TextStyle(
                color: AppColors.primaryDark, fontSize: 7,
                fontWeight: FontWeight.bold)))))),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Yoga Consciousness Trust',
              style: TextStyle(color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w600)),
            Text('యోగ చైతన్య సంస్థ',
              style: TextStyle(color: AppColors.teal, fontSize: 10)),
          ]),
      ]),
    titleSpacing: 16,
  );

  Widget _quoteBox() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppColors.primaryDark, AppColors.primary]),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(
        color: AppColors.primary.withOpacity(0.25),
        blurRadius: 10, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.wb_sunny_outlined, color: AppColors.teal, size: 12),
        SizedBox(width: 4),
        Text("Today's Teaching",
          style: TextStyle(color: AppColors.teal, fontSize: 10)),
      ]),
      const SizedBox(height: 8),
      Text('"${_quote?.text ?? 'The real yoga is not in the posture of the body, but in the stillness of the mind.'}"',
        style: const TextStyle(color: Colors.white, fontSize: 12,
          fontStyle: FontStyle.italic, height: 1.5)),
      const SizedBox(height: 6),
      Text('— ${_quote?.author ?? AppStrings.guruName}',
        style: const TextStyle(color: Color(0xFFF9D371), fontSize: 10)),
    ]),
  );

  Widget _cardGrid(BuildContext context) {
    final cards = _cards.isEmpty ? HomeCardsService.defaults() : _cards;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.88,
        crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: cards.length,
      itemBuilder: (ctx, i) => _PhotoCard(
        card: cards[i], onTap: () => _onCardTap(ctx, cards[i])),
    );
  }

  Widget _latestMags() => _magazines.isEmpty
      ? Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
          child: const Column(children: [
            Icon(Icons.menu_book_outlined, color: AppColors.textMuted, size: 36),
            SizedBox(height: 8),
            Text('Upload magazines via the admin page',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMid, fontSize: 12)),
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
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3))),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward, color: AppColors.primary),
                        SizedBox(height: 6),
                        Text('View all', style: TextStyle(
                          color: AppColors.primary, fontSize: 11,
                          fontWeight: FontWeight.w500)),
                      ])));
              }
              final mag = _magazines[i];
              return GestureDetector(
                onTap: () => Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) => IssueDetailScreen(magazine: mag))),
                child: SizedBox(width: 100, child: Column(children: [
                  SizedBox(height: 120, width: 100,
                    child: MagazineCover(
                      imageUrl:      mag.coverImageUrl,
                      fallbackColor: mag.coverColor,
                      month:         mag.displayMonth,
                      year:          mag.year,
                      monthNumber:   mag.month,
                      borderRadius:  8)),
                  const SizedBox(height: 4),
                  Text(mag.titleTelugu,
                    style: const TextStyle(fontSize: 10, color: AppColors.textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (i == 0) Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10)),
                    child: const Text('Latest',
                      style: TextStyle(fontSize: 9, color: AppColors.primaryDark))),
                ])));
            },
          ));

  Widget _upcomingPrograms() => Column(
    children: _programs.map((p) => GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ProgramsScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.90),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.event, color: AppColors.primary, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.title,
                style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 3),
              Text(p.displayDate,
                style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
              if (p.location.isNotEmpty)
                Text(p.location,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
            ])),
          const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
        ]),
      ),
    )).toList(),
  );

  Widget _aboutCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.90),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Yoga Consciousness Trust',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.primaryDark)),
      const SizedBox(height: 6),
      const Text('Founded by Yogacharya Sri Raparthi Rama Rao, YCT has been '
        'spreading the teachings of Anushtana Yoga Vedanta since 1990.',
        style: TextStyle(fontSize: 12, color: AppColors.textMid, height: 1.5)),
      const SizedBox(height: 12),
      Row(children: [
        _chip(Icons.language, 'Website', () => _openUrl(AppStrings.website)),
        const SizedBox(width: 8),
        _chip(Icons.chat, 'WhatsApp', () => _openUrl(AppStrings.whatsapp)),
      ]),
    ]));

  Widget _chip(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(
              fontSize: 11, color: AppColors.primaryDark,
              fontWeight: FontWeight.w500)),
          ])));

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: AppColors.textMid, letterSpacing: 0.8));

  Widget _countdown() {
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.celebration, color: AppColors.saffron, size: 16),
          SizedBox(width: 6),
          Text('Official Launch', style: TextStyle(
            color: AppColors.saffron, fontSize: 12,
            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          SizedBox(width: 6),
          Icon(Icons.celebration, color: AppColors.saffron, size: 16),
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
    Text(l, style: const TextStyle(
      color: Colors.white54, fontSize: 9, letterSpacing: 0.5)),
  ]);

  Widget _div() => const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Text(':', style: TextStyle(
      color: Colors.white54, fontSize: 22, fontWeight: FontWeight.bold)));
}

class _PhotoCard extends StatelessWidget {
  final HomeCard card;
  final VoidCallback onTap;
  const _PhotoCard({required this.card, required this.onTap});

  static const _fallbacks = {
    'publications': [Color(0xFF1B4D1B), Color(0xFF2D7A2D)],
    'gurudev':      [Color(0xFF0A1F3A), Color(0xFF1A3A5A)],
    'programs':     [Color(0xFF6B3205), Color(0xFF9A5010)],
    'centers':      [Color(0xFF1F0A40), Color(0xFF3A1870)],
  };

  @override
  Widget build(BuildContext context) {
    final fallbackColors = _fallbacks[card.id] ??
        [AppColors.primaryDark, AppColors.primary];
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
            Positioned.fill(
              child: card.imageUrl.isNotEmpty
                  ? Image.network(card.imageUrl, fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _fallbackBg(fallbackColors),
                      errorBuilder: (_, __, ___) => _fallbackBg(fallbackColors))
                  : _fallbackBg(fallbackColors)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.72),
                    ],
                    stops: const [0.35, 0.60, 1.0])))),
            Positioned(
              right: -8, bottom: 28,
              child: Opacity(opacity: 0.10,
                child: const Icon(Icons.spa, size: 80, color: Colors.white))),
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
                          color: Colors.white, fontSize: 15,
                          fontWeight: FontWeight.w700, height: 1.2,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)])),
                      const SizedBox(height: 3),
                      Text(card.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85), fontSize: 11,
                          shadows: const [Shadow(
                            color: Colors.black45, blurRadius: 4)])),
                    ])),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 18)),
                ])),
          ]))));
  }

  Widget _fallbackBg(List<Color> colors) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: colors)));
}
