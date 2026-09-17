import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/clamped_layout.dart';

/// Consistent layout for onboarding steps with title, subtitle, content and footer.
class OnboardingStepLayout extends StatelessWidget {
  /// Title widget.
  final Widget titleWidget;

  /// Subtitle widget.
  final Widget? subtitleWidget;

  /// Main content.
  final Widget content;

  /// Footer with actions.
  final Widget footer;

  const OnboardingStepLayout({
    super.key,
    required this.titleWidget,
    this.subtitleWidget,
    required this.content,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return ClampedLayout(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          titleWidget,
          if (subtitleWidget != null) ...[
            const SizedBox(height: 12),
            subtitleWidget!,
          ],
          const SizedBox(height: 32),
          Expanded(child: SingleChildScrollView(child: content)),
          const SizedBox(height: 24),
          SafeArea(child: footer),
        ],
      ),
    );
  }
}
