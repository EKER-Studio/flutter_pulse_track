import 'package:flutter/material.dart';

/// Centralized color palette and visual design tokens for the application.
abstract final class AppColors {
  AppColors._();

  // Backgrounds
  /// Scaffold background color.
  static const Color scaffoldBackground = Color(0xFF121212);

  /// Surface card background color.
  static const Color surfaceBackground = Color(0xFF1E1E1E);

  /// Badge and chip background color.
  static const Color badgeBackground = Color(0xFF2A2A2A);

  /// Darker background variant for contrast.
  static const Color darkerBackground = Color(0xFF0D0D0D);

  // Accents
  /// Primary accent blue.
  static const Color accentBlue = Colors.blueAccent;

  /// Primary accent red.
  static const Color accentRed = Colors.redAccent;

  /// Primary accent green.
  static const Color accentGreen = Colors.greenAccent;

  /// Primary accent orange.
  static const Color accentOrange = Colors.orangeAccent;

  // Text
  /// Primary text color.
  static const Color textPrimary = Colors.white;

  /// Secondary text color.
  static const Color textSecondary = Colors.grey;

  /// Tertiary muted text color.
  static const Color textTertiary = Color(0xFF757575);

  /// Muted text color for disabled states.
  static const Color textMuted = Color(0xFFBDBDBD);

  // Feedback
  /// Error feedback red.
  static const Color errorRed = Colors.red;

  /// Success feedback green.
  static const Color successGreen = Colors.green;

  // Borders
  /// Subtle border color.
  static const Color borderSubtle = Colors.white10;

  // Chart
  /// Chart grid line color.
  static const Color chartGridLine = Colors.white12;

  /// Gradient start for chart fill.
  static Color get chartFillStart => Colors.white.withValues(alpha: 0.05);

  /// Gradient end for chart fill.
  static Color get chartFillEnd => Colors.white.withValues(alpha: 0.0);

  // Stat icons
  /// Average BPM stat icon color.
  static const Color statIconAvg = Color(0xFFFF6B6B);

  /// Peak BPM stat icon color.
  static const Color statIconPeak = Color(0xFFFFD93D);

  /// Duration stat icon color.
  static const Color statIconDuration = Color(0xFF6BCB77);

  /// Samples stat icon color.
  static const Color statIconSamples = Color(0xFF4D96FF);

  // HR zone palette
  /// Heart rate zone 1 color.
  static const Color hrZone1 = Color(0xFF4D96FF);

  /// Heart rate zone 2 color.
  static const Color hrZone2 = Color(0xFF6BCB77);

  /// Heart rate zone 3 color.
  static const Color hrZone3 = Color(0xFFFFD93D);

  /// Heart rate zone 4 color.
  static const Color hrZone4 = Color(0xFFFF9F45);

  /// Heart rate zone 5 color.
  static const Color hrZone5 = Color(0xFFFF6B6B);
}
