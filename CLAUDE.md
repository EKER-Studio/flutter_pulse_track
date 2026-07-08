# Claude Code Project Rules - Flutter Riverpod Boilerplate

## Build & Generation Commands
- Install dependencies: `flutter pub get`
- Run build runner: `dart run build_runner build --delete-conflicting-outputs`
- Watch build runner: `dart run build_runner watch --delete-conflicting-outputs`
- Code analysis: `flutter analyze`
- Run tests: `flutter test`

## Architecture Guide
This is a Local-First, AI-Native boilerplate utilizing Clean Architecture under a Feature-First approach.

- **Data Flow:** UI (`ConsumerWidget`) -> Notifier (`@riverpod`) -> Repository Interface (`domain`) -> Repository Impl (`data`) -> Local DB (`isar_community`).
- **Reactivity:** Handled purely via Isar streams. Notifiers listen to Isar collections and pipe data directly into `AsyncValue` state.

## Formatting & Style
- Follow official Dart style guide (`dart format .`).
- Ensure all generated files (`.g.dart`) are correctly linked via `part 'filename.g.dart';`.