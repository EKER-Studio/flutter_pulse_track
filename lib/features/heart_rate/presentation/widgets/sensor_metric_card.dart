import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Reusable telemetry card displaying a sensor metric (e.g. location, battery level).
class SensorMetricCard extends StatelessWidget {
  /// Accessible semantic label for assistive tech.
  final String semanticsLabel;

  /// Leading icon.
  final IconData icon;

  /// Icon color override.
  final Color iconColor;

  /// Small title/category label above the metric value.
  final String title;

  /// Primary metric value text.
  final String value;

  const SensorMetricCard({
    super.key,
    required this.semanticsLabel,
    required this.icon,
    this.iconColor = AppColors.accentBlue,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ExcludeSemantics(child: Icon(icon, color: iconColor)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
