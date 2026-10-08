import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/features/onboarding/presentation/widgets/steps/biometric_step.dart';
import 'package:pulse_track/features/onboarding/presentation/widgets/steps/completion_step.dart';
import 'package:pulse_track/features/onboarding/presentation/widgets/steps/permissions_step.dart';
import 'package:pulse_track/features/onboarding/presentation/widgets/steps/welcome_step.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';

/// Onboarding wizard with welcome, permissions, biometric and completion steps.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _kPageTransition = Duration(milliseconds: 300);

  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < 3) {
      _controller.nextPage(duration: _kPageTransition, curve: Curves.easeInOut);
    } else {
      _complete();
    }
  }

  void _back() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: _kPageTransition,
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
                  WelcomeStep(onNext: _next),
                  PermissionsStep(onNext: _next, onBack: _back),
                  BiometricStep(onNext: _next, onBack: _back),
                  CompletionStep(onComplete: _complete, onBack: _back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
