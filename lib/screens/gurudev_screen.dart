import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/content_service.dart';

class GurudevScreen extends StatefulWidget {
  const GurudevScreen({super.key});
  @override
  State<GurudevScreen> createState() => _GurudevScreenState();
}

class _GurudevScreenState extends State<GurudevScreen> {
  GurudevContent? _content;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final c = await ContentService.fetchGurudev();
    if (mounted) setState(() { _content = c; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final c = _content ?? GurudevContent.fallback();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 280, pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppColors.primaryDark, AppColors.primary])),
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.saffron, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16)]),
                  child: ClipOval(child: Image.asset('assets/images/guruji.jpg', fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryMid,
                      child: const Icon(Icons.person, color: Colors.white, size: 60))))),
                const SizedBox(height: 14),
                const Text('పూజ్య గురుదేవులు',
                  style: TextStyle(color: AppColors.teal, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('Yogacharya Sri Raparthi Rama Rao',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Founder, Yoga Consciousness Trust',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ])),
            ),
          ),
        ),
        if (_loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('About Gurudev',
                '${c.aboutParagraph1}\n\n${c.aboutParagraph2}\n\n${c.aboutParagraph3}'),
              const SizedBox(height: 12),
              _section(c.avSection,
                '${c.avParagraph1}\n\n${c.avParagraph2}'),
              const SizedBox(height: 12),
              _section('Teachings',
                '${c.teachingsIntro}\n${c.teachingsBullets.map((b) => '• $b').join('\n')}'),
              const SizedBox(height: 12),
              _section('Legacy', c.legacyText),
              const SizedBox(height: 80),
            ]),
          )),
      ]),
    );
  }

  Widget _section(String title, String content) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      const SizedBox(height: 10),
      Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.7)),
    ]));
}
