import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart';
import 'package:pulse_track/core/infrastructure/services/foreground_task_platform.dart';

// ── Fake platform ─────────────────────────────────────────────────────────

class _FakeForegroundTaskPlatform implements ForegroundTaskPlatform {
  bool initialized = false;
  bool running = false;
  bool initCalled = false;
  bool stopCalled = false;
  void Function()? capturedCallback;

  @override
  Future<void> init() async {
    initCalled = true;
    initialized = true;
  }

  @override
  Future<bool> isRunningService() async => running;

  @override
  Future<void> startService({required void Function() callback}) async {
    capturedCallback = callback;
    running = true;
  }

  @override
  Future<void> stopService() async {
    stopCalled = true;
    running = false;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  late _FakeForegroundTaskPlatform platform;
  late ForegroundServiceManager manager;

  setUp(() {
    platform = _FakeForegroundTaskPlatform();
    manager = ForegroundServiceManager(platform: platform);
  });

  group('init', () {
    test('calls platform.init()', () async {
      await manager.init();

      expect(platform.initCalled, true);
    });

    test('is idempotent — does not call platform.init() twice', () async {
      await manager.init();
      platform.initCalled = false;
      await manager.init();

      expect(platform.initCalled, false);
    });
  });

  group('startService', () {
    test('calls init() when not initialized', () async {
      await manager.startService();

      expect(platform.initCalled, true);
    });

    test('starts service when not running', () async {
      await manager.startService();

      expect(platform.running, true);
    });

    test('does not start service when already running', () async {
      platform.running = true;
      await manager.startService();

      expect(platform.capturedCallback, isNull);
    });

    test('passes startCallback as the callback', () async {
      await manager.startService();

      expect(platform.capturedCallback, same(startCallback));
    });
  });

  group('stopService', () {
    test('stops service when running', () async {
      platform.running = true;
      await manager.stopService();

      expect(platform.stopCalled, true);
      expect(platform.running, false);
    });

    test('does not stop service when not running', () async {
      await manager.stopService();

      expect(platform.stopCalled, false);
    });
  });

  group('constructor default', () {
    test('uses FlutterForegroundTaskPlatform when platform is omitted', () {
      final defaultManager = ForegroundServiceManager();
      expect(defaultManager, isNotNull);
    });
  });

  group('MyTaskHandler', () {
    test('onStart executes without error', () async {
      final handler = MyTaskHandler();
      await expectLater(
        handler.onStart(DateTime.now(), TaskStarter.developer),
        completes,
      );
    });

    test('onRepeatEvent executes without error', () {
      final handler = MyTaskHandler();
      expect(() => handler.onRepeatEvent(DateTime.now()), returnsNormally);
    });

    test('onDestroy executes without error', () async {
      final handler = MyTaskHandler();
      await expectLater(handler.onDestroy(DateTime.now(), false), completes);
      await expectLater(handler.onDestroy(DateTime.now(), true), completes);
    });
  });

  group('foregroundServiceManagerProvider', () {
    test(
      'delivers ForegroundServiceManager instance via ProviderContainer',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final manager = container.read(foregroundServiceManagerProvider);
        expect(manager, isA<ForegroundServiceManager>());
      },
    );
  });
}
