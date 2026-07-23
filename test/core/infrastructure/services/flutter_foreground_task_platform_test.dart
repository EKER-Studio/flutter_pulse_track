import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/infrastructure/services/flutter_foreground_task_platform.dart';
import 'package:pulse_track/core/infrastructure/services/foreground_task_platform.dart';

void main() {
  group('FlutterForegroundTaskPlatform', () {
    test('implements ForegroundTaskPlatform', () {
      final platform = FlutterForegroundTaskPlatform();
      expect(platform, isA<ForegroundTaskPlatform>());
    });

    test('can be constructed without throwing', () {
      expect(() => FlutterForegroundTaskPlatform(), returnsNormally);
    });
  });
}