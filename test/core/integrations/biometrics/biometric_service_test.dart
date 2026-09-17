import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pulse_track/core/integrations/biometrics/biometric_service.dart';
import 'package:pulse_track/l10n/app_localizations_en.dart';

class _MockLocalAuthPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements LocalAuthPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockLocalAuthPlatform platform;

  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
    registerFallbackValue(const <AuthMessages>[]);
  });

  setUp(() {
    platform = _MockLocalAuthPlatform();
    LocalAuthPlatform.instance = platform;
    BiometricService.resetForTesting();

    when(() => platform.isDeviceSupported()).thenAnswer((_) async => true);
    when(() => platform.deviceSupportsBiometrics())
        .thenAnswer((_) async => true);
    when(() => platform.getEnrolledBiometrics())
        .thenAnswer((_) async => [BiometricType.fingerprint]);
  });

  Future<BiometricAuthResult> authenticate() {
    return BiometricService.instance.authenticate(localizedReason: 'reason');
  }

  void stubPlatformAuthenticate(FutureOr<bool> Function() answer) {
    when(
      () => platform.authenticate(
        localizedReason: any(named: 'localizedReason'),
        authMessages: any(named: 'authMessages'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) => Future.value(answer()));
  }

  group('isAvailable', () {
    test('returns true when biometrics are enrolled', () async {
      expect(await BiometricService.instance.isAvailable(), isTrue);
    });

    test('returns false when checking is unsupported', () async {
      when(() => platform.deviceSupportsBiometrics())
          .thenAnswer((_) async => false);

      expect(await BiometricService.instance.isAvailable(), isFalse);
    });

    test('returns false when nothing is enrolled', () async {
      when(() => platform.getEnrolledBiometrics()).thenAnswer((_) async => []);

      expect(await BiometricService.instance.isAvailable(), isFalse);
    });

    test('returns false when the plugin throws', () async {
      when(() => platform.deviceSupportsBiometrics())
          .thenThrow(Exception('channel error'));

      expect(await BiometricService.instance.isAvailable(), isFalse);
    });
  });

  group('isSupported', () {
    test('returns true when device is supported and checkable', () async {
      expect(await BiometricService.instance.isSupported(), isTrue);
    });

    test('returns false when the device is unsupported', () async {
      when(() => platform.isDeviceSupported()).thenAnswer((_) async => false);

      expect(await BiometricService.instance.isSupported(), isFalse);
    });

    test('returns false when the plugin throws', () async {
      when(() => platform.isDeviceSupported())
          .thenThrow(Exception('channel error'));

      expect(await BiometricService.instance.isSupported(), isFalse);
    });
  });

  group('canAuthenticate', () {
    test('returns true when either check passes', () async {
      when(() => platform.isDeviceSupported()).thenAnswer((_) async => false);

      expect(await BiometricService.instance.canAuthenticate(), isTrue);
    });

    test('returns false when neither check passes', () async {
      when(() => platform.isDeviceSupported()).thenAnswer((_) async => false);
      when(() => platform.deviceSupportsBiometrics())
          .thenAnswer((_) async => false);

      expect(await BiometricService.instance.canAuthenticate(), isFalse);
    });

    test('returns false when the plugin throws', () async {
      when(() => platform.isDeviceSupported())
          .thenThrow(Exception('channel error'));

      expect(await BiometricService.instance.canAuthenticate(), isFalse);
    });
  });

  group('authenticate', () {
    test('returns success and emits on the success stream', () async {
      stubPlatformAuthenticate(() => true);

      final events = <void>[];
      final sub = BiometricService.instance.authenticationSuccesses.listen(
        events.add,
      );

      final result = await authenticate();

      expect(result, BiometricAuthResult.success);
      await pumpEventQueue();
      expect(events, hasLength(1));
      await sub.cancel();
    });

    test('returns canceled when the user rejects the prompt', () async {
      stubPlatformAuthenticate(() => false);

      expect(await authenticate(), BiometricAuthResult.canceled);
    });

    test(
      'returns notAvailable without prompting when nothing can authenticate',
      () async {
        when(() => platform.isDeviceSupported()).thenAnswer((_) async => false);
        when(() => platform.deviceSupportsBiometrics())
            .thenAnswer((_) async => false);

        expect(await authenticate(), BiometricAuthResult.notAvailable);
        verifyNever(
          () => platform.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          ),
        );
      },
    );

    test('concurrent calls share a single platform prompt', () async {
      final gate = Completer<bool>();
      stubPlatformAuthenticate(() => gate.future);

      final first = authenticate();
      final second = authenticate();
      expect(BiometricService.instance.isAuthenticating, isTrue);

      gate.complete(true);
      expect(await first, BiometricAuthResult.success);
      expect(await second, BiometricAuthResult.success);
      verify(
        () => platform.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          options: any(named: 'options'),
        ),
      ).called(1);
      expect(BiometricService.instance.isAuthenticating, isFalse);
    });

    test('returns MissingPlugin as notAvailable', () async {
      when(
        () => platform.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          options: any(named: 'options'),
        ),
      ).thenThrow(MissingPluginException('no plugin'));

      expect(await authenticate(), BiometricAuthResult.notAvailable);
    });

    test('returns error on unexpected exception', () async {
      when(
        () => platform.authenticate(
          localizedReason: any(named: 'localizedReason'),
          authMessages: any(named: 'authMessages'),
          options: any(named: 'options'),
        ),
      ).thenThrow(StateError('weird'));

      expect(await authenticate(), BiometricAuthResult.error);
    });
  });

  group('authenticate LocalAuthException mapping', () {
    const cases = <LocalAuthExceptionCode, BiometricAuthResult>{
      LocalAuthExceptionCode.userCanceled: BiometricAuthResult.canceled,
      LocalAuthExceptionCode.systemCanceled: BiometricAuthResult.canceled,
      LocalAuthExceptionCode.userRequestedFallback:
          BiometricAuthResult.canceled,
      LocalAuthExceptionCode.timeout: BiometricAuthResult.canceled,
      LocalAuthExceptionCode.temporaryLockout: BiometricAuthResult.lockedOut,
      LocalAuthExceptionCode.biometricLockout:
          BiometricAuthResult.permanentlyLockedOut,
      LocalAuthExceptionCode.noBiometricsEnrolled:
          BiometricAuthResult.notEnrolled,
      LocalAuthExceptionCode.noCredentialsSet:
          BiometricAuthResult.passcodeNotSet,
      LocalAuthExceptionCode.noBiometricHardware:
          BiometricAuthResult.notAvailable,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          BiometricAuthResult.notAvailable,
      LocalAuthExceptionCode.authInProgress: BiometricAuthResult.error,
      LocalAuthExceptionCode.uiUnavailable: BiometricAuthResult.error,
      LocalAuthExceptionCode.deviceError: BiometricAuthResult.error,
      LocalAuthExceptionCode.unknownError: BiometricAuthResult.error,
    };

    for (final entry in cases.entries) {
      test('${entry.key.name} -> ${entry.value.name}', () async {
        when(
          () => platform.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          ),
        ).thenThrow(LocalAuthException(code: entry.key));

        expect(await authenticate(), entry.value);
      });
    }
  });

  group('authenticate PlatformException mapping', () {
    const cases = <String, BiometricAuthResult>{
      'LockedOut': BiometricAuthResult.lockedOut,
      'PermanentlyLockedOut': BiometricAuthResult.permanentlyLockedOut,
      'NotEnrolled': BiometricAuthResult.notEnrolled,
      'PasscodeNotSet': BiometricAuthResult.passcodeNotSet,
      'NotAvailable': BiometricAuthResult.notAvailable,
      'UserCanceled': BiometricAuthResult.canceled,
      'user_canceled': BiometricAuthResult.canceled,
      'auth_in_progress': BiometricAuthResult.error,
      'something_else': BiometricAuthResult.error,
    };

    for (final entry in cases.entries) {
      test('${entry.key} -> ${entry.value.name}', () async {
        when(
          () => platform.authenticate(
            localizedReason: any(named: 'localizedReason'),
            authMessages: any(named: 'authMessages'),
            options: any(named: 'options'),
          ),
        ).thenThrow(PlatformException(code: entry.key));

        expect(await authenticate(), entry.value);
      });
    }
  });

  group('isTerminalFailure', () {
    test('marks config-bound failures as terminal', () {
      for (final result in [
        BiometricAuthResult.notEnrolled,
        BiometricAuthResult.notAvailable,
        BiometricAuthResult.permanentlyLockedOut,
        BiometricAuthResult.passcodeNotSet,
      ]) {
        expect(BiometricService.isTerminalFailure(result), isTrue);
      }
    });

    test('marks retryable outcomes as non-terminal', () {
      for (final result in [
        BiometricAuthResult.success,
        BiometricAuthResult.canceled,
        BiometricAuthResult.lockedOut,
        BiometricAuthResult.error,
      ]) {
        expect(BiometricService.isTerminalFailure(result), isFalse);
      }
    });
  });

  group('createAuthMessages', () {
    test('builds Android and iOS messages from l10n', () {
      final messages = BiometricService.createAuthMessages(
        AppLocalizationsEn(),
      );

      expect(messages, hasLength(2));
    });
  });
}
