// ─────────────────────────────────────────
// YCT — Publications Screen
// Static list of YCT publications from the website.
// PDFs and covers load from Firestore/R2 when available;
// cards are always shown even without uploads.
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/constants.dart';
import '../core/models.dart';
import '../core/firestore_service.dart';
import '../widgets/cover_image.dart';
import 'book_detail_screen.dart';

// Static list sourced from yogaconsciousnesstrust.org/publications
// Each entry: (id, title, titleTelugu, language, description)
const _kStaticBooks = [
  (
    id: 'yoga_chaitanya_prabha',
    title: 'Yoga Chaitanya Prabha',
    titleTelugu: 'యోగ చైతన్య ప్రభ',
    language: 'Telugu',
    description: 'Monthly magazine of Yoga Consciousness Trust.'
  ),
  (
    id: 'anushtana_yoga_vedanta',
    title: 'Anushtana Yoga Vedanta',
    titleTelugu: 'అనుష్ఠాన యోగ వేదాంత',
    language: 'Telugu',
    description: 'Core teachings of Anushtana Yoga philosophy.'
  ),
  (
    id: 'yoga_marga_prabodham',
    title: 'Yoga Marga Prabodham',
    titleTelugu: 'యోగ మార్గ ప్రబోధం',
    language: 'Telugu',
    description: 'Guidance on the path of Yoga.'
  ),
  (
    id: 'chitta_vritti_nirodha',
    title: 'Chitta Vritti Nirodha',
    titleTelugu: 'చిత్త వృత్తి నిరోధ',
    language: 'Telugu',
    description: 'On controlling the fluctuations of the mind.'
  ),
  (
    id: 'dhyana_yoga',
    title: 'Dhyana Yoga',
    titleTelugu: 'ధ్యాన యోగ',
    language: 'Telugu',
    description: 'The yoga of meditation — techniques and philosophy.'
  ),
  (
    id: 'pranayama_rahasya',
    title: 'Pranayama Rahasya',
    titleTelugu: 'ప్రాణాయామ రహస్య',
    language: 'Telugu',
    description: 'Secrets of breathing practices in Yoga.'
  ),
  (
    id: 'kundalini_shakti',
    title: 'Kundalini Shakti',
    titleTelugu: 'కుండలినీ శక్తి',
    language: 'Telugu',
    description: 'Awakening of the dormant spiritual energy.'
  ),
  (
    id: 'nadi_shodhana',
    title: 'Nadi Shodhana',
    titleTelugu: 'నాడీ శోధన',
    language: 'Telugu',
    description: 'Purification of the subtle energy channels.'
  ),
  (
    id: 'samadhi_sopana',
    title: 'Samadhi Sopana',
    titleTelugu: 'సమాధి సోపాన',
    language: 'Telugu',
    description: 'Steps toward the state of Samadhi.'
  ),
  (
    id: 'asana_vigyan',
    title: 'Asana Vigyan',
    titleTelugu: 'ఆసన విజ్ఞాన',
    language: 'Telugu',
    description: 'Science of Yogic postures.'
  ),
  (
    id: 'yoga_philosophy',
    title: 'Yoga Philosophy',
    titleTelugu: 'యోగ తత్వ శాస్త్రం',
    language: 'Telugu & English',
    description: 'Introduction to the philosophical foundations of Yoga.'
  ),
  (
    id: 'guru_charitra',
    title: 'Guru Charitra',
    titleTelugu: 'గురు చరిత్ర',
    language: 'Telugu',
    description: 'Life and teachings of Yogacharya Sri Raparthi Rama Rao.'
  ),
  (
    id: 'bhakti_yoga',
    title: 'Bhakti Yoga',
    titleTelugu: 'భక్తి యోగ',
    language: 'Telugu',
    description: 'The path of devotion in Yoga Vedanta.'
  ),
  (
    id: 'karma_yoga',
    title: 'Karma Yoga',
    titleTelugu: 'కర్మ యోగ',
    language: 'Telugu',
    description: 'Yoga of selfless action.'
  ),
  (
    id: 'jnana_yoga',
    title: 'Jnana Yoga',
    titleTelugu: 'జ్ఞాన యోగ',
    language: 'Telugu',
    description: 'The path of knowledge and self-inquiry.'
  ),
  (
    id: 'yoga_sutras_commentary',
    title: 'Yoga Sutras — Commentary',
    titleTelugu: 'యోగ సూత్రాలు వ్యాఖ్యానం',
    language: 'Telugu',
    description: 'Commentary on Patanjali\'s Yoga Sutras by Yogacharya.'
  ),
  (
    id: 'daily_sadhana',
    title: 'Daily Sadhana',
    titleTelugu: 'దైనందిన సాధన',
    language: 'Telugu & English',
    description: 'A practical guide to daily spiritual practice.'
  ),
];

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // Firestore books keyed by id — for PDF/cover overlay
  Map<String, Book> _firestoreBooks = {};
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadFirestore();
  }

  Future<void> _loadFirestore() async {
    try {
      final books = await FirestoreService.fetchBooks();
      if (mounted) {
        setState(() {
          _firestoreBooks = {for (final b in books) b.id: b};
        });
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
    }
  }

  // Merge static entry with Firestore data if available
  Book _toBook(dynamic entry) {
    final fb = _firestoreBooks[entry.id];
    return Book(
      id:             entry.id,
      title:          entry.title,
      titleTelugu:    entry.titleTelugu,
      language:       entry.language,
      description:    entry.description,
      pdfPath:        fb?.pdfPath        ?? '',
      pdfUrl:         fb?.pdfUrl         ?? '',
      coverImagePath: fb?.coverImagePath ?? '',
      coverImageUrl:  fb?.coverImageUrl  ?? '',
      isPublished:    fb?.isPublished    ?? true,
      sortOrder:      fb?.sortOrder      ?? 0,
    );
  }

  List<Book> get _filtered {
    final all = _kStaticBooks.map(_toBook).toList();
    if (_search.isEmpty) return all;
    final q = _search.toLowerCase();
    return all.where((b) =>
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
            onPressed: _loadFirestore),
        ],
      ),
      body: Column(children: [
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
              ? const Center(child: Text('No results.',
                  style: TextStyle(color: AppColors.textMid)))
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
                    // Cycle through palette colours for fallback covers
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
