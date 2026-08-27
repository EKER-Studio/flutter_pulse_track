# Project-Specific Rules — pulse_track

*Companion to `AGENTS.md`. Save this file as `agents_project.md` in this repo's root, next to `AGENTS.md`.
Formerly `ble_heart_rate_monitor` — package renamed.*

### Build & Generation Commands
| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter gen-l10n` | Generate localization scaffolding (see Localization note below) |
| `dart run build_runner build` | Generate Riverpod + Isar code |
| `dart run flutter_launcher_icons` | Generate app icons for all platforms |
| `dart run flutter_native_splash:create` | Generate native splash screen |
| `dart format lib test` | Format code |
| `flutter analyze` | Static analysis |
| `dart run custom_lint` | Riverpod-specific lints — separate from `flutter analyze`, do not skip |
| `flutter test --exclude-tags golden` | Run non-golden tests |
| `./scripts/before_push.sh` | Full pipeline: pub get → gen-l10n → build_runner → format → analyze → custom_lint → test |

### Architecture & Layer Boundaries
Feature-first Clean Architecture under `lib/features/<feature>/`. Two features currently exist: `heart_rate`
and `workout`. Shared code lives in `lib/core/` (theme, logger, storage, foreground services).

- **Domain** (`domain/`): Pure Dart — entities, repository interfaces, use cases. NO Flutter, Riverpod, or
  Isar imports allowed here — not even in doc comments.
- **Infrastructure** (`infrastructure/`): Repository implementations combining `isar_community` (DB
  persistence) AND `flutter_blue_plus` (BLE parsing) together — this layer is NOT split into separate
  data/BLE folders.
- **Presentation** (`presentation/`): UI (`ConsumerWidget`) and state management via Riverpod 3.x generators
  (`@riverpod`).
- **State Management:** Riverpod 3.x strictly.
- **Data Flow:** `ConsumerWidget` → `@riverpod` notifier → domain repository interface → infrastructure
  repository impl → Isar DB.
- **Reactivity:** Isar streams piped into `AsyncValue` state by notifiers.

### Theme Convention
Implements the universal UI Hygiene rule via `AppColors.*` semantic constants defined in
`lib/core/presentation/theme/app_colors.dart`. Add new tokens there when needed.

### Logging Convention
Implements the universal Logging Hygiene rule via the top-level `log` singleton in
`lib/core/utils/app_logger.dart`:

```dart
import 'package:pulse_track/core/utils/app_logger.dart';
log.d('debug message');
log.e('error context', error: e, stackTrace: st);
```

Available methods: `log.t`, `log.d`, `log.i`, `log.w`, `log.e`, `log.f`. In release mode, only `info`+ passes
through; `error`+ is sent to Firebase Crashlytics.

### Localization (l10n)
Infrastructure is wired (`l10n.yaml`, `flutter gen-l10n`, `flutter_localizations` + `intl`), but
`lib/l10n/app_en.arb` is currently **empty** — no localized strings yet. Use plain English strings in views
until real translations are added. Do NOT fabricate `.arb` entries to fill this gap.

### HR Packet Parser Quirks
`HrPacketParser.parseRawBytes` reads BLE `0x2A37` characteristic data — these rules are load-bearing for
correctness, handle with care:
- Sensor contact status: Bit 2 (`0x04`) = supported, Bit 1 (`0x02`) = active. If `0x04` is off,
  `sensorContactActive` MUST be `null` regardless of Bit 1.
- R-R intervals are raw `uint16` values divided by 1024 to get seconds.
- 16-bit BPM is little-endian.

### Key Constraints
- **Isar initialization:** Always use `Isar.getInstance() ?? await Isar.open(...)` to prevent dual-open
  errors.
- **No `dart:math` imports** unless the file genuinely uses math functions (not just `max`/`min` on
  collections — use `fold` or direct comparison instead).

### Resource Lifecycle & Disposal (concrete items)
- Every `StreamSubscription` cancelled in `dispose()` or the corresponding Notifier's `ref.onDispose()`.
- Every `Timer`/`AnimationController` cancelled/disposed the same way.
- BLE connections/scans (`flutter_blue_plus`) explicitly stopped on dispose — never left running when the
  widget/notifier is torn down.
- App lifecycle transitions (`AppLifecycleState.paused`/`detached`) handled explicitly where background tasks
  (`flutter_foreground_task`) are involved — verify the task is paused/stopped appropriately, not left
  orphaned.

### Testing Conventions
- Tests live in `test/`, mirroring the `lib/` structure.
- Run with `flutter test` (or `flutter test --exclude-tags golden` to skip golden tests).

### CI
`.github/workflows/ci.yml` runs on push/PR to `main`. Caches `~/.pub-cache` and `.dart_tool/`, keyed on the
`pubspec.lock` hash.

### Mandatory Verification Pipeline (concrete commands)
Matches `./scripts/before_push.sh`:
1. `dart run build_runner build`
2. `dart format lib test`
3. `flutter analyze`
4. `dart run custom_lint`
5. `flutter test --exclude-tags golden`

Once all 5 steps are green and the Resource Lifecycle checklist above is verified, commit per `AGENTS.md` →
Git & Version Control (autonomous commit is enabled for this repo, since this file exists).
