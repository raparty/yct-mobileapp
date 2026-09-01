import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/content_service.dart';

class AboutYctScreen extends StatefulWidget {
  const AboutYctScreen({super.key});
  @override
  State<AboutYctScreen> createState() => _AboutYctScreenState();
}

class _AboutYctScreenState extends State<AboutYctScreen> {
  AboutContent? _content;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final c = await ContentService.fetchAbout();
    if (mounted) setState(() { _content = c; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final c = _content ?? AboutContent.fallback();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('About YCT'), backgroundColor: AppColors.primary),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
                  child: const Center(child: Text('YCT', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold))))),
                const SizedBox(height: 12),
                const Center(child: Text('Yoga Consciousness Trust',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                const Center(child: Text('యోగ చైతన్య సంస్థ',
                  style: TextStyle(fontSize: 14, color: AppColors.primary))),
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Est. 1990 · Vijinigiri, Andhra Pradesh',
                    style: TextStyle(fontSize: 12, color: AppColors.textMid)))),
                const SizedBox(height: 20),
                _card('Our Mission', c.mission),
                const SizedBox(height: 10),
                _card('Our Institutes',
                  c.institutes.map((i) => '• $i').join('\n')),
                const SizedBox(height: 10),
                _card('Programmes',
                  'YCT offers a wide range of residential and online programmes including:\n\n'
                  + c.programmes.map((p) => '• $p').join('\n')),
                const SizedBox(height: 10),
                _card('Publications', c.publications),
                const SizedBox(height: 80),
              ]),
            ),
    );
  }

  Widget _card(String title, String content) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      const SizedBox(height: 8),
      Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.6)),
    ]));
}
