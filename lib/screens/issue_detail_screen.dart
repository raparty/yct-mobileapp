import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/models.dart';
import 'pdf_viewer_screen.dart';

class IssueDetailScreen extends StatelessWidget {
  final Magazine magazine;
  const IssueDetailScreen({super.key, required this.magazine});

  @override
  Widget build(BuildContext context) {
    final mag = magazine;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: mag.coverColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: mag.coverColor,
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                // Cover
                Container(
                  width: 90, height: 120,
                  decoration: BoxDecoration(
                    color: mag.coverColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0,8))]),
                  padding: const EdgeInsets.all(8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('యోగ చైతన్య ప్రభ', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 7)),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(mag.displayMonth, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('${mag.year} • Vol.${mag.volume}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 8)),
                    ]),
                  ])),
                const SizedBox(height: 12),
                Text('${mag.titleTelugu} — Vol. ${mag.volume}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('యోగ చైతన్య ప్రభ • Monthly',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _chip('${mag.pages} pages'),
                  const SizedBox(width: 6), _chip('Telugu'),
                  const SizedBox(width: 6), _chip(mag.displayMonth),
                ]),
              ])),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Single Read button — no share/download
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: mag.hasPdf ? () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PdfViewerScreen(
                    title: '${mag.displayMonth} ${mag.year}',
                    pdfUrl: mag.pdfUrl))) : null,
                icon: const Icon(Icons.menu_book, color: Colors.white),
                label: const Text('Read this issue',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )),
            if (!mag.hasPdf) ...[
              const SizedBox(height: 8),
              const Text('PDF not yet uploaded for this issue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
            const SizedBox(height: 20),
            const Text('ABOUT THIS ISSUE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMid, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _row('Volume', '${mag.volume}'),
                _row('Month', mag.displayMonth),
                _row('Year', '${mag.year}'),
                _row('Pages', '${mag.pages}'),
                _row('Language', 'Telugu'),
                _row('Publisher', 'Yoga Consciousness Trust'),
              ])),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11)));

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(l, style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
      const Spacer(),
      Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
    ]));
}
