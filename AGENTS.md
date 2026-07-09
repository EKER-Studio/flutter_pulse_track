# Codex Project Rules - Flutter Riverpod Boilerplate

## Build & Generation Commands
- Install dependencies: `flutter pub get`
- Run build runner: `dart run build_runner build --delete-conflicting-outputs`
- Watch build runner: `dart run build_runner watch --delete-conflicting-outputs`
- Code analysis: `flutter analyze`
- Run tests: `flutter test`

## Architecture & State Management
This is a Local-First, AI-Native boilerplate utilizing Clean Architecture under a Feature-First approach.
- **State Management:** Riverpod 3.x strictly.
- **Data Flow:** UI (`ConsumerWidget`) -> Notifier (`@riverpod`) -> Repository Interface (`domain`) -> Repository Impl (`data`) -> Local DB (`isar_community`).
- **Reactivity:** Handled purely via Isar streams. Notifiers listen to Isar collections and pipe data directly into `AsyncValue` state.

## Project Conventions & Agent Workflow
- **Language:** All technical comments, documentation, and logic descriptions in the codebase MUST be written in English.
- **Mandatory Verification Pipeline:** After any modification within the `lib/**` directory, you MUST execute the following pipeline in strict order:
    1. `dart run build_runner build --delete-conflicting-outputs`
    2. `flutter analyze`
       *(A task is NOT considered complete until `flutter analyze` returns absolutely zero errors. Fix any arising issues autonomously).*

## Formatting & Style
- Follow official Dart style guide (`dart format .`).
- Ensure all generated files (`.g.dart`) are correctly linked via `part 'filename.g.dart';`.