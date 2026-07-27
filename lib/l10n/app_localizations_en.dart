// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'PulseTrack';

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

  @override
  String get scanner_title => 'Scanner';

  @override
  String get bluetooth_searching_label => 'Bluetooth scanning';

  @override
  String get bluetooth_disabled_label => 'Bluetooth disabled';

  @override
  String get device_unknown_label => 'Unknown device';

  @override
  String get bluetooth_device_label => 'Bluetooth device';

  @override
  String get toggle_filter_tooltip => 'Toggle Names & Nearby Filter';

  @override
  String get ready_to_scan => 'Ready to scan';

  @override
  String get start_scan_description =>
      'Tap Scan to begin searching for sensors.';

  @override
  String get scan_button_label => 'Scan';

  @override
  String get bluetooth_required => 'Bluetooth Required';

  @override
  String get bluetooth_off_description =>
      'Bluetooth adapter is powered off or unauthorized. Please enable Bluetooth and grant local infrastructure permissions to scan for sensors.';

  @override
  String get empty_state_title => 'CAN\'T SEE YOUR DEVICE?';

  @override
  String get empty_state_bullets =>
      '• Ensure the sensor is powered on.\n• Check the sensor battery.\n• Move closer to the device.\n• Try disabling the scan filters.';

  @override
  String get retry_scan_label => 'Retry Scan';

  @override
  String get scan_failed_title => 'Scan Failed';

  @override
  String get retry_button_label => 'Retry';

  @override
  String get searching_sensors => 'Searching for active sensors...';

  @override
  String get unknown_device => 'Unknown Device';
}
