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

  @override
  String get scan_button_semantic_label =>
      'Start scanning for heart rate sensors';

  @override
  String get retry_scan_semantic_label => 'Retry scanning for sensors';

  @override
  String connectToSensor(String sensorName) {
    return 'Connect to $sensorName';
  }

  @override
  String deviceListTileHint(String id, int rssi) {
    return 'MAC address $id, signal strength $rssi dBm. Double-tap to connect.';
  }

  @override
  String get disconnectButton => 'Disconnect';

  @override
  String disconnectHint(String deviceName) {
    return 'Disconnects from $deviceName';
  }

  @override
  String get disconnectedStatus => 'Disconnected';

  @override
  String get returnToScannerButton => 'Return to Scanner';

  @override
  String get returnToScannerHint =>
      'Navigates back to the device scanner screen';

  @override
  String get connectingMessage =>
      'Connecting to device...\nLink-layer handshake in progress';

  @override
  String get discoveringServicesMessage =>
      'Discovering Services... Please wait...';

  @override
  String get heartRateLabel => 'Heart rate';

  @override
  String heartRateLiveLabel(int bpm) {
    return 'Heart rate: $bpm beats per minute';
  }

  @override
  String get bpmUnit => 'BPM';

  @override
  String get bodySensorLocationTitle => 'Body sensor location';

  @override
  String bodySensorLocationLabel(String location) {
    return 'Body sensor location: $location';
  }

  @override
  String get sensorBatteryTitle => 'Sensor battery';

  @override
  String sensorBatteryLabel(String level) {
    return 'Sensor battery level: $level';
  }

  @override
  String get batteryNotAvailable => 'N/A';

  @override
  String get connectionFailedTitle => 'Connection Failed';

  @override
  String get retryConnectionButton => 'Retry Connection';

  @override
  String get retryConnectionHint =>
      'Attempts to reconnect to the heart rate sensor';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get goBackHint => 'Returns to the previous screen';

  @override
  String get workoutHistoryAppBarTitle => 'Workout History';

  @override
  String get deleteSessionLabel => 'Delete';

  @override
  String get deleteSessionHint => 'Deletes this workout session';

  @override
  String get unableToLoadHistory =>
      'Unable to load workout history. Please try again later.';

  @override
  String get unknownSensorName => 'Unknown Sensor';

  @override
  String get noWorkoutsTitle => 'No workouts recorded yet';

  @override
  String get noWorkoutsDescription =>
      'Complete a heart rate monitoring session to see your workout history here.';

  @override
  String workoutCardLabel(String date) {
    return 'Workout on $date';
  }

  @override
  String workoutCardHint(String duration, String device, int avg, int max) {
    return 'Duration $duration, sensor $device. Average heart rate $avg BPM, Peak heart rate $max BPM. Swipe left to delete.';
  }

  @override
  String get unableToDeleteSession =>
      'Unable to delete session. Please try again.';

  @override
  String get avgBpmMetric => 'Avg BPM';

  @override
  String get maxBpmMetric => 'Max BPM';

  @override
  String todayPrefix(String time) {
    return 'Today, $time';
  }

  @override
  String yesterdayPrefix(String time) {
    return 'Yesterday, $time';
  }

  @override
  String failedToLoadSavedSensors(String error) {
    return 'Failed to load saved sensors: $error';
  }

  @override
  String get routeErrorTitle => 'Navigation Error';

  @override
  String get routeErrorNotFound => 'Page not found';

  @override
  String get routeErrorInvalidLink => 'Invalid address or broken deep link.';

  @override
  String get routeErrorBackHome => 'Back to home';

  @override
  String get workoutDetailsTitle => 'Workout Details';

  @override
  String get workoutDetailsBackHint => 'Back to workout history';

  @override
  String get workoutDetailsExportHint => 'Export workout data to CSV';

  @override
  String workoutDetailsExportFailed(String error) {
    return 'Failed to export workout session: $error';
  }

  @override
  String get workoutDetailsSummary => 'Summary';

  @override
  String get workoutDetailsHeartRateOverTime => 'Heart Rate Over Time';

  @override
  String get workoutDetailsNoData => 'No workout data captured';

  @override
  String get workoutDetailsNotCompleted => 'The workout was not completed';

  @override
  String get workoutDetailsSensorDisconnected =>
      'The sensor may have disconnected before data was captured';

  @override
  String get workoutDetailsNoValidData =>
      'No valid heart rate data was recorded';

  @override
  String get workoutDetailsAvgBpm => 'Average BPM';

  @override
  String get workoutDetailsPeakBpm => 'Peak BPM';

  @override
  String get workoutDetailsDuration => 'Duration';

  @override
  String get workoutDetailsSamples => 'Samples';

  @override
  String get inProgress => 'In Progress';

  @override
  String get unknownSensor => 'Unknown Sensor';

  @override
  String get bodySensorLocationOther => 'Other';

  @override
  String get bodySensorLocationChest => 'Chest';

  @override
  String get bodySensorLocationWrist => 'Wrist';

  @override
  String get bodySensorLocationFinger => 'Finger';

  @override
  String get bodySensorLocationHand => 'Hand';

  @override
  String get bodySensorLocationEarLobe => 'Ear Lobe';

  @override
  String get bodySensorLocationFoot => 'Foot';

  @override
  String get bodySensorLocationUnknown => 'Unknown';
}
