import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFF2D5A2D);
  static const primaryMid   = Color(0xFF3C783C);
  static const primaryDark  = Color(0xFF1E3C1E);
  static const primaryLight = Color(0xFFE8F5E8);
  static const teal         = Color(0xFF00A08C);
  static const saffron      = Color(0xFFF0A03C);
  static const saffronDark  = Color(0xFFDC7828);
  static const bg           = Color(0xFFF5F3EE);
  static const white        = Color(0xFFFFFFFF);
  static const border       = Color(0xFFD3D1C7);
  static const textDark     = Color(0xFF2C2C2A);
  static const textMid      = Color(0xFF5F5E5A);
  static const textLight    = Color(0xFF888780);
  static const textMuted    = Color(0xFFB4B2A9);
  static const purple       = Color(0xFF534AB7);
  static const blue         = Color(0xFF185FA5);
  static const amber        = Color(0xFF854F0B);
  static const amberLight   = Color(0xFFFAEEDA);
  static const List<Color> coverColors = [
    Color(0xFF2D5A2D), Color(0xFF1E3C5A), Color(0xFF3C2D5A),
    Color(0xFF5A3C1E), Color(0xFF1E4A3C), Color(0xFF3C1E2D),
  ];
}

class AppStrings {
  static const appName        = 'Yoga Consciousness Trust';
  static const appNameTelugu  = 'యోగ చైతన్య సంస్థ';
  static const magazineName   = 'యోగ చైతన్య ప్రభ';
  static const guruName       = 'Yogacharya Sri Raparthi Rama Rao';
  static const contactEmail   = 'yctdesk@gmail.com';
  static const website        = 'https://www.yogaconsciousness.org';
  static const whatsapp       = 'https://wa.me/918966268680';
}

class R2Config {
  // Cloudflare R2 public URL — all content served from here
  static const baseUrl = 'https://pub-360b7b3324fb4f22bb35e656f476062a.r2.dev';

  // Build full URL from a stored path
  static String url(String path) => '$baseUrl/$path';
}
