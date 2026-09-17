import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/integrations/notifications/notification_service.dart';

const MethodChannel _timezoneChannel = MethodChannel('flutter_timezone');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Route the plugin down its macOS no-op path: the Android
    // platform-interface singleton is never registered in unit tests,
    // so resolving it would throw LateInitializationError.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_timezoneChannel, (call) async {
          if (call.method == 'getLocalTimezone') return 'UTC';
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_timezoneChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('NotificationService', () {
    test('setLocalizedTexts completes without throwing before init', () {
      expect(
        () => NotificationService.instance.setLocalizedTexts(
          title: 'T',
          body: 'B',
          channelName: 'C',
          channelDescription: 'D',
        ),
        returnsNormally,
      );
    });

    test('initialize completes without throwing', () async {
      await expectLater(NotificationService.instance.initialize(), completes);
    });

    test('initialize is idempotent', () async {
      await NotificationService.instance.initialize();

      await expectLater(NotificationService.instance.initialize(), completes);
    });

    test('scheduleDailyReminder completes without throwing', () async {
      await NotificationService.instance.initialize();

      await expectLater(
        NotificationService.instance.scheduleDailyReminder(hour: 9, minute: 30),
        completes,
      );
    });

    test('cancelDailyReminder completes without throwing', () async {
      await NotificationService.instance.initialize();

      await expectLater(
        NotificationService.instance.cancelDailyReminder(),
        completes,
      );
    });
  });
}
