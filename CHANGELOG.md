# Changelog

All notable changes to **PulseTrack** are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Conventional Commits](https://www.conventionalcommits.org/).

## [1.0.3] - 2026-09-29

### Added
- **privacy**: add user opt-out toggles for anonymous Crashlytics crash reporting and Firebase Analytics in Settings (`75aafae`)
- **settings**: add Privacy Policy and Rate App tiles with external browser redirection (`75aafae`)
- **l10n**: add localization strings for privacy toggles, diagnostics, and app rating in English and Polish (`75aafae`)
- **r8**: add keep rules for `flutter_local_notifications` broadcast receivers to prevent stripping in release builds (`614f128`)

### Fixed
- **android**: remove deprecated `windowLayoutInDisplayCutoutMode` in Android 12+ styles XML (`7d05bc6`)

### Changed
- **tooling**: scope `riverpod_generator` in `build.yaml` to application/controller files, accelerating `build_runner` execution (`dc02dc2`)
- **lint**: streamline `analysis_options.yaml` by adopting strict safety rules and removing redundant options inherited from `flutter_lints` (`5b3e6e9`)
- **ci**: make test and integration formatting checks dynamic in `scripts/before_push.sh` (`bfae0f9`)
- **deps**: bump dependencies, align Flutter SDK constraint to `>=3.47.0` and compile Android against SDK 36 (`d7021fd`)

## [1.0.2] - 2026-09-10

### Security
- **security**: stop leaking BLE PII (MAC, device name) to Crashlytics — `FirebaseCrashlyticsOutput` now forwards only `error` level, `HrMonitorNotifier` redacts identifiers (`5b710f0`)

### Fixed
- **isar**: guard `Isar.open` with `Isar.getInstance()` and document plaintext-at-rest decision; fix `saveWorkoutCheckpoint` sentinel returning `Isar.autoIncrement (-1)` on empty samples → `int?` nullable (`5e1e8ab`)
- **lifecycle**: `BleScannerNotifier` pauses hardware scan on `AppLifecycleState.paused/inactive` to avoid background battery drain (`08ef070`)
- **i18n**: externalize hardcoded `Retry` in `WorkoutHistoryView`, sync 12 missing `@placeholder` blocks in `app_pl.arb` and remove 3 dead keys (`bluetooth_device_label`, `databaseErrorTitle/Description`) — key sets now 91/91 (`ce31d03`)

### Added
- **l10n**: 25 new keys for route errors, workout details, body sensor locations and `failedToLoadSavedSensors` with EN/PL translations (`cc32f4b`)
- **test**: `BodySensorLocationL10n` 17 tests (all 8 locations × en/pl) (`54607ba`), `WorkoutExportService` +5 edge cases (bpm 0, single sample, null endTime, duration split) (`20322e6`)

### Changed
- **lint**: `avoid_infrastructure_imports_in_presentation` now also blocks `pulse_track/features/*/infrastructure` and `core/infrastructure` (`d060e42`)
- **docs**: remove trivial `Creates the ... widget` DartDoc in core, heart_rate and workout features (`03564cd`, `1e8fea6`, `54f2529`)
- **chore**: `dart format lib test` across 12 test files (`6c29705`)

## [1.0.1] - 2026-07-22

Bump from `1.0.0+1` → `1.0.1+2` (`bf7e62c` — `chore(release): bump application version`).

Range `bf7e62c..a81a244` — 148 commits:

### Added
- **l10n**: wire `AppLocalizations` delegates, localize home screen (`607b3df`), add PL translations
- **lint**: enforce presentation/isar boundary via `custom_lint` (`b7d1170`, `7196aa5`, `1ea1a94`)
- **workout**: `WorkoutExportService` CSV + share (`bc6a5c3`, `a304427`, `817e9c1`), `WorkoutHistoryView` reactive, HR zones
- **BLE**: foreground service (`de9e229`), Battery Service `0x180F` (`2e94a94`, `d6311ef`), local-first direct connect (`9b4e8d1`)

### Fixed
- **logger**: guard Crashlytics against uninitialized Firebase (`810e9f5`)
- **ble**: wake-lock release on link loss (`75cd370`), connection race conditions (`b8a2c91`), secure logging (`3e78785`)
- **workout**: stop checkpoint duplicate row every 30s (`ab6cca4`)
- **ci**: Flutter 3.47 pin, cache, Isar binary fetch, coverage reporting (`402d727`)
- **build**: correct `isar_generator` target to `infrastructure/models` (`d97c894`)
- **test**: valid `Level` in `app_logger_test` (`a81a244`)

### Changed
- **project**: rename to `PulseTrack` / `pulsetrack` package (`e98f673`, `b380eb0`, `8b874a2`)
- **deps**: `fake_async`, `csv`, `share_plus`, `firebase_*`, `go_router` upgrades

## [1.0.0] - 2026-07-08

Initial release — `1.0.0+1` (`042a559` boilerplate → `bf7e62c^`).

Range `042a559..bf7e62c^` — 119 commits:

- **heart_rate**: domain contracts, `BleConnectionStatus`, `BleDevice`, `HrMeasurement`, Isar DTOs, `HrPacketParser` with energy-expended & RR/1024 handling, FBP scanner/monitor services with timeouts
- **architecture**: Clean Architecture feature-first (`heart_rate`/`workout`), Riverpod 3.x codegen, `BodySensorLocation` 0x2A38, `MonitorState`/`BleScannerState` sealed
- **persistence**: Isar schemas, `DeviceProfileDto` upsert-by-MAC, `WorkoutSessionDto` indexed `startTime`, `sanitizeCrashedSessions`
- **presentation**: `HrScannerView`, `HrMonitorView` live telemetry, `HrHomeView` direct-connect chips, `AppColors` tokens, `GoRouter` migration (`8066e48`)
- **platform**: Android `FOREGROUND_SERVICE_HEALTH`, iOS splash/icons (`f020cb1`, `645221f`)
- **tooling**: `build.yaml`, `l10n.yaml`, `analysis_options`, `before_push.sh` pipeline

---

**Versioning:** `version: x.y.z+build` — `x.y.z` = semver, `+build` = Android `versionCode` / iOS `CFBundleVersion`.
