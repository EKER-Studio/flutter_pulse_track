import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFF121212);
  static const Color surfaceBackground = Color(0xFF1E1E1E);
  static const Color badgeBackground = Color(0xFF2A2A2A);
  static const Color darkerBackground = Color(0xFF0D0D0D);

  // Accents
  static const Color accentBlue = Colors.blueAccent;
  static const Color accentRed = Colors.redAccent;
  static const Color accentGreen = Colors.greenAccent;
  static const Color accentOrange = Colors.orangeAccent;

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color textTertiary = Color(0xFF757575);
  static const Color textMuted = Color(0xFFBDBDBD);

  // Feedback
  static const Color errorRed = Colors.red;
  static const Color successGreen = Colors.green;

  // Borders
  static const Color borderSubtle = Colors.white10;

  // Chart
  static const Color chartGridLine = Colors.white12;
  static Color get chartFillStart => Colors.white.withValues(alpha: 0.05);
  static Color get chartFillEnd => Colors.white.withValues(alpha: 0.0);

  // Stat icons
  static const Color statIconAvg = Color(0xFFFF6B6B);
  static const Color statIconPeak = Color(0xFFFFD93D);
  static const Color statIconDuration = Color(0xFF6BCB77);
  static const Color statIconSamples = Color(0xFF4D96FF);

  // HR zone palette
  static const Color hrZone1 = Color(0xFF4D96FF);
  static const Color hrZone2 = Color(0xFF6BCB77);
  static const Color hrZone3 = Color(0xFFFFD93D);
  static const Color hrZone4 = Color(0xFFFF9F45);
  static const Color hrZone5 = Color(0xFFFF6B6B);
}
