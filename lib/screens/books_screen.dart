// ─────────────────────────────────────────
// YCT — Publications Screen
// Books load from Firestore backend (uploaded via admin panel).
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import '../widgets/cover_image.dart';
import 'book_detail_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> _books = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final books = await FirestoreService.fetchBooks();
      if (mounted) setState(() { _books = books; _loading = false; });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Book> get _filtered {
    if (_search.isEmpty) return _books;
    final q = _search.toLowerCase();
    return _books.where((b) =>
        b.title.toLowerCase().contains(q) ||
        b.titleTelugu.contains(q) ||
        b.language.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final books = _filtered;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Publications'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search books...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                      onPressed: () => setState(() => _search = ''))
                  : null,
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('${books.length} title${books.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMid,
                  fontWeight: FontWeight.w500)),
          ])),
        Expanded(
          child: books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_outlined,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        _search.isNotEmpty
                            ? 'No books match "$_search"'
                            : 'No publications uploaded yet',
                        style: const TextStyle(
                            color: AppColors.textMid, fontSize: 14)),
                      if (_search.isEmpty) ...[
                        const SizedBox(height: 6),
                        const Text('Upload books via the admin panel.',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ],
                  ))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                  itemCount: books.length,
                  itemBuilder: (ctx, i) {
                    final book = books[i];
                    final paletteColor = AppColors.coverColors[
                        i % AppColors.coverColors.length];
                    return GestureDetector(
                      onTap: () => Navigator.push(ctx,
                        MaterialPageRoute(builder: (_) =>
                          BookDetailScreen(book: book))),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6, offset: const Offset(0, 2))]),
                        child: Column(children: [
                          Expanded(child: BookCover(
                            imageUrl:      book.coverImageUrl,
                            fallbackColor: paletteColor,
                            title:         book.title,
                            borderRadius:  10)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(book.title,
                                  style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: AppColors.textDark),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8)),
                                  child: Text(book.language,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.primaryDark))),
                              ])),
                        ])));
                  }),
        ),
      ]),
    );
  }
}
