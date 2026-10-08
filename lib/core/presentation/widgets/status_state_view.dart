import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Reusable full-page or centered state placeholder for empty, idle, disconnected, or error states.
///
/// Standardizes the common pattern:
/// `Center -> Column -> Icon -> Title -> Subtitle -> ActionButton`
/// found across multiple views in the application.
class StatusStateView extends StatelessWidget {
  /// Icon displayed prominently at the center-top.
  final IconData icon;

  /// Size of the icon. Defaults to 80.
  final double iconSize;

  /// Color of the icon. Defaults to [AppColors.textSecondary].
  final Color iconColor;

  /// Semantic label for the icon (if non-null, creates an accessible description).
  final String? iconSemanticLabel;

  /// Primary state title.
  final String title;

  /// Text style for [title]. Defaults to 20-24pt bold.
  final TextStyle? titleStyle;

  /// Secondary descriptive text or instructions.
  final String? subtitle;

  /// Text alignment for [subtitle]. Defaults to [TextAlign.center].
  final TextAlign subtitleTextAlign;

  /// Custom widget replacing or supplementing [subtitle].
  final Widget? customContent;

  /// Optional action widget rendered at the bottom (e.g. primary CTA button).
  final Widget? action;

  /// Content padding. Defaults to `EdgeInsets.all(32)`.
  final EdgeInsetsGeometry padding;

  /// Whether the view should be scrollable to prevent overflow on small viewports.
  final bool scrollable;

  const StatusStateView({
    super.key,
    required this.icon,
    this.iconSize = 80.0,
    this.iconColor = AppColors.textSecondary,
    this.iconSemanticLabel,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleTextAlign = TextAlign.center,
    this.customContent,
    this.action,
    this.padding = const EdgeInsets.all(32.0),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTitleStyle =
        titleStyle ??
        const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        );

    final content = Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconSemanticLabel != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
                semanticLabel: iconSemanticLabel,
              )
            else
              ExcludeSemantics(
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: effectiveTitleStyle,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                textAlign: subtitleTextAlign,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],
            if (action != null) ...[const SizedBox(height: 32), action!],
          ],
        ),
      ),
    );

    if (scrollable) {
      return SingleChildScrollView(child: content);
    }
    return content;
  }
}
