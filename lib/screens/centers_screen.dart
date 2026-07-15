import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

class CentersScreen extends StatelessWidget {
  const CentersScreen({super.key});

  static const _centers = [
    _Center('Yoga Chaitanyaramam — Vijinigiri',
        'Headquarters & Ashram',
        'Vijinigiri-535 250, Jami Mandal, Vizianagaram Dist, A.P.',
        '+918966268680', true),
    _Center('International Institute of Yoga Research & Training',
        'Bhimili Branch',
        'Krishna Colony, Bhimili-531 163, Visakha Dist.',
        '+918933228222', false),
    _Center('Academy of Yoga Consciousness',
        'Bhimili — Affiliated to Andhra University',
        'Bhimili, Visakhapatnam', '', false),
    _Center('Sri Raparti Rama Institute of Yoga',
        'Kanavaram — Affiliated to Adi Kavi Nannaya University',
        'Kanavaram, Godavari District', '', false),
    _Center('Sri Raparti Rama Institute of Yoga',
        'Kakinada — Affiliated to Adi Kavi Nannaya University',
        'Kakinada, Andhra Pradesh', '', false),
    _Center('Sri Raparti Rama Academy of Yogic Sciences',
        'Nandyal — Affiliated to Rayalaseema University',
        'Nandyal, Kurnool District', '', false),
    _Center('Hyderabad Center',
        'Kondapur Branch',
        'Kondapur, Hyderabad, Telangana', '', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Our Centers'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined,
                        color: AppColors.primary, size: 36),
                    const SizedBox(height: 8),
                    const Text('YCT Centers across AP & Telangana',
                      style: TextStyle(color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(
                          'https://maps.google.com/?q=Yoga+Chaitanyaramam+Vijinigiri')),
                      child: const Text('Open in Maps →',
                        style: TextStyle(color: AppColors.primary,
                            fontSize: 12, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('ALL CENTERS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textMid, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            ..._centers.map((c) => _CenterCard(center: c)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _Center {
  final String name, subtitle, address, phone;
  final bool isHeadquarters;
  const _Center(
      this.name, this.subtitle, this.address, this.phone,
      this.isHeadquarters);
}

class _CenterCard extends StatelessWidget {
  final _Center center;
  const _CenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: center.isHeadquarters
                ? AppColors.primary
                : AppColors.border,
            width: center.isHeadquarters ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(center.name,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            ),
            if (center.isHeadquarters)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('HQ',
                  style: TextStyle(fontSize: 10,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 3),
          Text(center.subtitle,
            style: const TextStyle(fontSize: 11,
                color: AppColors.primary)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on_outlined,
                size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(center.address,
                style: const TextStyle(fontSize: 11,
                    color: AppColors.textLight, height: 1.4)),
            ),
          ]),
          if (center.phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('tel:${center.phone}')),
              child: Row(children: [
                const Icon(Icons.phone_outlined,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(center.phone,
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
