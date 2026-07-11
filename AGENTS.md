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

### Guardrails
- NEVER delete, skip, or weaken a test to make the verification pipeline pass. Fix the underlying code instead.
- NEVER add lint-suppression comments (e.g. `// ignore:`) or disable analyzer/linter rules to silence errors, unless explicitly instructed.
- If a fix is not obvious after 2 attempts, stop and report the exact error instead of applying a workaround.

### Formatting & Style
- Follow the official style guide / formatter for the language in use (e.g. `dart format .`).
- Ensure all generated files are correctly linked/imported per the framework's conventions (e.g. `part 'filename.g.dart';` for Dart build_runner output).

---

## Project Stack: ble_heart_rate_monitor
*(Replace this whole section when starting a new project with a different stack.)*

### Build & Generation Commands
- Install dependencies: `flutter pub get`
- Run build runner: `dart run build_runner build --delete-conflicting-outputs`
- Watch build runner: `dart run build_runner watch --delete-conflicting-outputs`
- Code analysis: `flutter analyze`
- Lint (Riverpod-specific): `dart run custom_lint` *(remove this line once confirmed redundant with `flutter analyze` in this project's `analysis_options.yaml`)*
- Run tests: `flutter test`

### Architecture & State Management
This is a Local-First, AI-Native boilerplate utilizing Clean Architecture under a Feature-First approach.
- **State Management:** Riverpod 3.x strictly.
- **Data Flow:** UI (`ConsumerWidget`) -> Notifier (`@riverpod`) -> Repository Interface (`domain`) -> Repository Impl (`data`) -> Local DB (`isar_community`).
- **Reactivity:** Handled purely via Isar streams. Notifiers listen to Isar collections and pipe data directly into `AsyncValue` state.

### Mandatory Verification Pipeline
After any modification within the `lib/**` directory, you MUST execute the following pipeline in strict order:
1. `dart run build_runner build --delete-conflicting-outputs`
2. `flutter analyze`
3. `dart run custom_lint` *(see note above — drop if redundant)*
4. `flutter test`

A task is NOT considered complete until all steps pass with zero errors and zero failing tests. Fix any arising issues autonomously, subject to the Guardrails above.
