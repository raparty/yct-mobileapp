import 'package:flutter/material.dart';

class AppColors {
  // ── YCT Brand Colors (extracted from yogaconsciousness.org) ──
  // Primary forest green — website header, main brand color
  static const primary      = Color(0xFF2D5A2D);
  // Mid green — buttons, accents
  static const primaryMid   = Color(0xFF3C783C);
  // Dark green — status bar, hero gradients
  static const primaryDark  = Color(0xFF1E3C1E);
  // Light green — backgrounds, chips
  static const primaryLight = Color(0xFFE8F5E8);
  // Teal — from YCT Om logo snake color
  static const teal         = Color(0xFF00A08C);

  // ── Saffron/Gold — from Om symbol in YCT logo ──
  static const saffron      = Color(0xFFF0A03C);
  static const saffronDark  = Color(0xFFDC7828);

  // ── Neutral tones ──
  static const bg           = Color(0xFFF5F3EE);
  static const white        = Color(0xFFFFFFFF);
  static const border       = Color(0xFFD3D1C7);
  static const textDark     = Color(0xFF2C2C2A);
  static const textMid      = Color(0xFF5F5E5A);
  static const textLight    = Color(0xFF888780);
  static const textMuted    = Color(0xFFB4B2A9);

  // ── Secondary palette ──
  static const purple       = Color(0xFF534AB7);
  static const blue         = Color(0xFF185FA5);
  static const amber        = Color(0xFF854F0B);
  static const amberLight   = Color(0xFFFAEEDA);

  // ── Magazine cover colors — YCT themed ──
  static const List<Color> coverColors = [
    Color(0xFF2D5A2D),  // Forest green
    Color(0xFF1E3C5A),  // Deep blue-green
    Color(0xFF3C2D5A),  // Deep purple
    Color(0xFF5A3C1E),  // Deep saffron-brown
    Color(0xFF1E4A3C),  // Deep teal
    Color(0xFF3C1E2D),  // Deep maroon
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

class SheetConfig {
  static const sheetId        = '12yAED0Eo29odVliNbYKVrBD7jxlI5TCiQa_EQNX6A5s';
  static const magazinesTab   = 'magazines';
  static const booksTab       = 'books';
  static const audioTab       = 'audio';
  static const settingsTab    = 'settings';

  static String tabUrl(String tab) =>
      'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq'
      '?tqx=out:json&sheet=$tab';
}
