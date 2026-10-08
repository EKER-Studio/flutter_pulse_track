import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/navigation/presentation/widgets/components/adaptive_bottom_navigation_bar.dart';
import 'package:pulse_track/features/navigation/presentation/widgets/components/adaptive_navigation_rail.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  Widget buildBottomBar(int selectedIndex, ValueChanged<int> onSelected) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
        ),
      ),
    );
  }

  Widget buildNavRail(int selectedIndex, ValueChanged<int> onSelected) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: AdaptiveNavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
        ),
      ),
    );
  }

  group('AdaptiveBottomNavigationBar', () {
    testWidgets('renders all 4 tabs and invokes callback on tap', (
      tester,
    ) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildBottomBar(0, (index) => tappedIndex = index),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Calendar'));
      await tester.pump();

      expect(tappedIndex, 1);

      await tester.tap(find.text('Statistics'));
      await tester.pump();

      expect(tappedIndex, 2);
    });
  });

  group('AdaptiveNavigationRail', () {
    testWidgets('renders all 4 destinations in landscape rail', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(buildNavRail(1, (index) => tappedIndex = index));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tappedIndex, 3);
    });
  });
}
