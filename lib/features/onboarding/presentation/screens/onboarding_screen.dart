import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../settings/presentation/controllers/app_settings_notifier.dart';
import '../../../../core/integrations/biometrics/biometric_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/onboarding_step_layout.dart';

/// Onboarding wizard with welcome, permissions, biometric and completion steps.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates an [OnboardingScreen].
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _back() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _complete() async {
    await ref.read(appSettingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / 4,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  _WelcomeStep(onNext: _next),
                  _PermissionsStep(onNext: _next, onBack: _back),
                  _BiometricStep(onNext: _next, onBack: _back),
                  _CompletionStep(onComplete: _complete, onBack: _back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.onboardingWelcomeTitle,
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.onboardingWelcomeSubtitle,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      content: Column(
        children: [
          _FeatureCard(
            icon: Icons.monitor_heart_outlined,
            title: l10n.onboardingWelcomeHealthSync,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.history_outlined,
            title: l10n.onboardingWelcomeHistory,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.lock_outline,
            title: l10n.onboardingWelcomePrivacy,
          ),
        ],
      ),
      footer: FilledButton(
        onPressed: onNext,
        child: Text(l10n.onboardingWelcomeStart),
      ),
    );
  }
}

class _PermissionsStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _PermissionsStep({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.onboardingPermissionsTitle,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.onboardingPermissionsSubtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        children: [
          _PermissionTile(
            icon: Icons.bluetooth,
            title: l10n.permissionBluetoothTitle,
            subtitle: l10n.permissionBluetoothSubtitle,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.notifications_outlined,
            title: l10n.permissionNotificationsTitle,
            subtitle: l10n.permissionNotificationsSubtitle,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.favorite_outline,
            title: l10n.permissionHealthTitle,
            subtitle: l10n.permissionHealthSubtitle,
          ),
        ],
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

class _BiometricStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _BiometricStep({required this.onNext, required this.onBack});

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
            final result = await BiometricService.instance.authenticate(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.biometricAuthFailed)),
              );
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

class _CompletionStep extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;
  const _CompletionStep({required this.onComplete, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.onboardingCompleteTitle,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.onboardingCompleteSubtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      content: Icon(
        Icons.check_circle_outline,
        size: 96,
        color: Theme.of(context).colorScheme.primary,
      ),
      footer: Row(
        children: [
          TextButton(onPressed: onBack, child: Text(l10n.back)),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onComplete,
              child: Text(l10n.getStarted),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FeatureCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
