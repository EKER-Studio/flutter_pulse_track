# AI Agent Project Rules

## Universal Conventions
*(These apply to every project regardless of tech stack — keep this section identical across repos.)*

### Language
All technical comments, documentation, and logic descriptions in the codebase MUST be written in English.

### Documentation Convention
For every public class/method, add a doc comment following the language's standard doc format (e.g. dartdoc for Dart, JSDoc for TypeScript):
- One sentence summarizing purpose (don't repeat the class/method name).
- One line per non-trivial parameter (`@param` or equivalent).
- Return value documentation only if it isn't obvious from the type.
- NO code examples unless the logic is genuinely non-obvious.
- Do not document trivial getters/setters or self-explanatory boilerplate.

### Scope Discipline
- Only read, open, or modify files explicitly named in the task, or files directly imported/referenced by them.
- Do NOT explore or edit files outside the stated scope without first asking for confirmation.
- Exception — the following do NOT require asking first, as they are natural consequences of a task, not scope expansion:
  - Regenerating/updating codegen output files (e.g. `.g.dart`) that correspond to a modified source file.
  - Updating an existing test file that directly tests the modified code, when needed to keep the Mandatory Verification Pipeline passing.
- If the task seems to require touching files beyond the stated scope AND beyond the exceptions above, STOP and report which additional files you believe are needed, and why — before making changes.

### Ambiguity Handling
- If a requirement is ambiguous or underspecified, state your interpretation/assumption explicitly before proceeding, rather than silently guessing.
- Prefer asking one direct clarifying question over implementing multiple speculative variants.

### Dependency Changes
- Do NOT add, remove, or upgrade a dependency without explicitly flagging it in your response (name, version, reason).
- Never introduce a new dependency to solve a problem that can be reasonably solved with existing project dependencies or stdlib.

### Git & Version Control
- Once the full Mandatory Verification Pipeline has passed (all steps green, zero errors, zero failing tests) for a completed, atomic logical change, commit it without asking for permission first.
- Do NOT commit if any pipeline step failed, was skipped, or could not be run — stop and report instead, per Guardrails and Verification Honesty above.
- Write descriptive, atomic commit messages (what changed and why, not just "fix").
- NEVER force-push, rewrite shared history, or delete branches without explicit confirmation.

### Security
- NEVER hardcode API keys, tokens, passwords, or other secrets in source code.
- NEVER commit `.env` files or other files containing local secrets.
- Use environment variables / the platform's secure storage mechanism for anything sensitive.

### Verification Honesty
- NEVER report that a verification step (build, analyze, lint, test) passed unless you actually executed it in this session and observed the output.
- If a step cannot be run (e.g. missing tool, sandboxed environment limitation), say so explicitly instead of assuming or claiming success.
- Do not fabricate or paraphrase tool output — quote or summarize only what was actually returned.

### Debug Artifact Cleanup
- Remove debug print/log statements and commented-out code introduced during iteration before considering a task complete, unless explicitly asked to leave them for further debugging.
- Do not leave stray TODO comments describing unfinished work without flagging them explicitly in your final summary.

### Guardrails
- NEVER delete, skip, or weaken a test to make the verification pipeline pass. Fix the underlying code instead.
- NEVER add lint-suppression comments (e.g. `// ignore:`) or disable analyzer/linter rules to silence errors, unless explicitly instructed.
- If a fix is not obvious after 2 attempts, stop and report the exact error instead of applying a workaround.

### Formatting & Style
- Follow the official style guide / formatter for the language in use (e.g. `dart format .`).
- Ensure all generated files are correctly linked/imported per the framework's conventions (e.g. `part 'filename.g.dart';` for Dart build_runner output).

---

## Project Stack: pulse_track
*(Formerly `ble_heart_rate_monitor` — package renamed. Replace this whole section when starting a new project with a different stack.)*

### Build & Generation Commands
| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install dependencies |
| `flutter gen-l10n` | Generate localization scaffolding (see Localization note below) |
| `dart run build_runner build --delete-conflicting-outputs` | Generate Riverpod + Isar code |
| `dart run flutter_launcher_icons` | Generate app icons for all platforms |
| `dart run flutter_native_splash:create` | Generate native splash screen |
| `dart format --output=none --set-exit-if-changed .` | Check formatting |
| `flutter analyze` | Static analysis |
| `dart run custom_lint` | Riverpod-specific lints — **separate from `flutter analyze`, do not skip** |
| `flutter test --exclude-tags golden` | Run non-golden tests |
| `./before_push.sh` | Full pipeline: pub get → gen-l10n → build_runner → format → analyze → custom_lint → test |

### Architecture & Layer Boundaries
Feature-first Clean Architecture under `lib/features/<feature>/`. Two features currently exist: `heart_rate` and `workout`. Shared code lives in `lib/core/` (theme, logger, storage, foreground services).

- **Domain Layer** (`lib/features/<feature>/domain/`): Pure Dart — entities, repository interfaces, use cases. NO Flutter, Riverpod, or Isar imports allowed here — not even in doc comments.
- **Infrastructure Layer** (`lib/features/<feature>/infrastructure/`): Repository implementations combining `isar_community` (DB persistence) AND `flutter_blue_plus` (BLE parsing) together — this layer is NOT split into separate data/BLE folders.
- **Presentation Layer** (`lib/features/<feature>/presentation/`): UI (`ConsumerWidget`) and state management via Riverpod 3.x generators (`@riverpod`).
- **State Management:** Riverpod 3.x strictly.
- **Data Flow:** `ConsumerWidget` -> `@riverpod` notifier -> domain repository interface -> infrastructure repository impl -> Isar DB.
- **Reactivity:** Isar streams piped into `AsyncValue` state by notifiers.

### Theme Convention
All colors live in `lib/core/presentation/theme/app_colors.dart` — never use raw `Color(0xFF...)` or direct `Colors.*` in views. Use the `AppColors.*` semantic constant instead; add new tokens there when needed.

### Logging Convention
Use the top-level `log` singleton from `lib/core/utils/app_logger.dart` — never `debugPrint` or `print` (`avoid_print` lint is active).

```dart
import 'package:pulse_track/core/utils/app_logger.dart';
log.d('debug message');
log.e('error context', error: e, stackTrace: st);
```

Available methods: `log.t`, `log.d`, `log.i`, `log.w`, `log.e`, `log.f`. In release mode, only `info`+ passes through; `error`+ is sent to Firebase Crashlytics.

### Localization (l10n)
Infrastructure is wired (`l10n.yaml`, `flutter gen-l10n`, `flutter_localizations` + `intl`), but `lib/l10n/app_en.arb` is currently **empty** — no localized strings yet. Use plain English strings in views until real translations are added. Do NOT fabricate `.arb` entries to fill this gap.

### HR Packet Parser Quirks
`HrPacketParser.parseRawBytes` reads BLE `0x2A37` characteristic data — these rules are load-bearing for correctness, handle with care:
- Sensor contact status: Bit 2 (`0x04`) = supported, Bit 1 (`0x02`) = active. If `0x04` is off, `sensorContactActive` MUST be `null` regardless of Bit 1.
- R-R intervals are raw `uint16` values divided by 1024 to get seconds.
- 16-bit BPM is little-endian.

### Key Constraints
- **Isar initialization:** Always use `Isar.getInstance() ?? await Isar.open(...)` to prevent dual-open errors.
- **No `dart:math` imports** unless the file genuinely uses math functions (not just `max`/`min` on collections — use `fold` or direct comparison instead).

### Lifecycle & Resource Disposal Checklist
Before considering any feature involving streams, timers, animations, or BLE connections complete, verify:
- Every `StreamSubscription` is cancelled in `dispose()` or the corresponding Notifier's `ref.onDispose()`.
- Every `Timer`/`AnimationController` is cancelled/disposed the same way.
- BLE connections/scans (`flutter_blue_plus`) are explicitly stopped on dispose, not left running when the widget/notifier is torn down.
- App lifecycle transitions (`AppLifecycleState.paused`/`detached`) are handled explicitly where background tasks (`flutter_foreground_task`) are involved — verify the task is paused/stopped appropriately, not left orphaned.

### Testing Conventions
- Tests live in `test/`, mirroring the `lib/` structure.
- Run with `flutter test` (or `flutter test --exclude-tags golden` to skip golden tests).

### CI
`.github/workflows/ci.yml` runs on push/PR to `main`. Caches `~/.pub-cache` and `.dart_tool/`, keyed on the `pubspec.lock` hash.

### Mandatory Verification Pipeline
After any modification within the `lib/**` directory, you MUST execute the following pipeline in strict order (matches `before_push.sh`):
1. `dart run build_runner build --delete-conflicting-outputs`
2. `dart format --output=none --set-exit-if-changed .`
3. `flutter analyze`
4. `dart run custom_lint`
5. `flutter test --exclude-tags golden`

A task is NOT considered complete until all steps pass with zero errors and zero failing tests, AND the Lifecycle & Resource Disposal Checklist above has been explicitly verified. Fix any arising issues autonomously, subject to the Guardrails above.