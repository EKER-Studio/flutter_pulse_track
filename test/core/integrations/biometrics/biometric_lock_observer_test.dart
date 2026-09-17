import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/integrations/biometrics/biometric_lock_observer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late bool lockEnabled;
  late bool? appLocked;
  late List<bool> lockChanges;
  late int verifyCalls;
  late bool verifyReopened;
  late Object? verifyError;
  late int reopenedCalls;
  late BiometricLockObserver observer;

  setUp(() {
    lockEnabled = false;
    appLocked = null;
    lockChanges = [];
    verifyCalls = 0;
    verifyReopened = false;
    verifyError = null;
    reopenedCalls = 0;
    observer = BiometricLockObserver(
      isBiometricLockEnabled: () => lockEnabled,
      onLockStateChanged: lockChanges.add,
      localizedReason: () => 'reason',
      isAppLocked: () => appLocked ?? false,
      onDatabaseReopened: () async {
        reopenedCalls++;
      },
      verifyDatabaseIntegrity: () async {
        verifyCalls++;
        if (verifyError != null) throw verifyError!;
        return (reopened: verifyReopened);
      },
    );
  });

  tearDown(() {
    observer.dispose();
  });

  group('resumed', () {
    test('verifies database integrity', () async {
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(verifyCalls, 1);
    });

    test('notifies reopened callback when database was reopened', () async {
      verifyReopened = true;

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(reopenedCalls, 1);
    });

    test('skips reopened callback when database was not reopened', () async {
      verifyReopened = false;

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(reopenedCalls, 0);
    });

    test('swallows integrity check failure without throwing', () async {
      verifyError = Exception('db locked');

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(verifyCalls, 1);
      expect(reopenedCalls, 0);
    });

    test('resumed does not trigger lock callback', () async {
      lockEnabled = true;

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(lockChanges, isEmpty);
    });
  });

  group('background transitions lock the app', () {
    for (final state in [
      AppLifecycleState.paused,
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
    ]) {
      test('$state locks when lock is enabled', () {
        lockEnabled = true;

        observer.didChangeAppLifecycleState(state);

        expect(lockChanges, [true]);
      });
    }

    test('detached does not lock (engine teardown has no UI to shield; '
        'unlike scanner/monitor which must stop hardware)', () {
      lockEnabled = true;

      observer.didChangeAppLifecycleState(AppLifecycleState.detached);

      expect(lockChanges, isEmpty);
    });

    test('paused does not lock when lock is disabled', () {
      lockEnabled = false;

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(lockChanges, isEmpty);
    });

    test('paused does not lock when app is already locked', () {
      lockEnabled = true;
      appLocked = true;

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(lockChanges, isEmpty);
    });

    test('background transition does not verify database integrity', () {
      lockEnabled = true;

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(verifyCalls, 0);
    });
  });

  group('dispose', () {
    test('is idempotent', () {
      observer.dispose();

      expect(() => observer.dispose(), returnsNormally);
    });

    test('ignores lifecycle events after dispose', () async {
      lockEnabled = true;
      observer.dispose();

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(lockChanges, isEmpty);
      expect(verifyCalls, 0);
    });

    test('removeThisObserver disposes the observer', () {
      lockEnabled = true;
      observer.removeThisObserver();

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(lockChanges, isEmpty);
    });
  });
}
