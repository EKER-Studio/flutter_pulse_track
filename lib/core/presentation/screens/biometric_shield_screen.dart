import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../application/service_providers.dart';
import '../../utils/crash_reporter.dart';
import '../../../features/settings/presentation/controllers/app_settings_notifier.dart';

/// The biometric lock overlay and its authentication flow.
class BiometricShieldScreen extends ConsumerStatefulWidget {
  const BiometricShieldScreen({super.key});

  @override
  ConsumerState<BiometricShieldScreen> createState() =>
      _BiometricShieldScreenState();
}

class _BiometricShieldScreenState extends ConsumerState<BiometricShieldScreen> {
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleUnlock(context);
      }
    });
  }

  Future<void> _handleUnlock(BuildContext context) async {
    if (_isUnlocking) return;
    setState(() {
      _isUnlocking = true;
    });
    final l10n = AppLocalizations.of(context);

    try {
      final settings = ref.read(appSettingsProvider);
      if (!settings.isLocked) {
        ref.read(appSettingsProvider.notifier).setLocked(true);
      }
      final biometricService = ref.read(biometricServiceProvider);
      final result = await biometricService.authenticate(
        localizedReason: l10n.biometricAuthReason,
        authMessages: BiometricService.createAuthMessages(l10n),
      );
      if (result == BiometricAuthResult.success) {
        ref.read(appSettingsProvider.notifier).setLocked(false);
      } else if (BiometricService.isTerminalFailure(result) ||
          result == BiometricAuthResult.notAvailable) {
        if (!context.mounted) return;
        await _offerLockRecovery(context, l10n);
      } else {
        if (!ref.read(appSettingsProvider).isLocked) {
          ref.read(appSettingsProvider.notifier).setLocked(true);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.biometricAuthFailed)));
        }
      }
    } on Object catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Authentication threw in BiometricShieldScreen',
      );
      if (!ref.read(appSettingsProvider).isLocked) {
        ref.read(appSettingsProvider.notifier).setLocked(true);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).biometricAuthFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  Future<void> _offerLockRecovery(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    if (!context.mounted) return;
    final disable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(l10n.biometricLockoutTitle),
        content: SizedBox(width: 320, child: Text(l10n.biometricLockoutBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.keepLocked),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.disableLock),
          ),
        ],
      ),
    );
    if (disable == true) {
      await ref.read(appSettingsProvider.notifier).updateBiometricLock(false);
      ref.read(appSettingsProvider.notifier).setLocked(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: l10n.appLockedStatusIconSemantics,
                  image: true,
                  child: Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.appLocked,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.biometricAuthReason,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  button: true,
                  enabled: !_isUnlocking,
                  label: l10n.unlock,
                  hint: l10n.biometricAuthReason,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _isUnlocking
                        ? null
                        : () => _handleUnlock(context),
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.unlock),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
