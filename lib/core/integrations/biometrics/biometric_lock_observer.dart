import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/app_logger.dart';
import '../../utils/crash_reporter.dart';
import 'biometric_service.dart';

/// Enforces the biometric app lock and database integrity across app lifecycle changes.
class BiometricLockObserver with WidgetsBindingObserver {
  /// Whether biometric lock is enabled.
  final bool Function() isBiometricLockEnabled;

  /// Whether the app is currently locked.
  final bool Function()? isAppLocked;

  /// Called with `true` if locked, `false` if unlocked.
  final ValueChanged<bool> onLockStateChanged;

  final Stream<bool>? lockEnabledStream;

  /// Resolves the localized reason shown in the biometric prompt.
  final String Function() localizedReason;

  /// Invoked after database was reopened.
  final Future<void> Function()? onDatabaseReopened;

  final Future<({bool reopened})> Function() verifyDatabaseIntegrity;

  bool _isLockEnabled = false;
  bool _disposed = false;
  StreamSubscription<bool>? _subscription;

  /// Creates a [BiometricLockObserver].
  BiometricLockObserver({
    required this.isBiometricLockEnabled,
    required this.onLockStateChanged,
    required this.localizedReason,
    this.isAppLocked,
    this.lockEnabledStream,
    this.onDatabaseReopened,
    required this.verifyDatabaseIntegrity,
  }) {
    _isLockEnabled = isBiometricLockEnabled();
    WidgetsBinding.instance.addObserver(this);
    _subscription = lockEnabledStream?.listen((enabled) {
      _isLockEnabled = enabled;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    if (state == AppLifecycleState.resumed) {
      _verifyDatabaseIntegrity();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _checkBiometricLock();
    }
  }

  Future<void> _verifyDatabaseIntegrity() async {
    try {
      final result = await verifyDatabaseIntegrity();
      if (result.reopened) {
        await onDatabaseReopened?.call();
      }
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricLockObserver] Database integrity check on resumption failed',
        fatal: false,
      );
    }
  }

  Future<void> _checkBiometricLock() async {
    if (!_isLockEnabled) return;

    if (BiometricService.instance.isAuthenticating) return;
    if (BiometricService.instance.wasAuthenticatingRecently) return;
    if (isAppLocked?.call() == true) return;

    log.i(
      '[BiometricLockObserver] App backgrounded while lock enabled -> locking',
    );
    onLockStateChanged(true);
  }

  /// Safe to call multiple times.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Convenience alias for [dispose].
  void removeThisObserver() => dispose();
}
