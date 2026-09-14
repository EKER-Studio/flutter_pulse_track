import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Section header label displayed above grouped settings tiles.
class SettingsSectionHeader extends StatelessWidget {
  /// Header title text.
  final String title;

  /// Creates a [SettingsSectionHeader] with [title].
  const SettingsSectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
