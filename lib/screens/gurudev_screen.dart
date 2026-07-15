import 'package:flutter/material.dart';
import '../core/constants.dart';

class GurudevScreen extends StatelessWidget {
  const GurudevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.primaryMid, AppColors.primaryDark])),
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Container(width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2)),
                  child: const Icon(Icons.person, color: Colors.white, size: 44)),
                const SizedBox(height: 12),
                const Text('Yogacharya Sri Raparthi Rama Rao',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('పూజ్య గురుదేవులు', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ])),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('About Gurudev',
              'Yogacharya Sri Raparthi Rama Rao is the founder of Yoga Consciousness Trust (YCT) and a revered spiritual master in the tradition of Anushtana Yoga Vedanta.\n\n'
              'Born with a deep inclination towards spiritual practice, Gurudev dedicated his life to exploring the depths of yoga and Vedantic philosophy, ultimately synthesising these into the comprehensive system of Anushtana Yoga Vedanta — a practical path for self-realisation accessible to all.\n\n'
              'Under his guidance, YCT has grown from a small ashram in Vijinigiri to an organisation with centres across Andhra Pradesh and Telangana, affiliated with multiple universities and serving thousands of seekers.'),
            const SizedBox(height: 16),
            _section('Anushtana Yoga Vedanta',
              'Anushtana Yoga Vedanta is the methodology developed by Gurudev that integrates the practical aspects of Yoga — including asana, pranayama, dharana, and dhyana — with the philosophical wisdom of Vedanta.\n\n'
              'This integrated approach enables the practitioner to purify the body and mind, develop discriminative wisdom (viveka), and ultimately realise the true nature of the Self (Atma Sakshatkar).'),
            const SizedBox(height: 16),
            _section('Teachings',
              'Gurudev\'s teachings are preserved in the monthly journal "Yoga Chaitanya Prabha" (యోగ చైతన్య ప్రభ), numerous books in Telugu and English, and thousands of audio discourses.\n\n'
              'His key teachings include:\n'
              '• The nature of karma and its role in spiritual evolution\n'
              '• Practical techniques for meditation and self-enquiry\n'
              '• The three paths: Karma Yoga, Bhakti Yoga, and Jnana Yoga\n'
              '• The importance of Guru-Shishya relationship in spiritual practice\n'
              '• Vedantic understanding of consciousness and the nature of reality'),
            const SizedBox(height: 16),
            _section('Legacy',
              'Gurudev\'s Aradhana is observed on 26th October each year, when thousands of devotees gather at Yoga Chaitanyaramam, Vijinigiri to pay their respects and renew their commitment to sadhana.\n\n'
              'His teachings continue through YCT\'s network of institutes, residential programmes, and publications that reach seekers across the world.'),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }

  Widget _section(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.7)),
      ]),
    );
  }
}
