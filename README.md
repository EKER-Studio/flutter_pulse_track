# PulseTrack: Heart Rate Monitor

A production-ready, high-performance Flutter application for real-time heart rate monitoring via
Bluetooth Low Energy (BLE). Built with a Local-First architecture, utilizing Riverpod for reactive
state management and Isar for high-speed local data persistence.

## Features

* **Real-time Telemetry**: Low-latency parsing of standard GATT Heart Rate Service (`0x180D`) streaming heart rate values and R-R intervals (raw timing data; no HRV computation).
* **Smart Direct Connect**: Local-First device caching via Isar database allows instant, one-tap connections to previously paired sensors, bypassing expensive and battery-draining hardware air discovery.
* **Universal Capability Discovery**: Dynamic runtime resolution of Body Sensor Location (`0x2A38`) and continuous live streaming of Battery Level (`0x180F`).
* **Resilient Background Protection**: Engineered with a strict Android Foreground Service boundary to prevent OS-level process termination when the device is locked or dark-screened during a workout.
* **Reactive State Machine**: Powered by Riverpod 3.x, mapping native BLE events into an exhaustive, type-safe sealed state architecture with atomic error boundaries.
* **Environmental Safety**: Hardware state detection catching disabled Bluetooth adapters and connection timeouts instantly at the UI layer.
* **Workout Persistence & Export**: Isar-backed workout history with crash recovery, CSV export/share, and heart-rate zone analytics.
* **Settings & Data Management**: Theme/metrics preferences, CSV workout import with preview, biometric app lock, and full data wipe — all persisted locally.
* **Onboarding & Navigation**: Guided first-run onboarding plus adaptive navigation (bottom bar / navigation rail).
* **Health & Platform Integrations**: Optional sync to Health Connect/HealthKit, daily reminders, and home-screen widget sync.
* **Localization**: Full i18n in 10 locales (de, en, es, fr, it, ja, ko, nl, pl, pt) via `flutter gen-l10n`.

## Verification

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format lib test integration_test test_driver
flutter analyze
dart run custom_lint
./scripts/check_boundaries.sh
flutter test --exclude-tags "golden,screenshot"
```

Or run the full pipeline at once: `./scripts/before_push.sh` (additionally builds a debug APK).

## Architecture

This project follows a strict clean architectural pattern:

* **Domain**: Pure business entities, model contracts, and immutable state definitions.
* **Infrastructure**: Low-level hardware abstractions (`flutter_blue_plus`) and high-speed local persistence engines (`isar`).
* **Presentation**: Fully reactive, dark-themed UI components and controller notifiers orchestrating state transformations.

## Getting Started

1. Clone the repository.
2. Install dependencies: `flutter pub get`.
3. Generate localizations: `flutter gen-l10n`.
4. Run code generation: `dart run build_runner build --delete-conflicting-outputs`.
5. Provide Firebase configuration (`lib/firebase_options.dart` via FlutterFire, or CI stubs) — the app runs with dummy config outside release builds.
6. Ensure Bluetooth and Location permissions are granted on your physical Android/iOS device.
7. Launch the application.

## App Icons & Splash Screen

After replacing the placeholder images in `assets/icon/`, regenerate the platform assets:

```bash
# Generate App Icons
dart run flutter_launcher_icons

# Generate Native Splash Screen
dart run flutter_native_splash:create
```

## License

[MIT License](LICENSE)