import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import '../core/connectivity_service.dart';
import '../widgets/error_view.dart';
import 'magazine_archive_screen.dart';
import 'issue_detail_screen.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Magazine> _magazines = [];
  List<Book>     _books     = [];
  bool   _loading = true;
  String? _error;
  String _search  = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        FirestoreService.fetchMagazines(),
        FirestoreService.fetchBooks(),
      ]);
      if (mounted) setState(() {
        _magazines = results[0] as List<Magazine>;
        _books     = results[1] as List<Book>;
        _loading   = false;
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      if (mounted) setState(() {
        _error   = ConnectivityService.friendlyError(e);
        _loading = false;
      });
    }
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textDark,
            title: const Text('Publications',
              style: TextStyle(color: AppColors.textDark,
                  fontSize: 18, fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: _load)
            ],
            bottom: _loading || _error != null ? null : PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,0,16,8),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search titles...',
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textMuted, size: 20),
                      filled: true, fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tab,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMid,
                  indicatorColor: AppColors.primary,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                  tabs: [
                    Tab(text: 'Magazine (${_magazines.length})'),
                    Tab(text: 'Books (${_books.length})'),
                    const Tab(text: 'All'),
                  ],
                ),
              ])),
          ),
        ],
        body: _loading
            ? const LoadingView(message: 'Loading publications...')
            : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : TabBarView(
                    controller: _tab,
                    children: [
                      _MagTab(magazines: _magazines, search: _search),
                      _BooksTab(books: _books, search: _search),
                      _BooksTab(books: _books, search: _search),
                    ]),
      ),
    );
  }
}

class _MagTab extends StatelessWidget {
  final List<Magazine> magazines; final String search;
  const _MagTab({required this.magazines, required this.search});

  @override
  Widget build(BuildContext context) {
    if (magazines.isEmpty) return EmptyView(
      icon: Icons.menu_book_outlined,
      title: 'No magazines uploaded yet',
      subtitle: 'Upload magazines via the admin panel\nand they will appear here.');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MagazineArchiveScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.auto_stories,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('యోగ చైతన్య ప్రభ — Full Archive',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark)),
                  Text('Browse all ${magazines.length} issues by year',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMid)),
                ])),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.primary, size: 14),
            ]))),
        const SizedBox(height: 16),
        const Text('RECENT ISSUES',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.textMid, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.72,
            crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: magazines.take(6).length,
          itemBuilder: (ctx, i) {
            final mag = magazines[i];
            final ci  = i % AppColors.coverColors.length;
            return GestureDetector(
              onTap: () => Navigator.push(ctx, MaterialPageRoute(
                builder: (_) => IssueDetailScreen(magazine: mag))),
              child: Container(
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  Expanded(child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.coverColors[ci],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10))),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('YCT',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 7)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mag.displayMonth,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${mag.year}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11)),
                          ]),
                      ]))),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(mag.titleTelugu,
                          style: const TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark)),
                        if (i==0) Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10)),
                          child: const Text('Latest',
                            style: TextStyle(fontSize: 9,
                                color: AppColors.primaryDark))),
                      ])),
                ])));
          }),
      ]));
  }
}

class _BooksTab extends StatelessWidget {
  final List<Book> books; final String search;
  const _BooksTab({required this.books, required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = search.isEmpty ? books
        : books.where((b) =>
            b.title.toLowerCase().contains(search.toLowerCase()) ||
            b.titleTelugu.contains(search)).toList();

    if (books.isEmpty) return EmptyView(
      icon: Icons.book_outlined,
      title: 'No books uploaded yet',
      subtitle: 'Upload books via the admin panel\nand they will appear here.');

    if (filtered.isEmpty) return EmptyView(
      icon: Icons.search_off,
      title: 'No books match "$search"',
      subtitle: 'Try a different search term.');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final book = filtered[i];
        return GestureDetector(
          onTap: () => Navigator.push(ctx, MaterialPageRoute(
            builder: (_) => BookDetailScreen(book: book))),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(width: 48, height: 64,
                decoration: BoxDecoration(color: book.coverColor,
                  borderRadius: BorderRadius.circular(4)),
                child: Center(child: Text('YCT',
                  style: TextStyle(color: Colors.white.withOpacity(0.9),
                    fontSize: 8, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                  if (book.titleTelugu.isNotEmpty)
                    Text(book.titleTelugu,
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.textMid)),
                  const SizedBox(height: 4),
                  Text(book.description,
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textLight),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10)),
                    child: Text(book.language,
                      style: const TextStyle(fontSize: 10,
                          color: AppColors.primaryDark))),
                ])),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.textMuted, size: 14),
            ])));
      });
  }
}
