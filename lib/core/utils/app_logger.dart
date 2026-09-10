import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' hide ProductionFilter;

/// Top-level singleton logger for structured logging across the application.
///
/// Outputs formatted log messages to the console in debug mode and forwards
/// errors to Firebase Crashlytics in production.
final log = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  filter: ProductionFilter(),
  output: MultiOutput([ConsoleOutput(), FirebaseCrashlyticsOutput()]),
);

/// Custom log filter that suppresses detailed debug logs in release mode.
///
/// Allows all log events during development, but filters events below [Level.info] in release builds.
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.info.index;
    }
    return true;
  }
}

/// Custom log output that delivers log events to Firebase Crashlytics.
///
/// Only `error` and above are forwarded to Crashlytics to avoid leaking
/// personally identifiable data (BLE MAC, device names) that may appear in
/// `info`/`debug` logs (see C-2).
class FirebaseCrashlyticsOutput extends LogOutput {
  /// Whether errors should be forwarded to Crashlytics during debug runs.
  final bool enableInDebug;

  /// Creates a [FirebaseCrashlyticsOutput] instance.
  ///
  /// @param enableInDebug If true, forwards errors in debug mode. Defaults to false.
  FirebaseCrashlyticsOutput({this.enableInDebug = false});

  @override
  void output(OutputEvent event) {
    if (kDebugMode && !enableInDebug) return;

    try {
      if (Firebase.apps.isEmpty) return;

      final fullMessage = event.lines.join('\n');
      if (event.level.index >= Level.error.index) {
        FirebaseCrashlytics.instance.recordError(
          event.origin.error ?? fullMessage,
          event.origin.stackTrace,
          reason: event.origin.message,
        );
      }
    } catch (_) {
      // Safe fallback when Crashlytics is unreachable.
    }
  }
}
