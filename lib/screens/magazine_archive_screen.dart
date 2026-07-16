import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import 'issue_detail_screen.dart';

class MagazineArchiveScreen extends StatefulWidget {
  const MagazineArchiveScreen({super.key});

  @override
  State<MagazineArchiveScreen> createState() => _MagazineArchiveScreenState();
}

class _MagazineArchiveScreenState extends State<MagazineArchiveScreen> {
  List<Magazine> _all = [];
  bool _loading = true;
  int _selectedYear = 0;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mags = await FirestoreService.fetchMagazines();
    if (mounted) {
      setState(() {
        _all = mags;
        _selectedYear = mags.isNotEmpty ? mags.first.year : DateTime.now().year;
        _loading = false;
      });
    }
  }

  List<int> get _years {
    final years = _all.map((m) => m.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  }

  List<Magazine> get _filtered {
    return _all.where((m) {
      final yearMatch = m.year == _selectedYear;
      final searchMatch = _search.isEmpty ||
          m.titleEnglish.toLowerCase().contains(_search.toLowerCase()) ||
          m.titleTelugu.contains(_search);
      return yearMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('యోగ చైతన్య ప్రభ',
              style: TextStyle(fontSize: 16, color: Colors.white)),
            Text('Monthly magazine archive',
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withOpacity(0.8))),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by topic, year, keyword...',
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
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Year tabs
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _years.length,
                itemBuilder: (_, i) {
                  final year = _years[i];
                  final selected = year == _selectedYear;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedYear = year),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$year',
                        style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : Colors.white,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary))
          : _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No issues found for $_selectedYear',
                        style: const TextStyle(color: AppColors.textMid)),
                      const SizedBox(height: 8),
                      const Text('Upload PDFs and add rows to the Google Sheet',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_selectedYear',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.textMid,
                            letterSpacing: 0.5)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final mag = _filtered[i];
                            final colorIndex =
                                i % AppColors.coverColors.length;
                            return GestureDetector(
                              onTap: () => Navigator.push(ctx,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      IssueDetailScreen(magazine: mag))),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors
                                            .coverColors[colorIndex],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(10)),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'YCT • యోగ చైతన్య ప్రభ',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                fontSize: 7),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(mag.displayMonth,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                              Text('${mag.year}',
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 11)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(mag.titleTelugu,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textDark)),
                                        const SizedBox(height: 4),
                                        Text('${mag.pages} pages',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
