import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/presentation/widgets/failure_card.dart';

void main() {
  group('FailureCard', () {
    testWidgets('renders title, message, and action widgets', (
      WidgetTester tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FailureCard(
              title: 'Connection Error',
              message: 'Connection failed',
              actions: [
                ElevatedButton(
                  onPressed: () => retried = true,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Connection Error'), findsOneWidget);
      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('renders without actions when none provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FailureCard(
              title: 'Disconnected',
              message: 'Sensor disconnected',
            ),
          ),
        ),
      );

      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.text('Sensor disconnected'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
