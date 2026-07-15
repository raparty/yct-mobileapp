import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/models.dart';

class IssueDetailScreen extends StatefulWidget {
  final Magazine magazine;
  const IssueDetailScreen({super.key, required this.magazine});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_magazines') ?? [];
    if (mounted) setState(() => _saved = saved.contains(widget.magazine.id));
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_magazines') ?? [];
    if (_saved) {
      saved.remove(widget.magazine.id);
    } else {
      saved.add(widget.magazine.id);
    }
    await prefs.setStringList('saved_magazines', saved);
    if (mounted) setState(() => _saved = !_saved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_saved ? 'Saved to your library' : 'Removed from library'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openPdf() async {
    final url = widget.magazine.viewUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF link not available yet')));
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _download() async {
    final url = widget.magazine.directPdfUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _share() {
    final mag = widget.magazine;
    Share.share(
      '${AppStrings.magazineName} — ${mag.titleEnglish}\n'
      'Read the latest issue of YCT\'s monthly magazine.\n'
      '${mag.viewUrl}\n\n'
      '${AppStrings.website}',
      subject: '${AppStrings.magazineName} — ${mag.titleEnglish}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mag = widget.magazine;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: mag.coverColor,
            actions: [
              IconButton(
                icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white),
                onPressed: _toggleSave,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _share,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: mag.coverColor,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Magazine cover mock
                      Container(
                        width: 100, height: 130,
                        decoration: BoxDecoration(
                          color: mag.coverColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 2),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 16, offset: const Offset(0, 8))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('యోగ చైతన్య ప్రభ',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 7)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mag.displayMonth,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                  Text('${mag.year} • Vol.${mag.volume}',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 8)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('${mag.titleTelugu} — Vol. ${mag.volume}',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('యోగ చైతన్య ప్రభ • Monthly magazine',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _chip('${mag.pages} pages'),
                          const SizedBox(width: 6),
                          _chip('Telugu'),
                          const SizedBox(width: 6),
                          _chip(mag.displayMonth),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary action — Read
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openPdf,
                      icon: const Icon(Icons.menu_book, color: Colors.white),
                      label: const Text('Read this issue',
                        style: TextStyle(color: Colors.white,
                            fontSize: 15, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Secondary actions — Download & Share
                  Row(children: [
                    Expanded(child: _ActionBtn(
                      icon: Icons.download_outlined,
                      label: 'Download',
                      onTap: _download,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _ActionBtn(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: _share,
                    )),
                  ]),
                  const SizedBox(height: 20),
                  const Text('ABOUT THIS ISSUE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textMid, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(children: [
                      _infoRow('Volume', '${mag.volume}'),
                      _infoRow('Issue', '${mag.month}'),
                      _infoRow('Year', '${mag.year}'),
                      _infoRow('Pages', '${mag.pages}'),
                      _infoRow('Language', 'Telugu'),
                      _infoRow('Publisher', 'Yoga Consciousness Trust'),
                    ]),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
        style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.textMid)),
        const Spacer(),
        Text(value, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: AppColors.textDark)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
              fontSize: 11, color: AppColors.textMid)),
        ]),
      ),
    );
  }
}
