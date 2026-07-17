import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import 'gurudev_screen.dart';
import 'about_yct_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('More'), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity, color: AppColors.primary,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]),
                child: ClipOval(child: Image.asset('assets/images/yct_logo.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Text('YCT', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)))))),
              const SizedBox(height: 10),
              const Text(AppStrings.appName, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(AppStrings.appNameTelugu, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ABOUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMid, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              _MenuCard(items: [
                _MenuItem(Icons.person_outline, 'About Gurudev', 'Life and teachings of Yogacharya Sri Raparthi Rama Rao',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GurudevScreen()))),
                _MenuItem(Icons.info_outline, 'About YCT', 'Our mission, institutes and programmes',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutYctScreen()))),
                _MenuItem(Icons.school_outlined, 'Anushtana Yoga Vedanta', 'Our methodology explained in Gurudev section',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GurudevScreen()))),
              ]),
              const SizedBox(height: 20),
              const Text('CONTACT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMid, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              _MenuCard(items: [
                _MenuItem(Icons.language, 'Website', AppStrings.website, () => _open(AppStrings.website)),
                _MenuItem(Icons.chat_outlined, 'WhatsApp', 'Chat with us', () => _open(AppStrings.whatsapp)),
                _MenuItem(Icons.email_outlined, 'Email', 'info@yogaconsciousness.org', () => _open('mailto:${'info@yogaconsciousness.org'}')),
                _MenuItem(Icons.phone_outlined, 'Phone', '+91 89662 68680', () => _open('tel:+918966268680')),
              ]),
              const SizedBox(height: 20),
              const Text('PUBLICATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMid, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              _MenuCard(items: [
                _MenuItem(Icons.shopping_bag_outlined, 'Buy Publications', 'Order books and magazines online', () => _open('${AppStrings.website}/shop')),
                _MenuItem(Icons.subscriptions_outlined, 'Subscribe to Magazine', 'Get యోగ చైతన్య ప్రభ monthly', () => _open('mailto:${'info@yogaconsciousness.org'}')),
              ]),
              const SizedBox(height: 20),
              Center(child: Text('Version 1.0.0 · Yoga Consciousness Trust', style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
              const SizedBox(height: 80),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap);
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(children: items.asMap().entries.map((e) => Column(children: [
      ListTile(
        leading: Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(e.value.icon, color: AppColors.primary, size: 18)),
        title: Text(e.value.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        subtitle: Text(e.value.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textMuted),
        onTap: e.value.onTap),
      if (e.key < items.length - 1) const Divider(height: 1, indent: 64, color: AppColors.border),
    ])).toList()),
  );
}
