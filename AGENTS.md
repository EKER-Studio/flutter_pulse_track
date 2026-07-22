# Agent Rules

## Scope Discipline

- Only read/open/modify files explicitly named in the task or directly imported/referenced by them. Do not explore or edit outside stated scope without asking first.
- Exception (no asking required): regenerate `.g.dart` codegen outputs for modified source files, and update the directly-related test file to keep verification green.
- If the task seems to need files beyond scope + exceptions, stop and report which files and why.

## Verification Pipeline (run in order after any `lib/` change)

1. `dart run build_runner build --delete-conflicting-outputs`
2. `flutter analyze lib/ test/` (ignore `build/` issues from Firebase plugins — pre-existing noise)
3. `flutter test`
4. `dart format .`

Do NOT commit unless all four pass. Do NOT skip, weaken, or silence a test/lint to make the pipeline pass.

## Architecture

Feature-first Clean Architecture with three layers per feature under `lib/features/<feature>/`:
- **domain/** — entities, repo interfaces, use cases. Pure Dart. NO Flutter or Riverpod imports.
- **infrastructure/** — repo implementations via `isar_community`. Handles DB persistence and BLE parsing.
- **presentation/** — UI via `ConsumerWidget` + notifiers via `@riverpod` generators. State management is Riverpod 3.x.

Data flow: `ConsumerWidget` → `@riverpod` notifier → domain repo interface → infrastructure repo impl → Isar DB.
Reactivity: Isar streams piped into `AsyncValue` state by notifiers.

## Theme

All colors live in `lib/core/presentation/theme/app_colors.dart` — never use raw `Color(0xFF...)` or direct `Colors.*` in views. Use the `AppColors.*` semantic constant instead. Add new tokens there when needed.

## Logger

Use the top-level `log` singleton from `lib/core/utils/app_logger.dart` — never `debugPrint` or `print` (`avoid_print` lint is active). The codebase already has zero `debugPrint` calls.
```dart
import 'package:pulse_track/core/utils/app_logger.dart';
log.d('debug message');
log.e('error context', error: e, stackTrace: st);
log.w('warning');
```
Available methods: `log.t`, `log.d`, `log.i`, `log.w`, `log.e`, `log.f`. In release mode, only `info`+ passes through; `error`+ are sent to Firebase Crashlytics.

## Codegen

Files annotated with `@riverpod` or `@collection` produce `.g.dart` parts. Always regenerate after modifying annotated classes: `dart run build_runner build --delete-conflicting-outputs`.

Generated `*.g.dart` files are excluded from the analyzer (pre-configured in `analysis_options.yaml`). The `custom_lint` plugin is active for Riverpod-specific linting.

## Localization (l10n)

Infrastructure is wired (`l10n.yaml`, `flutter gen-l10n`, `flutter_localizations` + `intl`), but `lib/l10n/app_en.arb` is **empty**. There are no localized strings yet. Use plain English strings in views until real translations are added. Do NOT fake `.arb` entries.

## Key constraints

- **Domain layer purity:** No Flutter, Riverpod, or Isar imports in `domain/` — not even in doc comments.
- **Isar initialization:** Always use `Isar.getInstance() ?? await Isar.open(...)` to prevent dual-open errors.
- **Disposal:** Every `StreamSubscription`, `Timer`, and BLE connection must be cancelled/stopped in `ref.onDispose()`. Handle `AppLifecycleState.paused`/`detached` for background tasks.
- **Formatting:** Use `dart format .` — never manually indent or reformat.
- **No `// ignore:` comments** or lint suppression.
- **No `dart:math` imports** unless the file genuinely uses math functions (not just `max`/`min` on collections — use `fold` or direct comparison).

## HR packet parser quirks

- `HrPacketParser.parseRawBytes` reads BLE 0x2A37 characteristic data.
- Sensor contact status: Bit 2 (0x04) = supported, Bit 1 (0x02) = active. If 0x04 is off, `sensorContactActive` must be `null` regardless of Bit 1.
- R-R intervals are raw uint16 values divided by 1024 to get seconds.
- 16-bit BPM is little-endian.

## Test

- Only test file: `test/features/heart_rate/infrastructure/parsers/hr_packet_parser_test.dart` (31 tests).
- Run with `flutter test`.

## CI

Workflow at `.github/workflows/ci.yml` caches `~/.pub-cache` and `.dart_tool/` via `actions/cache@v4`, keyed on `runner.os` + `hashFiles('pubspec.lock')`.
