import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFF2D5A46); // updated to Meditative Sage green
  static const primaryMid   = Color(0xFF3B7A5E);
  static const primaryDark  = Color(0xFF1E3F31);
  static const primaryLight = Color(0xFFE8F5EE);
  static const teal         = Color(0xFF80CBC4);
  static const saffron      = Color(0xFFD4A359); // gold accent
  static const saffronDark  = Color(0xFFC4922A);
  static const bg           = Color(0xFFF4F7F5); // updated — pale mist
  static const white        = Color(0xFFFFFFFF);
  static const border       = Color(0xFFE8EDE9);
  static const textDark     = Color(0xFF1A1A1A);
  static const textMid      = Color(0xFF6B7280);
  static const textLight    = Color(0xFF9CA3AF);
  static const textMuted    = Color(0xFFB4B2A9);
  static const purple       = Color(0xFF534AB7);
  static const blue         = Color(0xFF185FA5);
  static const amber        = Color(0xFF854F0B);
  static const amberLight   = Color(0xFFFAEEDA);
  static const List<Color> coverColors = [
    Color(0xFF2D5A46), Color(0xFF1E3C5A), Color(0xFF3C2D5A),
    Color(0xFF5A3C1E), Color(0xFF1E4A3C), Color(0xFF3C1E2D),
  ];
}

class AppStrings {
  static const appName        = 'Yoga Consciousness Trust';
  static const appNameTelugu  = 'యోగ చైతన్య సంస్థ';
  static const magazineName   = 'యోగ చైతన్య ప్రభ';
  static const guruName       = 'Yogacharya Sri Raparthi Rama Rao';
  static const contactEmail   = 'info@yogaconsciousness.org';
  static const website        = 'https://www.yogaconsciousness.org';
  static const whatsapp       = 'https://wa.me/919492448840';
}

class R2Config {
  static const baseUrl = 'https://pub-360b7b3324fb4f22bb35e656f476062a.r2.dev';
  static String url(String path) => '$baseUrl/$path';
}
