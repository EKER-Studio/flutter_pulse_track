import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// Title shown in the app bar of the home dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'PulseTrack'**
  String get homeTitle;

  /// Header above the horizontal list of previously-connected BLE sensors.
  ///
  /// In en, this message translates to:
  /// **'Saved Sensors (Direct Connect)'**
  String get savedSensorsSectionTitle;

  /// Fallback label shown when a saved device profile has an empty name.
  ///
  /// In en, this message translates to:
  /// **'Unknown Sensor'**
  String get unknownSensorLabel;

  /// Fallback device name passed to the monitor screen when a saved profile has an empty name.
  ///
  /// In en, this message translates to:
  /// **'Saved Sensor'**
  String get savedSensorFallbackName;

  /// Label for the primary call-to-action button that opens the BLE scanner screen.
  ///
  /// In en, this message translates to:
  /// **'Scan for New Sensor'**
  String get scanForNewSensorButton;

  /// Title of the workout history placeholder card and its screen.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistoryTitle;

  /// Subtitle text under the workout history placeholder card on the home screen.
  ///
  /// In en, this message translates to:
  /// **'View past heart rate sessions and analytics.'**
  String get workoutHistoryDescription;

  /// Title shown in the AppBar of the BLE scanner screen.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner_title;

  /// Semantic label for the Bluetooth searching icon.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth scanning'**
  String get bluetooth_searching_label;

  /// Semantic label for the Bluetooth disabled icon.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth disabled'**
  String get bluetooth_disabled_label;

  /// Semantic label for the unknown device icon.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get device_unknown_label;

  /// Tooltip for the filter toggle button in the scanner view.
  ///
  /// In en, this message translates to:
  /// **'Toggle Names & Nearby Filter'**
  String get toggle_filter_tooltip;

  /// Header text displayed when the scanner is idle.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get ready_to_scan;

  /// Helper text shown under the ready‑to‑scan header.
  ///
  /// In en, this message translates to:
  /// **'Tap Scan to begin searching for sensors.'**
  String get start_scan_description;

  /// Label for the primary scan button.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan_button_label;

  /// Header when Bluetooth is turned off.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Required'**
  String get bluetooth_required;

  /// Explanation shown when Bluetooth is off.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth adapter is powered off or unauthorized. Please enable Bluetooth and grant local infrastructure permissions to scan for sensors.'**
  String get bluetooth_off_description;

  /// Title shown when no devices are found after a scan.
  ///
  /// In en, this message translates to:
  /// **'CAN\'T SEE YOUR DEVICE?'**
  String get empty_state_title;

  /// Bullet list displayed in the empty‑state view.
  ///
  /// In en, this message translates to:
  /// **'• Ensure the sensor is powered on.\n• Check the sensor battery.\n• Move closer to the device.\n• Try disabling the scan filters.'**
  String get empty_state_bullets;

  /// Button label to retry scanning from the empty‑state view.
  ///
  /// In en, this message translates to:
  /// **'Retry Scan'**
  String get retry_scan_label;

  /// Title shown when a scan cannot be started.
  ///
  /// In en, this message translates to:
  /// **'Scan Failed'**
  String get scan_failed_title;

  /// Button label to retry after a failure.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry_button_label;

  /// Message displayed while the scanner is actively searching.
  ///
  /// In en, this message translates to:
  /// **'Searching for active sensors...'**
  String get searching_sensors;

  /// Placeholder name for a device that reports an empty name.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get unknown_device;

  /// Semantic label for the Scan button.
  ///
  /// In en, this message translates to:
  /// **'Start scanning for heart rate sensors'**
  String get scan_button_semantic_label;

  /// Semantic label for the Retry Scan button in empty state.
  ///
  /// In en, this message translates to:
  /// **'Retry scanning for sensors'**
  String get retry_scan_semantic_label;

  /// Semantic label for saved sensor chips on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Connect to {sensorName}'**
  String connectToSensor(String sensorName);

  /// Semantics hint for each device row in the scanner list.
  ///
  /// In en, this message translates to:
  /// **'MAC address {id}, signal strength {rssi} dBm. Double-tap to connect.'**
  String deviceListTileHint(String id, int rssi);

  /// Label for the disconnect button in the monitor view AppBar.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectButton;

  /// Semantics hint for the disconnect button.
  ///
  /// In en, this message translates to:
  /// **'Disconnects from {deviceName}'**
  String disconnectHint(String deviceName);

  /// Status text shown when the sensor is disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnectedStatus;

  /// Button label to navigate back to the scanner screen.
  ///
  /// In en, this message translates to:
  /// **'Return to Scanner'**
  String get returnToScannerButton;

  /// Semantics hint for the Return to Scanner button.
  ///
  /// In en, this message translates to:
  /// **'Navigates back to the device scanner screen'**
  String get returnToScannerHint;

  /// Progress message shown during BLE link-layer connection.
  ///
  /// In en, this message translates to:
  /// **'Connecting to device...\nLink-layer handshake in progress'**
  String get connectingMessage;

  /// Progress message shown during GATT service discovery.
  ///
  /// In en, this message translates to:
  /// **'Discovering Services... Please wait...'**
  String get discoveringServicesMessage;

  /// Header label above the live BPM reading.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get heartRateLabel;

  /// Accessibility live region label for the current heart rate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate: {bpm} beats per minute'**
  String heartRateLiveLabel(int bpm);

  /// Abbreviation for beats per minute.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpmUnit;

  /// Title for the sensor location info card.
  ///
  /// In en, this message translates to:
  /// **'Body sensor location'**
  String get bodySensorLocationTitle;

  /// Accessibility label for the sensor location card.
  ///
  /// In en, this message translates to:
  /// **'Body sensor location: {location}'**
  String bodySensorLocationLabel(String location);

  /// Title for the battery level info card.
  ///
  /// In en, this message translates to:
  /// **'Sensor battery'**
  String get sensorBatteryTitle;

  /// Accessibility label for the battery card.
  ///
  /// In en, this message translates to:
  /// **'Sensor battery level: {level}'**
  String sensorBatteryLabel(String level);

  /// Displayed when battery level is unavailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get batteryNotAvailable;

  /// Title of the failure state card in the monitor view.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailedTitle;

  /// Button label to retry connecting to a device.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get retryConnectionButton;

  /// Semantics hint for the retry connection button.
  ///
  /// In en, this message translates to:
  /// **'Attempts to reconnect to the heart rate sensor'**
  String get retryConnectionHint;

  /// Button label to navigate back from the failure state.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// Semantics hint for the go back button.
  ///
  /// In en, this message translates to:
  /// **'Returns to the previous screen'**
  String get goBackHint;

  /// AppBar title for the workout history screen.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistoryAppBarTitle;

  /// Semantic label for the dismiss-to-delete gesture background.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSessionLabel;

  /// Semantics hint for the delete session action.
  ///
  /// In en, this message translates to:
  /// **'Deletes this workout session'**
  String get deleteSessionHint;

  /// Error message when workout history fails to load.
  ///
  /// In en, this message translates to:
  /// **'Unable to load workout history. Please try again later.'**
  String get unableToLoadHistory;

  /// Fallback device name shown on workout cards when the original is empty.
  ///
  /// In en, this message translates to:
  /// **'Unknown Sensor'**
  String get unknownSensorName;

  /// Title in the empty state of workout history.
  ///
  /// In en, this message translates to:
  /// **'No workouts recorded yet'**
  String get noWorkoutsTitle;

  /// Description in the empty state of workout history.
  ///
  /// In en, this message translates to:
  /// **'Complete a heart rate monitoring session to see your workout history here.'**
  String get noWorkoutsDescription;

  /// Semantic label for a workout history card.
  ///
  /// In en, this message translates to:
  /// **'Workout on {date}'**
  String workoutCardLabel(String date);

  /// Semantics hint for a workout history card.
  ///
  /// In en, this message translates to:
  /// **'Duration {duration}, sensor {device}. Average heart rate {avg} BPM, Peak heart rate {max} BPM. Swipe left to delete.'**
  String workoutCardHint(String duration, String device, int avg, int max);

  /// SnackBar message when session deletion fails.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete session. Please try again.'**
  String get unableToDeleteSession;

  /// Label for the average BPM metric on workout cards.
  ///
  /// In en, this message translates to:
  /// **'Avg BPM'**
  String get avgBpmMetric;

  /// Label for the max BPM metric on workout cards.
  ///
  /// In en, this message translates to:
  /// **'Max BPM'**
  String get maxBpmMetric;

  /// Date prefix for workouts that occurred today.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayPrefix(String time);

  /// Date prefix for workouts that occurred yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String yesterdayPrefix(String time);

  /// Error shown when saved sensors fail to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load saved sensors: {error}'**
  String failedToLoadSavedSensors(String error);

  /// AppBar title for the route error view.
  ///
  /// In en, this message translates to:
  /// **'Navigation Error'**
  String get routeErrorTitle;

  /// Headline for unknown route.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeErrorNotFound;

  /// Details for invalid route.
  ///
  /// In en, this message translates to:
  /// **'Invalid address or broken deep link.'**
  String get routeErrorInvalidLink;

  /// Button to return to home from route error.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get routeErrorBackHome;

  /// AppBar title for workout details.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get workoutDetailsTitle;

  /// Semantics/back tooltip for workout details.
  ///
  /// In en, this message translates to:
  /// **'Back to workout history'**
  String get workoutDetailsBackHint;

  /// Tooltip/semantics for export button.
  ///
  /// In en, this message translates to:
  /// **'Export workout data to CSV'**
  String get workoutDetailsExportHint;

  /// Snackbar when export fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to export workout session: {error}'**
  String workoutDetailsExportFailed(String error);

  /// Header for summary grid.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get workoutDetailsSummary;

  /// Header for BPM chart.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate Over Time'**
  String get workoutDetailsHeartRateOverTime;

  /// Placeholder when no BPM samples.
  ///
  /// In en, this message translates to:
  /// **'No workout data captured'**
  String get workoutDetailsNoData;

  /// Reason when endTime is null.
  ///
  /// In en, this message translates to:
  /// **'The workout was not completed'**
  String get workoutDetailsNotCompleted;

  /// Reason when samples empty.
  ///
  /// In en, this message translates to:
  /// **'The sensor may have disconnected before data was captured'**
  String get workoutDetailsSensorDisconnected;

  /// Generic no-data reason.
  ///
  /// In en, this message translates to:
  /// **'No valid heart rate data was recorded'**
  String get workoutDetailsNoValidData;

  /// Tile label average BPM.
  ///
  /// In en, this message translates to:
  /// **'Average BPM'**
  String get workoutDetailsAvgBpm;

  /// Tile label peak BPM.
  ///
  /// In en, this message translates to:
  /// **'Peak BPM'**
  String get workoutDetailsPeakBpm;

  /// Tile label duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutDetailsDuration;

  /// Tile label samples.
  ///
  /// In en, this message translates to:
  /// **'Samples'**
  String get workoutDetailsSamples;

  /// Badge when endTime is null.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Fallback sensor name.
  ///
  /// In en, this message translates to:
  /// **'Unknown Sensor'**
  String get unknownSensor;

  /// Body sensor location other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get bodySensorLocationOther;

  /// Body sensor location chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get bodySensorLocationChest;

  /// Body sensor location wrist.
  ///
  /// In en, this message translates to:
  /// **'Wrist'**
  String get bodySensorLocationWrist;

  /// Body sensor location finger.
  ///
  /// In en, this message translates to:
  /// **'Finger'**
  String get bodySensorLocationFinger;

  /// Body sensor location hand.
  ///
  /// In en, this message translates to:
  /// **'Hand'**
  String get bodySensorLocationHand;

  /// Body sensor location earLobe.
  ///
  /// In en, this message translates to:
  /// **'Ear Lobe'**
  String get bodySensorLocationEarLobe;

  /// Body sensor location foot.
  ///
  /// In en, this message translates to:
  /// **'Foot'**
  String get bodySensorLocationFoot;

  /// Body sensor location unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get bodySensorLocationUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
