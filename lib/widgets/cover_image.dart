// ─────────────────────────────────────────
// YCT — Cover Image Widget
// Priority order:
// 1. Specific cover uploaded for this issue
// 2. Generic monthly cover from R2 (1.jpeg to 12.jpeg)
// 3. Colored placeholder (if R2 cover also fails)
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/constants.dart';

class MagazineCover extends StatelessWidget {
  final String? imageUrl;
  final Color fallbackColor;
  final String month;
  final int year;
  final int monthNumber; // 1-12, used to pick generic cover
  final double borderRadius;

  const MagazineCover({
    super.key,
    required this.imageUrl,
    required this.fallbackColor,
    required this.month,
    required this.year,
    required this.monthNumber,
    this.borderRadius = 8,
  });

  // Generic cover URL based on month (1-12)
  String get _genericCoverUrl {
    final m = ((monthNumber - 1) % 12 + 1).clamp(1, 12);
    return '${R2Config.baseUrl}/covers/$m.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final hasSpecificCover = imageUrl != null && imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasSpecificCover
          ? _networkImage(imageUrl!, fallbackToGeneric: true)
          : _networkImage(_genericCoverUrl, fallbackToGeneric: false),
    );
  }

  Widget _networkImage(String url, {required bool fallbackToGeneric}) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: fallbackColor.withOpacity(0.3),
              child: const Center(child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)))),
      errorBuilder: (_, __, ___) => fallbackToGeneric
          ? _networkImage(_genericCoverUrl, fallbackToGeneric: false)
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: fallbackColor,
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('యోగ చైతన్య ప్రభ',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 7)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(month, style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text('$year', style: TextStyle(
            color: Colors.white.withOpacity(0.8), fontSize: 11)),
        ]),
      ]));
}

class BookCover extends StatelessWidget {
  final String? imageUrl;
  final Color fallbackColor;
  final String title;
  final double borderRadius;

  const BookCover({
    super.key,
    required this.imageUrl,
    required this.fallbackColor,
    required this.title,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: fallbackColor,
    padding: const EdgeInsets.all(10),
    child: Center(child: Text(title,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white,
          fontSize: 12, fontWeight: FontWeight.w600, height: 1.4))));
}
