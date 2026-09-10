import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/infrastructure/services/foreground_task_platform.dart';

class _MockPlatform extends Mock implements ForegroundTaskPlatform {}

void main() {
  late ForegroundTaskPlatform platform;

  setUp(() {
    platform = _MockPlatform();
  });

  group('ForegroundTaskPlatform contract', () {
    test('mock is a subtype of ForegroundTaskPlatform', () {
      expect(platform, isA<ForegroundTaskPlatform>());
    });

    test('init returns Future<void>', () async {
      when(() => platform.init()).thenAnswer((_) async {});

      await platform.init();

      verify(() => platform.init()).called(1);
    });

    test('isRunningService returns Future<bool>', () async {
      when(() => platform.isRunningService()).thenAnswer((_) async => true);

      final result = await platform.isRunningService();

      expect(result, true);
    });

    test('isRunningService returns false when not running', () async {
      when(() => platform.isRunningService()).thenAnswer((_) async => false);

      final result = await platform.isRunningService();

      expect(result, false);
    });

    test('startService accepts callback', () async {
      void callback() {}
      when(() => platform.startService(callback: any(named: 'callback')))
          .thenAnswer((_) async {});

      await platform.startService(callback: callback);

      verify(() => platform.startService(callback: callback)).called(1);
    });

    test('stopService returns Future<void>', () async {
      when(() => platform.stopService()).thenAnswer((_) async {});

      await platform.stopService();

      verify(() => platform.stopService()).called(1);
    });
  });
}
