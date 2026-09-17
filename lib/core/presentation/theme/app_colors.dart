import 'package:flutter/material.dart';

/// Centralized color palette and visual design tokens for the application.
abstract final class AppColors {
  AppColors._();

  // Backgrounds
  /// Scaffold background color (dark surface).
  static const Color scaffoldBackground = Color(0xFF111318);

  /// Surface card background color (surfaceContainerLow).
  static const Color surfaceBackground = Color(0xFF191C20);

  /// Badge and chip background color (surfaceContainerHigh).
  static const Color badgeBackground = Color(0xFF282A2F);

  /// Darker background variant for contrast (surfaceContainerLowest).
  static const Color darkerBackground = Color(0xFF0C0E13);

  // Accents
  /// Primary accent blue (Material 3 Dark Primary).
  static const Color accentBlue = Color(0xFFADC6FF);

  /// Primary accent red (Material 3 Dark Error).
  static const Color accentRed = Color(0xFFFFB4AB);

  /// Primary accent green (Feedback Success Dark).
  static const Color accentGreen = Color(0xFF7CE38B);

  /// Primary accent orange (Feedback Warning Dark).
  static const Color accentOrange = Color(0xFFFFD56B);

  // Text
  /// Primary text color (onSurface).
  static const Color textPrimary = Color(0xFFE2E2E9);

  /// Secondary text color (onSurfaceVariant).
  static const Color textSecondary = Color(0xFFC4C6D0);

  /// Tertiary muted text color (outline).
  static const Color textTertiary = Color(0xFF8E9099);

  /// Muted text color for disabled states (outline).
  static const Color textMuted = Color(0xFF8E9099);

  // Feedback
  /// Error feedback red (error).
  static const Color errorRed = Color(0xFFFFB4AB);

  /// Success feedback green (feedback success).
  static const Color successGreen = Color(0xFF7CE38B);

  // Borders
  /// Subtle border color (outlineVariant with alpha).
  static const Color borderSubtle = Color(0x33C4C6D0);

  // Chart
  static const Color chartGridLine = Color(0x29C4C6D0);

  /// Gradient start for chart fill.
  static Color get chartFillStart => accentBlue.withValues(alpha: 0.28);

  /// Gradient end for chart fill.
  static Color get chartFillEnd => accentBlue.withValues(alpha: 0.0);

  // Stat icons
  static const Color statIconAvg = Color(0xFFFFB4AB);

  static const Color statIconPeak = Color(0xFFFFD56B);

  static const Color statIconDuration = Color(0xFF7CE38B);

  static const Color statIconSamples = Color(0xFFADC6FF);

  // HR zone palette
  static const Color hrZone1 = Color(0xFF4D96FF);

  static const Color hrZone2 = Color(0xFF6BCB77);

  static const Color hrZone3 = Color(0xFFFFD93D);

  static const Color hrZone4 = Color(0xFFFF9F45);

  static const Color hrZone5 = Color(0xFFFF6B6B);
}
