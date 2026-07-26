// ─────────────────────────────────────────
// YCT — Magazine Archive (R1)
// • Error state + retry
// • Empty state
// • Loading indicator
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import '../core/connectivity_service.dart';
import '../widgets/error_view.dart';
import 'issue_detail_screen.dart';

class MagazineArchiveScreen extends StatefulWidget {
  const MagazineArchiveScreen({super.key});
  @override
  State<MagazineArchiveScreen> createState() => _MagazineArchiveScreenState();
}

class _MagazineArchiveScreenState extends State<MagazineArchiveScreen> {
  List<Magazine> _all = [];
  bool _loading = true;
  String? _error;
  int _selectedYear = 0;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final mags = await FirestoreService.fetchMagazines();
      if (mounted) setState(() {
        _all = mags;
        _selectedYear = mags.isNotEmpty ? mags.first.year : DateTime.now().year;
        _loading = false;
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      if (mounted) setState(() {
        _error   = ConnectivityService.friendlyError(e);
        _loading = false;
      });
    }
  }

  List<int> get _years {
    final y = _all.map((m) => m.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return y;
  }

  List<Magazine> get _filtered => _all.where((m) {
    final yearOk = m.year == _selectedYear;
    final searchOk = _search.isEmpty ||
        m.titleEnglish.toLowerCase().contains(_search.toLowerCase()) ||
        m.titleTelugu.contains(_search);
    return yearOk && searchOk;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('యోగ చైతన్య ప్రభ',
              style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('Monthly magazine archive',
              style: TextStyle(
                  fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load),
        ],
        bottom: _loading || _error != null ? null : PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withOpacity(0.6), size: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _years.length,
                itemBuilder: (_, i) {
                  final year = _years[i];
                  final sel  = year == _selectedYear;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedYear = year),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text('$year',
                        style: TextStyle(
                          color: sel ? AppColors.primary : Colors.white,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13))));
                }),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading magazine archive...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _all.isEmpty
                  ? EmptyView(
                      icon: Icons.menu_book_outlined,
                      title: 'No magazines uploaded yet',
                      subtitle: 'Upload magazines via the admin panel\nand they will appear here.',
                      action: TextButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh,
                            color: AppColors.primary, size: 16),
                        label: const Text('Refresh',
                            style: TextStyle(color: AppColors.primary))))
                  : _filtered.isEmpty
                      ? EmptyView(
                          icon: Icons.search_off,
                          title: 'No issues found for $_selectedYear',
                          subtitle: 'Try selecting a different year.')
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) {
                              final mag = _filtered[i];
                              final ci  = i % AppColors.coverColors.length;
                              return GestureDetector(
                                onTap: () => Navigator.push(ctx,
                                  MaterialPageRoute(builder: (_) =>
                                    IssueDetailScreen(magazine: mag))),
                                child: _MagCard(magazine: mag, colorIndex: ci));
                            })),
    );
  }
}

class _MagCard extends StatelessWidget {
  final Magazine magazine;
  final int colorIndex;
  const _MagCard({required this.magazine, required this.colorIndex});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Expanded(child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.coverColors[colorIndex],
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10))),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('YCT • యోగ చైతన్య ప్రభ',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 7)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(magazine.displayMonth,
                style: const TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${magazine.year}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 11)),
            ]),
          ]))),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(magazine.titleTelugu,
            style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500, color: AppColors.textDark)),
          const SizedBox(height: 3),
          Text('${magazine.pages} pages',
            style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ])),
    ]));
}
