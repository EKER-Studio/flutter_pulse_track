import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Single interactive row tile in the settings view.
class SettingsTile extends StatelessWidget {
  /// Leading icon.
  final IconData icon;

  /// Primary label text.
  final String title;

  /// Secondary description or current value text.
  final String? subtitle;

  /// Optional custom trailing widget. Defaults to a subtle chevron.
  final Widget? trailing;

  /// Optional icon color override.
  final Color? iconColor;

  /// Optional title color override.
  final Color? titleColor;

  /// Callback when user taps the tile.
  final VoidCallback? onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppColors.accentBlue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: AppColors.surfaceBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Semantics(
        label: subtitle != null ? '$title. $subtitle' : title,
        button: onTap != null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: effectiveColor, size: 20),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: titleColor),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                )
              : null,
          trailing:
              trailing ??
              (onTap != null
                  ? const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    )
                  : null),
          onTap: onTap,
        ),
      ),
    );
  }
}
