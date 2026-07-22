# EKER Studio HR Companion

A production-ready, high-performance Flutter application for real-time heart rate monitoring via
Bluetooth Low Energy (BLE). Built with a Local-First architecture, utilizing Riverpod for reactive
state management and Isar for high-speed local data persistence.

## Features

* **Real-time Telemetry**: Low-latency parsing of standard GATT Heart Rate Service (`0x180D`) streaming heart rate values and high-precision R-R intervals for HRV analysis.
* **Smart Direct Connect**: Local-First device caching via Isar database allows instant, one-tap connections to previously paired sensors, bypassing expensive and battery-draining hardware air discovery.
* **Universal Capability Discovery**: Dynamic runtime resolution of Body Sensor Location (`0x2A38`) and continuous live streaming of Battery Level (`0x180F`).
* **Resilient Background Protection**: Engineered with a strict Android Foreground Service boundary to prevent OS-level process termination when the device is locked or dark-screened during a workout.
* **Reactive State Machine**: Powered by Riverpod 3.0, mapping native BLE events into an exhaustive, type-safe sealed state architecture with atomic error boundaries.
* **Environmental Safety**: Immersive hardware state detection catching disabled Bluetooth adapters, runtime permission revokes, and connection timeouts instantly at the UI layer.

## Architecture

This project follows a rygorystyczny clean architectural pattern:

* **Domain**: Pure business entities, model contracts, and immutable state definitions.
* **Infrastructure**: Low-level hardware abstractions (`flutter_blue_plus`) and high-speed local persistence engines (`isar`).
* **Presentation**: Fully reactive, dark-themed UI components and controller notifiers orchestrating state transformations.

## Getting Started

1. Clone the repository.
2. Install dependencies: `flutter pub get`.
3. Run code generation: `dart run build_runner build --delete-conflicting-outputs`.
4. Ensure Bluetooth and Location permissions are granted on your physical Android/iOS device.
5. Launch the application.

## License

[MIT License](LICENSE)