import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Reusable error/failure card with icon, title, message, and an optional retry action.
///
/// Used across multiple views (scanner failure, monitor failure, etc.) to
/// display a consistent error state with a prominent border accent.
class FailureCard extends StatelessWidget {
  /// Icon displayed at the top of the card.
  final IconData icon;

  /// Accent color for the icon and the card border tint.
  final Color accentColor;

  /// Primary failure title text.
  final String title;

  /// Detailed failure message or error description.
  final String message;

  /// Optional list of action widgets rendered below the message.
  ///
  /// Typically contains retry buttons or navigation actions.
  final List<Widget> actions;

  const FailureCard({
    super.key,
    this.icon = Icons.error_outline,
    this.accentColor = AppColors.accentRed,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: Icon(icon, size: 48, color: accentColor)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
