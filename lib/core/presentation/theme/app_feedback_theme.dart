import 'package:flutter/material.dart';

/// Centralized semantic color tokens for feedback UI (snackbars, banners, and alerts).
abstract final class AppFeedbackTheme {
  /// Light background color for success states.
  static const Color successBackgroundLight = Color(0xFFE7F8ED);

  /// Dark background color for success states.
  static const Color successBackgroundDark = Color(0xFF14291E);

  /// Light foreground color for success states.
  static const Color successForegroundLight = Color(0xFF156F35);

  /// Dark foreground color for success states.
  static const Color successForegroundDark = Color(0xFF7CE38B);

  /// Light background color for error states.
  static const Color errorBackgroundLight = Color(0xFFFCE8E6);

  /// Dark background color for error states.
  static const Color errorBackgroundDark = Color(0xFF2E1517);

  /// Light foreground color for error states.
  static const Color errorForegroundLight = Color(0xFFB3261E);

  /// Dark foreground color for error states.
  static const Color errorForegroundDark = Color(0xFFF2B8B5);

  /// Light background color for warning states.
  static const Color warningBackgroundLight = Color(0xFFFEF7E0);

  /// Dark background color for warning states.
  static const Color warningBackgroundDark = Color(0xFF2A200B);

  /// Light foreground color for warning states.
  static const Color warningForegroundLight = Color(0xFF7D5700);

  /// Dark foreground color for warning states.
  static const Color warningForegroundDark = Color(0xFFFFD56B);

  /// Light background color for info states.
  static const Color infoBackgroundLight = Color(0xFFE8F0FE);

  /// Dark background color for info states.
  static const Color infoBackgroundDark = Color(0xFF121C2B);

  /// Light foreground color for info states.
  static const Color infoForegroundLight = Color(0xFF0A56D1);

  /// Dark foreground color for info states.
  static const Color infoForegroundDark = Color(0xFFA8C7FA);
}
