// ─────────────────────────────────────────
// YCT App — Home Screen
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/sheets_service.dart';
import 'library_screen.dart';
import 'magazine_archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppSettings _settings = AppSettings.defaults();
  List<Magazine> _latestMagazines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      SheetsService.fetchSettings(),
      SheetsService.fetchMagazines(),
    ]);
    if (mounted) {
      setState(() {
        _settings        = results[0] as AppSettings;
        _latestMagazines = (results[1] as List<Magazine>).take(3).toList();
        _loading         = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Explore'),
                    const SizedBox(height: 10),
                    _buildQuickGrid(context),
                    const SizedBox(height: 20),
                    if (_latestMagazines.isNotEmpty) ...[
                      _buildSectionTitle('Latest Issues'),
                      const SizedBox(height: 10),
                      _buildLatestMagazines(),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle('About YCT'),
                    const SizedBox(height: 10),
                    _buildAboutCard(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryMid, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Center(
                          child: Text('YCT',
                            style: TextStyle(color: Colors.white,
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(AppStrings.appName,
                            style: TextStyle(color: Colors.white,
                                fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(AppStrings.appNameTelugu,
                            style: TextStyle(
                                color: AppColors.teal, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Daily quote card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.wb_sunny_outlined,
                              color: AppColors.teal, size: 12),
                          const SizedBox(width: 4),
                          Text("Today's Teaching",
                            style: TextStyle(
                                color: AppColors.teal, fontSize: 10,
                                letterSpacing: 0.5)),
                        ]),
                        const SizedBox(height: 6),
                        Text(
                          _loading
                              ? '"${AppSettings.defaults().dailyQuote}"'
                              : '"${_settings.dailyQuote}"',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12,
                              fontStyle: FontStyle.italic, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text('— ${AppStrings.guruName}',
                          style: TextStyle(
                              color: AppColors.teal, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(),
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textMid, letterSpacing: 0.5));
  }

  Widget _buildQuickGrid(BuildContext context) {
    final items = [
      _QuickItem('Publications', 'Books & magazines',
          Icons.menu_book, AppColors.primaryLight, AppColors.primary,
          () => _goToTab(context, 1)),
      _QuickItem('About Gurudev', 'Life & teachings',
          Icons.self_improvement, const Color(0xFFE6F1FB), AppColors.blue,
          () => _openUrl(AppStrings.website)),
      _QuickItem('Centers', 'Find us near you',
          Icons.location_on, AppColors.amberLight, AppColors.amber,
          () => _goToTab(context, 3)),
      _QuickItem('Audio', 'Discourses & talks',
          Icons.headphones, const Color(0xFFEEEDFE), AppColors.purple,
          () => _goToTab(context, 2)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: items.map((item) => _QuickCard(item: item)).toList(),
    );
  }

  void _goToTab(BuildContext context, int index) {
    // Find the MainShell and switch tab
    final scaffold = Scaffold.of(context);
    // Navigate via parent — simpler approach: push named route
    // For now navigate directly
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Widget _buildLatestMagazines() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _latestMagazines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final mag = _latestMagazines[i];
          return GestureDetector(
            onTap: () => Navigator.push(ctx,
              MaterialPageRoute(
                builder: (_) => MagazineArchiveScreen())),
            child: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Container(
                    height: 120, width: 100,
                    decoration: BoxDecoration(
                      color: mag.coverColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(
                          color: mag.coverColor.withOpacity(0.3),
                          blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('YCT', style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 8)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mag.displayMonth,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                              Text('${mag.year}', style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(mag.titleTelugu,
                    style: const TextStyle(fontSize: 10,
                        color: AppColors.textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (i == 0)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Latest',
                        style: TextStyle(fontSize: 9,
                            color: AppColors.primaryDark)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yoga Consciousness Trust',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text(
            'Founded by Yogacharya Sri Raparthi Rama Rao, YCT has been '
            'spreading the teachings of Anushtana Yoga Vedanta since 1990, '
            'with centers across Andhra Pradesh and Telangana.',
            style: TextStyle(fontSize: 12, color: AppColors.textLight,
                height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _ContactChip(
              icon: Icons.language,
              label: 'Website',
              onTap: () => _openUrl(AppStrings.website),
            ),
            const SizedBox(width: 8),
            _ContactChip(
              icon: Icons.chat,
              label: 'WhatsApp',
              onTap: () => _openUrl(AppStrings.whatsapp),
            ),
          ]),
        ],
      ),
    );
  }
}

class _QuickItem {
  final String title, subtitle;
  final IconData icon;
  final Color bgColor, iconColor;
  final VoidCallback onTap;
  _QuickItem(this.title, this.subtitle, this.icon,
      this.bgColor, this.iconColor, this.onTap);
}

class _QuickCard extends StatelessWidget {
  final _QuickItem item;
  const _QuickCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 18),
            ),
            const Spacer(),
            Text(item.title,
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
            Text(item.subtitle,
              style: const TextStyle(fontSize: 10,
                  color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(
              fontSize: 11, color: AppColors.primaryDark,
              fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
