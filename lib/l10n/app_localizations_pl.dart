// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get homeTitle => 'PulseTrack';

  @override
  String get savedSensorsSectionTitle =>
      'Zapisane czujniki (Połączenie bezpośrednie)';

  @override
  String get unknownSensorLabel => 'Nieznany czujnik';

  @override
  String get savedSensorFallbackName => 'Zapisany czujnik';

  @override
  String get scanForNewSensorButton => 'Skanuj nowe urządzenie';

  @override
  String get workoutHistoryTitle => 'Historia treningów';

  @override
  String get workoutHistoryDescription =>
      'Przeglądaj przeszłe sesje tętna i analitykę.';

  @override
  String get scanner_title => 'Skaner';

  @override
  String get bluetooth_searching_label => 'Skanowanie Bluetooth';

  @override
  String get bluetooth_disabled_label => 'Bluetooth wyłączony';

  @override
  String get device_unknown_label => 'Nieznane urządzenie';

  @override
  String get bluetooth_device_label => 'Urządzenie Bluetooth';

  @override
  String get toggle_filter_tooltip =>
      'Przełącz filtr nazw i pobliskich urządzeń';

  @override
  String get ready_to_scan => 'Gotowy do skanowania';

  @override
  String get start_scan_description =>
      'Stuknij Skanuj, aby rozpocząć wyszukiwanie czujników.';

  @override
  String get scan_button_label => 'Skanuj';

  @override
  String get bluetooth_required => 'Wymagany Bluetooth';

  @override
  String get bluetooth_off_description =>
      'Adapter Bluetooth jest wyłączony lub brak uprawnień. Włącz Bluetooth i przyznaj uprawnienia lokalne, aby skanować czujniki.';

  @override
  String get empty_state_title => 'NIE WIDZISZ SWOJEGO URZĄDZENIA?';

  @override
  String get empty_state_bullets =>
      '• Upewnij się, że czujnik jest włączony.\n• Sprawdź baterię czujnika.\n• Zbliż się do urządzenia.\n• Spróbuj wyłączyć filtry skanowania.';

  @override
  String get retry_scan_label => 'Ponów skanowanie';

  @override
  String get scan_failed_title => 'Skanowanie nie powiodło się';

  @override
  String get retry_button_label => 'Ponów';

  @override
  String get searching_sensors => 'Wyszukiwanie aktywnych czujników...';

  @override
  String get unknown_device => 'Nieznane urządzenie';

  @override
  String get scan_button_semantic_label =>
      'Rozpocznij skanowanie w poszukiwaniu czujników tętna';

  @override
  String get retry_scan_semantic_label =>
      'Ponów skanowanie w poszukiwaniu czujników';

  @override
  String connectToSensor(String sensorName) {
    return 'Połącz z $sensorName';
  }

  @override
  String deviceListTileHint(String id, int rssi) {
    return 'Adres MAC $id, moc sygnału $rssi dBm. Stuknij dwukrotnie, aby połączyć.';
  }

  @override
  String get disconnectButton => 'Rozłącz';

  @override
  String disconnectHint(String deviceName) {
    return 'Rozłącza z urządzeniem $deviceName';
  }

  @override
  String get disconnectedStatus => 'Rozłączono';

  @override
  String get returnToScannerButton => 'Powrót do skanera';

  @override
  String get returnToScannerHint => 'Powraca do ekranu skanera urządzeń';

  @override
  String get connectingMessage =>
      'Łączenie z urządzeniem...\nTrwa nawiązywanie połączenia';

  @override
  String get discoveringServicesMessage =>
      'Wyszukiwanie usług... Proszę czekać...';

  @override
  String get heartRateLabel => 'Tętno';

  @override
  String heartRateLiveLabel(int bpm) {
    return 'Tętno: $bpm uderzeń na minutę';
  }

  @override
  String get bpmUnit => 'BPM';

  @override
  String get bodySensorLocationTitle => 'Lokalizacja czujnika';

  @override
  String bodySensorLocationLabel(String location) {
    return 'Lokalizacja czujnika: $location';
  }

  @override
  String get sensorBatteryTitle => 'Bateria czujnika';

  @override
  String sensorBatteryLabel(String level) {
    return 'Poziom baterii czujnika: $level';
  }

  @override
  String get batteryNotAvailable => 'Brak danych';

  @override
  String get connectionFailedTitle => 'Połączenie nieudane';

  @override
  String get retryConnectionButton => 'Ponów połączenie';

  @override
  String get retryConnectionHint =>
      'Próbuje ponownie połączyć się z czujnikiem tętna';

  @override
  String get goBackButton => 'Wstecz';

  @override
  String get goBackHint => 'Powraca do poprzedniego ekranu';

  @override
  String get workoutHistoryAppBarTitle => 'Historia treningów';

  @override
  String get deleteSessionLabel => 'Usuń';

  @override
  String get deleteSessionHint => 'Usuwa tę sesję treningową';

  @override
  String get unableToLoadHistory =>
      'Nie można wczytać historii treningów. Spróbuj ponownie później.';

  @override
  String get unknownSensorName => 'Nieznany czujnik';

  @override
  String get noWorkoutsTitle => 'Brak zarejestrowanych treningów';

  @override
  String get noWorkoutsDescription =>
      'Ukończ sesję monitorowania tętna, aby zobaczyć historię treningów w tym miejscu.';

  @override
  String workoutCardLabel(String date) {
    return 'Trening w dniu $date';
  }

  @override
  String workoutCardHint(String duration, String device, int avg, int max) {
    return 'Czas trwania $duration, czujnik $device. Średnie tętno $avg BPM, Szczytowe tętno $max BPM. Przesuń w lewo, aby usunąć.';
  }

  @override
  String get unableToDeleteSession =>
      'Nie można usunąć sesji. Spróbuj ponownie.';

  @override
  String get avgBpmMetric => 'Śr. BPM';

  @override
  String get maxBpmMetric => 'Maks. BPM';

  @override
  String todayPrefix(String time) {
    return 'Dzisiaj, $time';
  }

  @override
  String yesterdayPrefix(String time) {
    return 'Wczoraj, $time';
  }

  @override
  String failedToLoadSavedSensors(String error) {
    return 'Nie można wczytać zapisanych czujników: $error';
  }

  @override
  String get routeErrorTitle => 'Błąd nawigacji';

  @override
  String get routeErrorNotFound => 'Nie znaleziono żądanej strony';

  @override
  String get routeErrorInvalidLink =>
      'Nieprawidłowy adres lub uszkodzony link głęboki.';

  @override
  String get routeErrorBackHome => 'Powrót do strony głównej';

  @override
  String get databaseErrorTitle => 'Błąd bazy danych';

  @override
  String get databaseErrorDescription =>
      'Wystąpił krytyczny błąd bazy danych. Spróbuj zrestartować aplikację lub wyczyścić jej pamięć podręczną.';

  @override
  String get workoutDetailsTitle => 'Szczegóły treningu';

  @override
  String get workoutDetailsBackHint => 'Powrót do historii treningów';

  @override
  String get workoutDetailsExportHint => 'Eksportuj dane treningu do CSV';

  @override
  String workoutDetailsExportFailed(String error) {
    return 'Nie udało się wyeksportować sesji: $error';
  }

  @override
  String get workoutDetailsSummary => 'Podsumowanie';

  @override
  String get workoutDetailsHeartRateOverTime => 'Tętno w czasie';

  @override
  String get workoutDetailsNoData => 'Brak zarejestrowanych danych';

  @override
  String get workoutDetailsNotCompleted => 'Trening nie został ukończony';

  @override
  String get workoutDetailsSensorDisconnected =>
      'Czujnik mógł zostać rozłączony przed zapisem danych';

  @override
  String get workoutDetailsNoValidData =>
      'Nie zarejestrowano prawidłowych danych tętna';

  @override
  String get workoutDetailsAvgBpm => 'Śr. BPM';

  @override
  String get workoutDetailsPeakBpm => 'Maks. BPM';

  @override
  String get workoutDetailsDuration => 'Czas trwania';

  @override
  String get workoutDetailsSamples => 'Próbki';

  @override
  String get inProgress => 'W trakcie';

  @override
  String get unknownSensor => 'Nieznany czujnik';

  @override
  String get bodySensorLocationOther => 'Inne';

  @override
  String get bodySensorLocationChest => 'Klatka piersiowa';

  @override
  String get bodySensorLocationWrist => 'Nadgarstek';

  @override
  String get bodySensorLocationFinger => 'Palec';

  @override
  String get bodySensorLocationHand => 'Dłoń';

  @override
  String get bodySensorLocationEarLobe => 'Płatek ucha';

  @override
  String get bodySensorLocationFoot => 'Stopa';

  @override
  String get bodySensorLocationUnknown => 'Nieznane';
}
