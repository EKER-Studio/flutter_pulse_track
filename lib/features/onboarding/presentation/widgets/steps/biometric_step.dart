import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/core/application/service_providers.dart';
import 'package:pulse_track/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Third onboarding step offering optional biometric authentication lock.
class BiometricStep extends ConsumerWidget {
  /// Callback to advance to the next step.
  final VoidCallback onNext;

  /// Callback to return to the previous step.
  final VoidCallback onBack;

  const BiometricStep({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);

    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.biometricStepTitle,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.biometricStepSubtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      content: SwitchListTile(
        title: Text(l10n.biometricLock),
        subtitle: Text(l10n.biometricDesc),
        value: settings.isBiometricLockEnabled,
        onChanged: (enabled) async {
          if (enabled) {
            final biometricService = ref.read(biometricServiceProvider);
            final result = await biometricService.authenticate(
              localizedReason: l10n.biometricAuthReason,
              authMessages: BiometricService.createAuthMessages(l10n),
            );
            if (result == BiometricAuthResult.success) {
              await ref
                  .read(appSettingsProvider.notifier)
                  .updateBiometricLock(true);
            } else if (context.mounted &&
                (BiometricService.isTerminalFailure(result) ||
                    result == BiometricAuthResult.notAvailable)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.biometricsNotAvailable)),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.biometricAuthFailed)));
            }
          } else {
            await ref
                .read(appSettingsProvider.notifier)
                .updateBiometricLock(false);
          }
        },
      ),
      footer: Row(
        children: [
          TextButton(onPressed: onBack, child: Text(l10n.back)),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(onPressed: onNext, child: Text(l10n.next)),
          ),
        ],
      ),
    );
  }
}
