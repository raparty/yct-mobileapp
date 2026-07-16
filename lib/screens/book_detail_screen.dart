import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/models.dart';
import 'pdf_viewer_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(book.title, style: const TextStyle(fontSize: 15)),
        backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 120, height: 160,
            decoration: BoxDecoration(color: book.coverColor, borderRadius: BorderRadius.circular(6),
              boxShadow: [BoxShadow(color: book.coverColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0,10))]),
            child: Center(child: Text('YCT',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.bold))))),
          const SizedBox(height: 20),
          Center(child: Text(book.title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark))),
          if (book.titleTelugu.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(child: Text(book.titleTelugu,
              style: const TextStyle(fontSize: 14, color: AppColors.textMid))),
          ],
          const SizedBox(height: 8),
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: Text(book.language, style: const TextStyle(fontSize: 12, color: AppColors.primaryDark)))),
          const SizedBox(height: 20),
          if (book.description.isNotEmpty) ...[
            const Text('ABOUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMid, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(book.description, style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.6)),
            const SizedBox(height: 20),
          ],
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: book.pdfUrl.isNotEmpty ? () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PdfViewerScreen(title: book.title, pdfUrl: book.pdfUrl))) : null,
              icon: const Icon(Icons.menu_book, color: Colors.white),
              label: const Text('Read this book',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}
