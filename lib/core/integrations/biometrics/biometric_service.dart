import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import '../../utils/app_logger.dart';
import '../../utils/crash_reporter.dart';
import '../../../l10n/app_localizations.dart';

/// Represents the outcome of a biometric authentication attempt.
enum BiometricAuthResult {
  /// Authentication succeeded.
  success,

  /// The user dismissed or rejected the prompt (retryable).
  canceled,

  /// Biometrics are temporarily locked out (retryable after the OS cool-down).
  lockedOut,

  /// Biometrics are permanently locked out until the user re-enrolls.
  permanentlyLockedOut,

  /// No biometric credentials are enrolled on this device.
  notEnrolled,

  /// No device passcode is set, so biometric-only authentication cannot work.
  passcodeNotSet,

  /// Biometrics are not available or unsupported on this device.
  notAvailable,

  /// Authentication failed for any other reason.
  error,
}

/// A singleton service that authenticates users via biometrics with fallback to PIN/pattern/password.
class BiometricService {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _authentication = LocalAuthentication();

  /// Broadcast stream emitting an event after every successful authentication.
  Stream<void> get authenticationSuccesses =>
      _authenticationSuccessController.stream;

  StreamController<void> _authenticationSuccessController =
      StreamController<void>.broadcast();

  @visibleForTesting
  static void resetForTesting() {
    if (!instance._authenticationSuccessController.isClosed) {
      instance._authenticationSuccessController.close();
    }
    instance._authenticationSuccessController =
        StreamController<void>.broadcast();
    instance._lastAuthCompletionTime = null;
  }

  Future<void> dispose() async {
    if (!_authenticationSuccessController.isClosed) {
      await _authenticationSuccessController.close();
    }
  }

  void _notifyAuthenticationSuccess() {
    if (!_authenticationSuccessController.isClosed) {
      _authenticationSuccessController.add(null);
    }
  }

  /// Whether the device has biometric hardware and at least one enrolled credential.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _authentication.canCheckBiometrics;
      if (kDebugMode) {
        log.d('[BiometricService] canCheckBiometrics: $canCheck');
      }
      if (!canCheck) return false;
      final biometrics = await _authentication.getAvailableBiometrics();
      if (kDebugMode) {
        log.d('[BiometricService] getAvailableBiometrics: $biometrics');
      }
      return biometrics.isNotEmpty;
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricService] isAvailable check failed',
        fatal: false,
      );
      return false;
    }
  }

  /// Whether biometric authentication is fully supported by the OS.
  Future<bool> isSupported() async {
    try {
      final deviceSupported = await _authentication.isDeviceSupported();
      if (kDebugMode) {
        log.d('[BiometricService] isDeviceSupported: $deviceSupported');
      }
      if (!deviceSupported) return false;
      final canCheck = await _authentication.canCheckBiometrics;
      if (kDebugMode) {
        log.d('[BiometricService] canCheckBiometrics: $canCheck');
      }
      return canCheck;
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricService] isSupported check failed',
        fatal: false,
      );
      return false;
    }
  }

  /// Checks whether the device can present any OS credential prompt.
  Future<bool> canAuthenticate() async {
    try {
      final deviceSupported = await _authentication.isDeviceSupported();
      if (kDebugMode) {
        log.d('[BiometricService] isDeviceSupported: $deviceSupported');
      }
      final canCheck = await _authentication.canCheckBiometrics;
      if (kDebugMode) {
        log.d('[BiometricService] canCheckBiometrics: $canCheck');
      }
      return deviceSupported || canCheck;
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricService] canAuthenticate check failed',
        fatal: false,
      );
      return false;
    }
  }

  Future<BiometricAuthResult>? _activeAuthFuture;
  DateTime? _lastAuthCompletionTime;

  /// Whether biometric authentication is currently in progress.
  bool get isAuthenticating => _activeAuthFuture != null;

  /// Whether authentication finished very recently (within 1 second).
  bool get wasAuthenticatingRecently {
    final lastCompletion = _lastAuthCompletionTime;
    return lastCompletion != null &&
        DateTime.now().difference(lastCompletion) < const Duration(seconds: 1);
  }

  /// Prompts the user for device credential authentication.
  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
    Iterable<AuthMessages>? authMessages,
  }) async {
    if (_activeAuthFuture != null) {
      if (kDebugMode) {
        log.d(
          '[BiometricService] Authentication already in progress. Re-using active Future.',
        );
      }
      return _activeAuthFuture!;
    }

    _activeAuthFuture = _performAuthentication(
      localizedReason: localizedReason,
      authMessages: authMessages,
    );

    try {
      return await _activeAuthFuture!;
    } finally {
      _activeAuthFuture = null;
      _lastAuthCompletionTime = DateTime.now();
    }
  }

  Future<BiometricAuthResult> _performAuthentication({
    required String localizedReason,
    Iterable<AuthMessages>? authMessages,
  }) async {
    try {
      final canAuth = await canAuthenticate();
      if (kDebugMode) {
        log.d('[BiometricService] authenticate -> canAuthenticate: $canAuth');
      }
      if (!canAuth) return BiometricAuthResult.notAvailable;

      final ok = await LocalAuthPlatform.instance.authenticate(
        localizedReason: localizedReason,
        authMessages: authMessages ?? const <AuthMessages>[],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (kDebugMode) {
        log.d('[BiometricService] authenticate result: $ok');
      }
      if (ok) {
        _notifyAuthenticationSuccess();
        return BiometricAuthResult.success;
      }
      return BiometricAuthResult.canceled;
    } on LocalAuthException catch (e, stack) {
      if (e.code == LocalAuthExceptionCode.deviceError ||
          e.code == LocalAuthExceptionCode.unknownError) {
        await AppCrashReporter.recordError(
          e,
          stack,
          reason:
              '[BiometricService] LocalAuthException ${e.code.name}: ${e.description}',
          fatal: false,
        );
      }
      return switch (e.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.userRequestedFallback ||
        LocalAuthExceptionCode.timeout => BiometricAuthResult.canceled,
        LocalAuthExceptionCode.temporaryLockout =>
          BiometricAuthResult.lockedOut,
        LocalAuthExceptionCode.biometricLockout =>
          BiometricAuthResult.permanentlyLockedOut,
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          BiometricAuthResult.notEnrolled,
        LocalAuthExceptionCode.noCredentialsSet =>
          BiometricAuthResult.passcodeNotSet,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricAuthResult.notAvailable,
        LocalAuthExceptionCode.authInProgress ||
        LocalAuthExceptionCode.uiUnavailable ||
        LocalAuthExceptionCode.deviceError ||
        LocalAuthExceptionCode.unknownError => BiometricAuthResult.error,
      };
    } on MissingPluginException catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricService] MissingPluginException: $e',
        fatal: false,
      );
      return BiometricAuthResult.notAvailable;
    } on PlatformException catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricService] PlatformException: ${e.code} ${e.message}',
        fatal: false,
      );
      return switch (e.code) {
        'LockedOut' => BiometricAuthResult.lockedOut,
        'PermanentlyLockedOut' => BiometricAuthResult.permanentlyLockedOut,
        'NotEnrolled' => BiometricAuthResult.notEnrolled,
        'PasscodeNotSet' => BiometricAuthResult.passcodeNotSet,
        'NotAvailable' => BiometricAuthResult.notAvailable,
        'NotAuthenticated' ||
        'UserCanceled' ||
        'SystemCanceled' ||
        'AuthenticationCanceled' ||
        'user_canceled' ||
        'canceled' => BiometricAuthResult.canceled,
        'auth_in_progress' => BiometricAuthResult.error,
        _ => BiometricAuthResult.error,
      };
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricService] authenticate unexpected exception',
        fatal: false,
      );
      return BiometricAuthResult.error;
    }
  }

  /// Whether [result] means the user cannot authenticate until device config changes.
  static bool isTerminalFailure(BiometricAuthResult result) {
    return switch (result) {
      BiometricAuthResult.notEnrolled ||
      BiometricAuthResult.notAvailable ||
      BiometricAuthResult.permanentlyLockedOut ||
      BiometricAuthResult.passcodeNotSet => true,
      _ => false,
    };
  }

  /// Creates localized AuthMessages based on [AppLocalizations].
  static List<AuthMessages> createAuthMessages(AppLocalizations l10n) {
    return [
      AndroidAuthMessages(
        signInTitle: l10n.biometricStepTitle,
        cancelButton: l10n.cancel,
      ),
      IOSAuthMessages(cancelButton: l10n.cancel),
    ];
  }
}
