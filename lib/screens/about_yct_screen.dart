import 'package:flutter/material.dart';
import '../core/constants.dart';

class AboutYctScreen extends StatelessWidget {
  const AboutYctScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('About YCT'), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Logo
          Center(child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
            child: const Center(child: Text('YCT', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold))))),
          const SizedBox(height: 12),
          const Center(child: Text('Yoga Consciousness Trust', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark))),
          const Center(child: Text('యోగ చైతన్య సంస్థ', style: TextStyle(fontSize: 14, color: AppColors.primary))),
          const Center(child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Est. 1990 · Vijinigiri, Andhra Pradesh', style: TextStyle(fontSize: 12, color: AppColors.textMid)))),
          const SizedBox(height: 20),
          _card('Our Mission',
            'To spread the ancient wisdom of Anushtana Yoga Vedanta to all seekers, making the path of self-realisation accessible through practical teaching, residential programmes, and publications.'),
          const SizedBox(height: 10),
          _card('Our Institutes', 
            '• Academy of Yoga Consciousness, Bhimili — Affiliated to Andhra University\n'
            '• International Institute of Yoga Research & Training, Bhimili\n'
            '• Sri Raparti Rama Institute of Yoga, Kanavaram — Adi Kavi Nannaya University\n'
            '• Sri Raparti Rama Institute of Yoga, Kakinada — Adi Kavi Nannaya University\n'
            '• Sri Raparti Rama Academy of Yogic Sciences, Nandyal — Rayalaseema University'),
          const SizedBox(height: 10),
          _card('Programmes',
            'YCT offers a wide range of residential and online programmes including:\n\n'
            '• Antar Mouna — silent retreat\n'
            '• Chaitanya Prakasha Yoga — dharana & meditation\n'
            '• Anusthana Yoga Vedanta Course (AYVC)\n'
            '• Health Management Camps through Yoga\n'
            '• Personality Development Camps for Youth\n'
            '• Sadhana Saptaha — 7-day intensive retreats'),
          const SizedBox(height: 10),
          _card('Publications',
            'YCT publishes the monthly journal "Yoga Chaitanya Prabha" (యోగ చైతన్య ప్రభ) since 1990, along with numerous books in Telugu, English, and bilingual formats covering the complete teachings of Anushtana Yoga Vedanta.'),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _card(String title, String content) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      const SizedBox(height: 8),
      Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.6)),
    ]));
}
