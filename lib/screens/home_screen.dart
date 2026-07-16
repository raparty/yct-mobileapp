import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import 'magazine_archive_screen.dart';
import 'issue_detail_screen.dart';
import 'gurudev_screen.dart';

// Callback to switch main tab from home screen
typedef TabSwitcher = void Function(int index);

class HomeScreen extends StatefulWidget {
  final TabSwitcher? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppSettings _settings = AppSettings.defaults();
  List<Magazine> _magazines = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final results = await Future.wait([
      FirestoreService.fetchSettings(),
      FirestoreService.fetchMagazines(),
    ]);
    if (mounted) setState(() {
      _settings  = results[0] as AppSettings;
      _magazines = (results[1] as List<Magazine>).take(4).toList();
      _loading   = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _switchTab(int i) {
    if (widget.onSwitchTab != null) widget.onSwitchTab!(i);
  }

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

  Widget _header() => SliverAppBar(
    expandedHeight: 196, pinned: true, backgroundColor: AppColors.primary,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primaryMid, AppColors.primaryDark])),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                child: const Center(child: Text('YCT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(AppStrings.appName, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(AppStrings.appNameTelugu, style: const TextStyle(color: AppColors.teal, fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.wb_sunny_outlined, color: AppColors.teal, size: 12),
                  const SizedBox(width: 4),
                  const Text("Today's Teaching", style: TextStyle(color: AppColors.teal, fontSize: 10)),
                ]),
                const SizedBox(height: 6),
                Text('"${_settings.dailyQuote}"',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic, height: 1.5)),
                const SizedBox(height: 4),
                Text('— ${AppStrings.guruName}', style: const TextStyle(color: AppColors.teal, fontSize: 10)),
              ]),
            ),
          ]),
        )),
      ),
    ),
  );

  Widget _sectionTitle(String t) => Text(t.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMid, letterSpacing: 0.5));

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
      _QuickCard('Centers', 'Find us near you',
        Icons.location_on, AppColors.amberLight, AppColors.amber,
        () => _switchTab(3)), // Centers tab index 3
      _QuickCard('Audio', 'Discourses & talks',
        Icons.headphones, const Color(0xFFEEEDFE), AppColors.purple,
        () => _switchTab(2)), // Audio tab index 2
    ],
  );

  Widget _emptyMags() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MagazineArchiveScreen())),
            child: Container(
              width: 90,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.arrow_forward, color: AppColors.primary),
                SizedBox(height: 6),
                Text('View all', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
              ])));
        }
        final mag = _magazines[i];
        return GestureDetector(
          onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => IssueDetailScreen(magazine: mag))),
          child: SizedBox(width: 100, child: Column(children: [
            Container(
              height: 120, width: 100,
              decoration: BoxDecoration(color: mag.coverColor, borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: mag.coverColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
              padding: const EdgeInsets.all(8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('YCT', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 8)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mag.displayMonth, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('${mag.year}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                ]),
              ])),
            const SizedBox(height: 4),
            Text(mag.titleTelugu, style: const TextStyle(fontSize: 10, color: AppColors.textDark),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            if (i == 0) Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Text('Latest', style: TextStyle(fontSize: 9, color: AppColors.primaryDark))),
          ])));
      },
    ));

  Widget _aboutCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Yoga Consciousness Trust', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
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
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: fg, size: 18)),
        const Spacer(),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ])));
}
