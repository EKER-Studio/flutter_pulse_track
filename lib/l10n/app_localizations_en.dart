// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'HR Companion';

  @override
  String get savedSensorsSectionTitle => 'Saved Sensors (Direct Connect)';

  @override
  String get unknownSensorLabel => 'Unknown Sensor';

  @override
  String get savedSensorFallbackName => 'Saved Sensor';

  @override
  String get scanForNewSensorButton => 'Scan for New Sensor';

  @override
  String get workoutHistoryTitle => 'Workout History';

  @override
  String get workoutHistoryDescription =>
      'View past heart rate sessions and analytics.';
}
