import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pulse_track/features/onboarding/presentation/widgets/steps/welcome_step.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  testWidgets('OnboardingScreen renders first step (WelcomeStep)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: OnboardingScreen(),
        ),
      ),
    );

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(WelcomeStep), findsOneWidget);
  });
}
