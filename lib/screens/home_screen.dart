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
  YearlyProgram? _nextProgram;
  bool _loading = true;
  String? _error;

  // Sep 30 countdown
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
        FirestoreService.fetchPrograms(),
      ]);
      if (mounted) setState(() {
        _magazines    = (results[0] as List<Magazine>).take(4).toList();
        _quote        = results[1] as DailyQuote;
        final programs = results[2] as List<YearlyProgram>;
        _nextProgram  = programs.where((p) => p.isUpcoming).firstOrNull;
        _loading      = false;
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      if (mounted) setState(() {
        _error   = ConnectivityService.friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Tab indices: 0=Home, 1=Library, 2=Audio, 3=Programs, 4=Centers, 5=More
  void _switchTab(int i) { if (widget.onSwitchTab != null) widget.onSwitchTab!(i); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(slivers: [
          _header(),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_showCountdown) ...[_countdown(), const SizedBox(height: 20)],
              if (_nextProgram != null) ...[
                _programBanner(_nextProgram!),
                const SizedBox(height: 20),
              ],
              _sectionTitle('Explore'),
              const SizedBox(height: 10),
              _quickGrid(context),
              const SizedBox(height: 20),
              _sectionTitle('Latest Issues'),
              const SizedBox(height: 10),
              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _magazines.isEmpty ? _emptyMags() : _latestMags(),
              const SizedBox(height: 20),
              _sectionTitle('About YCT'),
              const SizedBox(height: 10),
              _aboutCard(),
              const SizedBox(height: 100),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _programBanner(YearlyProgram prog) {
    return GestureDetector(
      onTap: () => _switchTab(3), // Programs tab is index 3
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.amberLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.saffron.withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.saffron.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(prog.typeIcon, color: AppColors.saffronDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('UPCOMING PROGRAM',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                color: AppColors.saffronDark, letterSpacing: 0.8)),
            const SizedBox(height: 2),
            Text(prog.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textDark),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${prog.displayDate} · ${prog.centerName}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMid),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textMuted),
        ]),
      ),
    );
  }

  Widget _header() => SliverAppBar(
    expandedHeight: 200, pinned: true, backgroundColor: AppColors.primary,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primaryMid, AppColors.primaryDark])),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)]),
                child: ClipOval(child: Image.asset('assets/images/yct_logo.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Text('YCT',
                    style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)))))),
              const SizedBox(width: 10),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppStrings.appName,
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(AppStrings.appNameTelugu,
                  style: TextStyle(color: AppColors.teal, fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.wb_sunny_outlined, color: AppColors.teal, size: 12),
                  SizedBox(width: 4),
                  Text("Today's Teaching",
                    style: TextStyle(color: AppColors.teal, fontSize: 10)),
                ]),
                const SizedBox(height: 6),
                Text('"${_quote?.text ?? 'The real yoga is not in the posture of the body, but in the stillness of the mind.'}"',
                  style: const TextStyle(color: Colors.white, fontSize: 12,
                    fontStyle: FontStyle.italic, height: 1.5)),
                const SizedBox(height: 4),
                Text('— ${_quote?.author ?? AppStrings.guruName}',
                  style: const TextStyle(color: AppColors.teal, fontSize: 10)),
              ]),
            ),
          ]),
        )),
      ),
    ),
  );

  Widget _countdown() {
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMid],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.celebration, color: AppColors.saffron, size: 16),
          SizedBox(width: 6),
          Text('Official Launch',
            style: TextStyle(color: AppColors.saffron,
              fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
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
    Text(l, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.5)),
  ]);

  Widget _div() => const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Text(':', style: TextStyle(color: Colors.white54,
      fontSize: 22, fontWeight: FontWeight.bold)));

  Widget _sectionTitle(String t) => Text(t.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: AppColors.textMid, letterSpacing: 0.5));

  Widget _quickGrid(BuildContext context) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
    children: [
      _QuickCard('Publications', 'Books & magazines',
        Icons.menu_book, AppColors.primaryLight, AppColors.primary,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => MagazineArchiveScreen()))),
      _QuickCard('About Gurudev', 'Life & teachings',
        Icons.self_improvement, const Color(0xFFE6F1FB), AppColors.blue,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GurudevScreen()))),
      _QuickCard('Programs', 'Yearly schedule',
        Icons.event, AppColors.amberLight, AppColors.saffronDark,
        () => _switchTab(3)), // Programs = index 3
      _QuickCard('Centers', 'Find us near you',
        Icons.location_on, const Color(0xFFEEEDFE), AppColors.purple,
        () => _switchTab(4)), // Centers = index 4
    ],
  );

  Widget _emptyMags() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border)),
    child: const Column(children: [
      Icon(Icons.menu_book_outlined, color: AppColors.textMuted, size: 36),
      SizedBox(height: 8),
      Text('Upload magazines via the admin page', textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMid, fontSize: 12)),
    ]));

  Widget _latestMags() => SizedBox(
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
              decoration: BoxDecoration(color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.arrow_forward, color: AppColors.primary),
                SizedBox(height: 6),
                Text('View all', style: TextStyle(
                  color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
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
              decoration: BoxDecoration(color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10)),
              child: const Text('Latest',
                style: TextStyle(fontSize: 9, color: AppColors.primaryDark))),
          ])));
      },
    ));

  Widget _aboutCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Yoga Consciousness Trust',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      const SizedBox(height: 6),
      const Text('Founded by Yogacharya Sri Raparthi Rama Rao, YCT has been spreading the teachings of Anushtana Yoga Vedanta since 1990.',
        style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.5)),
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
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(
          fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
      ])));
}

class _QuickCard extends StatelessWidget {
  final String title, sub; final IconData icon;
  final Color bg, fg; final VoidCallback onTap;
  const _QuickCard(this.title, this.sub, this.icon, this.bg, this.fg, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: fg, size: 18)),
        const Spacer(),
        Text(title, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ])));
}
