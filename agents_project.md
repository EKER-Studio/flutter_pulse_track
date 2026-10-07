# Project-Specific Rules — pulse_track

*Companion to `AGENTS.md`. Save this file as `agents_project.md` in this repo's root, next to `AGENTS.md`.
Formerly `ble_heart_rate_monitor` — package renamed.*

### Build & Generation Commands
| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter gen-l10n` | Generate localization scaffolding (see Localization note below) |
| `dart run build_runner build --delete-conflicting-outputs` | Generate Riverpod + Isar code |
| `dart run flutter_launcher_icons` | Generate app icons for all platforms |
| `dart run flutter_native_splash:create` | Generate native splash screen |
| `dart format lib test integration_test test_driver` | Format code |
| `flutter analyze` | Static analysis |
| `dart run custom_lint` | Riverpod-specific lints — separate from `flutter analyze`, do not skip |
| `./scripts/check_boundaries.sh` | Machine-enforced import boundaries (domain purity, no Isar in presentation) |
| `flutter test --exclude-tags "golden,screenshot"` | Run non-golden tests |
| `flutter build apk --debug` | Verify Android build integrity |
| `./scripts/before_push.sh` | Full pipeline: pub get → gen-l10n → build_runner → format → analyze → custom_lint → check_boundaries → test → apk build |

### Architecture & Layer Boundaries
Feature-first Clean Architecture under `lib/features/<feature>/`. Five features currently exist: `heart_rate`,
`workout`, `settings`, `navigation`, and `onboarding`. Shared code lives in `lib/core/` (theme, logger, storage, foreground services).

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
Full localization infrastructure is active (`l10n.yaml`, `flutter gen-l10n`, `flutter_localizations` + `intl`).
English (`lib/l10n/app_en.arb`) serves as the base template; 10 locales ship
(de, en, es, fr, it, ja, ko, nl, pl, pt) with Polish as the primary translation.
Always keep key sets synchronized across all `app_*.arb` files.

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
- **Provider placement:** `@riverpod` providers for infrastructure services (e.g.
  `csvWorkoutImportService`) live in `application/*_providers.dart`, never in `infrastructure/` —
  presentation must import providers only from the application layer. The custom lint
  `avoid_infrastructure_imports_in_presentation` enforces this for workout, heart_rate,
  settings, and core infrastructure paths.
- **Accepted BLE type leakage:** `ble_scanner_notifier.dart` and `hr_monitor_notifier.dart` import
  `flutter_blue_plus` types (`Guid`, `ScanResult`, `BluetoothDevice`, ...) because the
  `BluetoothScannerService` / `HeartRateMonitorService` contracts themselves expose them.
  All operations still go through the service abstractions; full domain-type wrapping is
  deferred mid-term work, not a boundary violation.

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
- Run with `flutter test --exclude-tags "golden,screenshot"` (golden/screenshot tests are
  environment-dependent and excluded from the canonical pipeline).
- Unit-test scope covers domain, data/infrastructure, and presentation controllers
  (notifiers, providers, router gates). Plain views/screens/dialogs (app shell:
  navigation, onboarding, settings dialogs, biometric shield) are intentionally
  out of unit-test scope — covered by screenshot integration tests instead.

### CI
`.github/workflows/ci.yml` runs on push/PR to `develop` (with `concurrency` cancel-in-progress).
Caches `~/.pub-cache`, Gradle caches, and the Isar native binary (`libisar.so`), keyed on the
`pubspec.lock` hash. Runs the same steps as `./scripts/before_push.sh` (including
`./scripts/check_boundaries.sh`), plus `--coverage` upload — keep both in sync when the
pipeline changes.

### Mandatory Verification Pipeline (concrete commands)
Matches `./scripts/before_push.sh`:
1. `flutter pub get`
2. `flutter gen-l10n`
3. `dart run build_runner build`
4. `dart format lib test integration_test test_driver`
5. `flutter analyze`
6. `dart run custom_lint`
7. `./scripts/check_boundaries.sh`
8. `flutter test --exclude-tags "golden,screenshot"`

Once all steps are green and the Resource Lifecycle checklist above is verified, commit per `AGENTS.md` →
Git & Version Control (autonomous commit is enabled for this repo, since this file exists).
