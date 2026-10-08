import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/widgets/status_state_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Fallback error screen displayed when a deep link or route fails to match.
///
/// Indicates the requested location is invalid and offers a direct action to
/// return to the main dashboard.
class RouteErrorView extends StatelessWidget {
  const RouteErrorView({super.key, this.error});

  /// Optional error or exception details triggering this fallback view.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(l10n.routeErrorTitle)),
      body: StatusStateView(
        icon: Icons.error_outline_rounded,
        iconSize: 64,
        iconColor: AppColors.errorRed,
        title: l10n.routeErrorNotFound,
        titleStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        subtitle: error?.toString() ?? l10n.routeErrorInvalidLink,
        padding: const EdgeInsets.all(24.0),
        action: ElevatedButton.icon(
          onPressed: () => context.go('/'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.home_rounded),
          label: Text(l10n.routeErrorBackHome),
        ),
      ),
    );
  }
}
