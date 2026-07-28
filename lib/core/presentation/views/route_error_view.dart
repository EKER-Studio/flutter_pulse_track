import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Fallback error screen displayed when a deep link or route fails to match.
///
/// Indicates the requested location is invalid and offers a direct action to
/// return to the main dashboard.
class RouteErrorView extends StatelessWidget {
  /// Creates a [RouteErrorView].
  ///
  /// Takes an optional [error] exception details instance.
  const RouteErrorView({super.key, this.error});

  /// Optional error or exception details triggering this fallback view.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Błąd Nawigacji'),
        backgroundColor: AppColors.surfaceBackground,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nie znaleziono żądanej strony',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ??
                    'Nieprawidłowy adres lub uszkodzony link głęboki.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Powrót do strony głównej'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
