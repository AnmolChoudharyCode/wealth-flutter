import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand palette
  static const Color dark = Color(0xFF2C2C2C);
  static const Color darkPurple = Color(0xFF612D53);
  static const Color rose = Color(0xFF853953);
  static const Color lightBg = Color(0xFFF3F4F4);

  // Semantic
  static const Color positive = Color(0xFF27AE60);
  static const Color negative = Color(0xFFEB5757);
  static const Color neutral = Color(0xFF8A8A8A);

  // Surface
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF383838);

  // Text
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnDark = Color(0xFFF3F4F4);
  static const Color textOnDarkMuted = Color(0xFFB0B0B0);

  // Border / Divider
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF444444);

  // Chart palette
  static const List<Color> chartPalette = [
    Color(0xFF612D53),
    Color(0xFF853953),
    Color(0xFF4A9B8E),
    Color(0xFFE8A838),
    Color(0xFF5B8CDE),
    Color(0xFFB15CCB),
  ];
}
