import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/app_logger.dart';
import '../../utils/crash_reporter.dart';
import 'biometric_service.dart';

/// Enforces the biometric app lock and database integrity across app lifecycle changes.
///
/// The lock-enabled state is always read live via [isBiometricLockEnabled]
/// on every lifecycle transition, so toggling the setting takes effect
/// immediately without an app restart.
class BiometricLockObserver with WidgetsBindingObserver {
  /// Whether biometric lock is enabled.
  final bool Function() isBiometricLockEnabled;

  /// Whether the app is currently locked.
  final bool Function()? isAppLocked;

  /// Called with `true` if locked, `false` if unlocked.
  final ValueChanged<bool> onLockStateChanged;

  /// Resolves the localized reason shown in the biometric prompt.
  final String Function() localizedReason;

  /// Invoked after database was reopened.
  final Future<void> Function()? onDatabaseReopened;

  final Future<({bool reopened})> Function() verifyDatabaseIntegrity;

  bool _disposed = false;

  /// Creates a [BiometricLockObserver].
  BiometricLockObserver({
    required this.isBiometricLockEnabled,
    required this.onLockStateChanged,
    required this.localizedReason,
    this.isAppLocked,
    this.onDatabaseReopened,
    required this.verifyDatabaseIntegrity,
  }) {
    WidgetsBinding.instance.addObserver(this);
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
    } on Object catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[BiometricLockObserver] Database integrity check on resumption failed',
      );
    }
  }

  Future<void> _checkBiometricLock() async {
    if (!isBiometricLockEnabled()) return;

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
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Convenience alias for [dispose].
  void removeThisObserver() => dispose();
}
