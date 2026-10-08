import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/core/application/service_providers.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Settings section for biometric authentication and security lock.
class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.biometricLock),
        SettingsTile(
          icon: Icons.lock_outline_rounded,
          title: l10n.biometricLock,
          subtitle: l10n.biometricDesc,
          trailing: Switch(
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
                  ref.read(appSettingsProvider.notifier).setLocked(true);
                } else if (BiometricService.isTerminalFailure(result) ||
                    result == BiometricAuthResult.notAvailable) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.biometricsNotAvailable)),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.biometricAuthFailed)),
                    );
                  }
                }
              } else {
                await ref
                    .read(appSettingsProvider.notifier)
                    .updateBiometricLock(false);
                ref.read(appSettingsProvider.notifier).setLocked(false);
              }
            },
          ),
        ),
      ],
    );
  }
}
