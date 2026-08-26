# Flutter/Dart & Riverpod Code Style (Continue supplemental rules)

These rules supplement AGENTS.md (SSOT). If there is any conflict, AGENTS.md wins.

## Architecture & Layer Boundaries
- Feature-First Clean Architecture under `lib/features/<feature>/{domain,data,presentation}/`.
- **Domain Layer** (`lib/features/<feature>/domain/`): Pure Dart (entities, repository interfaces, use cases). NO Flutter or Riverpod imports allowed.
- **Data Layer** (`lib/features/<feature>/data/`): Repository implementations, Isar models, and synchronous mappers (extensions).
- **Presentation Layer** (`lib/features/<feature>/presentation/`): UI (`ConsumerWidget`) and state management via Riverpod 3.x generators (`@riverpod`).

## State Management (Riverpod 3.x)
- Strictly use `@riverpod` code generation — never manual state mutation in CRUD methods.
- State is **stream-driven**: notifiers listen to Isar collections and pipe directly into `AsyncValue`.
- Single source of truth: screens subscribe by ID via `.family(id)` providers.
- Always use `ref.onDispose()` to cancel `StreamSubscription`, `Timer`, or any controller resources.

## Dart & Language Conventions
- Keep code compliant with `dart format`.
- Prefer explicit types in public APIs; avoid `dynamic`.
- Use Dart 3.12+ features (records, patterns, class modifiers) instead of Freezed/Equatable.
- Documentation: For every public class/method, add a doc comment following standard DartDoc convention.

## Widgets and UI
- Extend `ConsumerWidget` or `ConsumerStatefulWidget` for presentation widgets consuming providers.
- Keep widgets small; if `build()` grows, extract private widgets/methods.
- Use `const` constructors where possible.
- Do not perform heavy work or I/O inside `build()`.
- Rely on `Theme.of(context)` and the project design system.

## Testing
- Unit tests for notifier state transitions, CRUD logic, and subscription cancellation.
- Widget tests with fake repositories injected via `ProviderContainer` / `ProviderScope.overrides`.
- Tests must be deterministic (avoid real timers/delays unless required).
