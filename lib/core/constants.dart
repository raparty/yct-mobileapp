// ─────────────────────────────────────────
// YCT App — Constants
// ─────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFF0F6E56);
  static const primaryDark  = Color(0xFF085041);
  static const primaryMid   = Color(0xFF1D9E75);
  static const primaryLight = Color(0xFFE1F5EE);
  static const teal         = Color(0xFF9FE1CB);

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

  // Cover colors for magazine issues (cycles through)
  static const List<Color> coverColors = [
    Color(0xFF0F6E56),
    Color(0xFF534AB7),
    Color(0xFF185FA5),
    Color(0xFF854F0B),
    Color(0xFF993C1D),
    Color(0xFF3B6D11),
  ];
}

class AppStrings {
  static const appName        = 'Yoga Consciousness Trust';
  static const appNameTelugu  = 'యోగ చైతన్య సంస్థ';
  static const magazineName   = 'యోగ చైతన్య ప్రభ';
  static const guruName       = 'Yogacharya Sri Raparthi Rama Rao';
  static const contactEmail   = 'info@yogaconsciousness.org';
  static const website        = 'https://www.yogaconsciousness.org';
  static const whatsapp       = 'https://wa.me/918966268680';
}

class SheetConfig {
  // Google Sheet ID
  static const sheetId = '12yAED0Eo29odVliNbYKVrBD7jxlI5TCiQa_EQNX6A5s';

  // Tab names (must match your sheet tabs exactly)
  static const magazinesTab = 'magazines';
  static const booksTab     = 'books';
  static const audioTab     = 'audio';
  static const settingsTab  = 'settings';

  // Google Sheets API — public read, no API key needed
  static String tabUrl(String tab) =>
      'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq'
      '?tqx=out:json&sheet=$tab';
}
