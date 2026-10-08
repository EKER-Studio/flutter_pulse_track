import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/presentation/widgets/status_state_view.dart';

void main() {
  group('StatusStateView', () {
    testWidgets('renders icon, title, and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusStateView(
              icon: Icons.bluetooth_disabled_rounded,
              title: 'No Bluetooth',
              subtitle: 'Turn on Bluetooth in device settings.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.bluetooth_disabled_rounded), findsOneWidget);
      expect(find.text('No Bluetooth'), findsOneWidget);
      expect(
        find.text('Turn on Bluetooth in device settings.'),
        findsOneWidget,
      );
    });

    testWidgets('renders action button when provided', (
      WidgetTester tester,
    ) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusStateView(
              icon: Icons.refresh_rounded,
              title: 'Error',
              action: ElevatedButton(
                onPressed: () => actionTriggered = true,
                child: const Text('Retry'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(actionTriggered, isTrue);
    });
  });
}
