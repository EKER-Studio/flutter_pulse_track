import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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

class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.info.index;
    }
    return true;
  }
}

class FirebaseCrashlyticsOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (kDebugMode) return;

    for (final line in event.lines) {
      if (event.level.index >= Level.error.index) {
        FirebaseCrashlytics.instance.recordError(
          event.origin.error ?? line,
          event.origin.stackTrace,
          reason: event.origin.message,
        );
      } else if (event.level.index >= Level.info.index) {
        FirebaseCrashlytics.instance.log(line);
      }
    }
  }
}
