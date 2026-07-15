import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri,
        mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // YCT banner
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Center(
                    child: Text('YCT',
                      style: TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(AppStrings.appName,
                  style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(AppStrings.appNameTelugu,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 4),
                Text('Spreading the light of Anushtana Yoga Vedanta since 1990',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 11)),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ABOUT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textMid, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  _MenuCard(items: [
                    _MenuItem(Icons.person_outline, 'About Gurudev',
                        'Life and teachings of Yogacharya Sri Raparthi Rama Rao',
                        () => _open(AppStrings.website)),
                    _MenuItem(Icons.info_outline, 'About YCT',
                        'Our mission, vision and history',
                        () => _open('${AppStrings.website}/about')),
                    _MenuItem(Icons.school_outlined, 'Anushtana Yoga Vedanta',
                        'Our methodology and approach',
                        () => _open(AppStrings.website)),
                  ]),

                  const SizedBox(height: 20),
                  const Text('CONTACT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textMid, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  _MenuCard(items: [
                    _MenuItem(Icons.language, 'Website',
                        AppStrings.website,
                        () => _open(AppStrings.website)),
                    _MenuItem(Icons.chat_outlined, 'WhatsApp',
                        'Chat with us on WhatsApp',
                        () => _open(AppStrings.whatsapp)),
                    _MenuItem(Icons.email_outlined, 'Email',
                        AppStrings.contactEmail,
                        () => _open('mailto:${AppStrings.contactEmail}')),
                    _MenuItem(Icons.phone_outlined, 'Phone',
                        '+91 89662 68680',
                        () => _open('tel:+918966268680')),
                  ]),

                  const SizedBox(height: 20),
                  const Text('PUBLICATIONS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textMid, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  _MenuCard(items: [
                    _MenuItem(Icons.shopping_bag_outlined, 'Buy Publications',
                        'Order books and magazines online',
                        () => _open('${AppStrings.website}/shop')),
                    _MenuItem(Icons.subscriptions_outlined, 'Subscribe to Magazine',
                        'Get योग चैतन्य प्रभ monthly',
                        () => _open('mailto:${AppStrings.contactEmail}')),
                  ]),

                  const SizedBox(height: 20),
                  Center(
                    child: Text('Version 1.0.0 · Yoga Consciousness Trust',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap);
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(children: [
            ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon,
                    color: AppColors.primary, size: 18),
              ),
              title: Text(item.title,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
              subtitle: Text(item.subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textLight),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 13, color: AppColors.textMuted),
              onTap: item.onTap,
            ),
            if (i < items.length - 1)
              const Divider(height: 1,
                  indent: 64, color: AppColors.border),
          ]);
        }).toList(),
      ),
    );
  }
}
