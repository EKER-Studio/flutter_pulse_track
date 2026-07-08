# BLE Heart Rate Monitor

A production-ready, high-performance Flutter application for real-time heart rate monitoring via
Bluetooth Low Energy (BLE). Built with a Local-First architecture, utilizing Riverpod for reactive
state management and Isar for high-speed local data persistence.

## Features

* **Real-time Telemetry**: Low-latency parsing of standard GATT Heart Rate Service (0x180D).
* **Universal Compatibility**: Dynamic reading of Body Sensor Location (0x2A38) and Battery Level (
  0x180F).
* **Local-First Architecture**: Offline-ready data storage using Isar database to track workout
  sessions.
* **Reactive State**: Robust state management using Riverpod 3.0, ensuring seamless UI
  synchronization with hardware lifecycle.
* **Resilient Connectivity**: Advanced connection handling with automatic GATT discovery, timeouts,
  and lifecycle management.

## Architecture

This project follows a clean architectural pattern:

* **Domain**: Pure business entities, model contracts, and service definitions.
* **Infrastructure**: Implementation of hardware interfaces (FlutterBluePlus) and data storage (
  Isar).
* **Presentation**: Reactive UI components and state controllers using Riverpod.

## Getting Started

1. Clone the repository.
2. Install dependencies: `flutter pub get`.
3. Run code generation: `dart run build_runner build --delete-conflicting-outputs`.
4. Launch on your physical Android/iOS device.

## License

[MIT License](LICENSE)