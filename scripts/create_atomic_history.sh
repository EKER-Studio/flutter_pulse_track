#!/usr/bin/env bash
set -euo pipefail

# Rebuilds a compile-safe, chronological Git history for this Flutter project.
#
# Intended workflow:
#   1. Save the final project state on a side branch, for example:
#        git branch final-state
#   2. Create/switch to a clean target branch where the history should be built.
#   3. Run:
#        FINAL_REF=final-state bash scripts/create_atomic_history.sh
#
# The script intentionally writes transitional source files before restoring
# final versions later in the timeline. This keeps every checkout compile-safe.

FINAL_REF="${FINAL_REF:-final-state}"
ROOT_DIR="$(git rev-parse --show-toplevel)"
SCRIPT_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_SOURCE="$SCRIPT_SOURCE_DIR/$(basename "${BASH_SOURCE[0]}")"
TARGET_SCRIPT="$ROOT_DIR/scripts/create_atomic_history.sh"
cd "$ROOT_DIR"

require_clean_worktree() {
  if ! git diff --quiet; then
    echo "Working tree has unstaged tracked changes. Commit or discard them before running this script." >&2
    exit 1
  fi

  if ! git diff --cached --quiet; then
    echo "The index has staged changes. Commit or unstage them before running this script." >&2
    exit 1
  fi
}

require_final_ref() {
  if ! git rev-parse --verify --quiet "$FINAL_REF^{commit}" >/dev/null; then
    echo "FINAL_REF '$FINAL_REF' does not exist. Create a side branch with the final project state first." >&2
    exit 1
  fi
}

write_file() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  cat >"$path"
}

restore_from_final() {
  git checkout "$FINAL_REF" -- "$@"
}

run_codegen() {
  dart run build_runner build --delete-conflicting-outputs
}

format_dart() {
  dart format "$@"
}

install_self() {
  mkdir -p "$(dirname "$TARGET_SCRIPT")"

  if [[ "$SCRIPT_SOURCE" != "$TARGET_SCRIPT" ]]; then
    cp "$SCRIPT_SOURCE" "$TARGET_SCRIPT"
  fi

  chmod +x "$TARGET_SCRIPT"
}

commit_paths() {
  local commit_date="$1"
  local commit_message="$2"
  shift 2

  local missing=()
  local path

  for path in "$@"; do
    if [[ ! -e "$path" ]]; then
      missing+=("$path")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    echo "Missing paths for commit '$commit_message':" >&2
    printf '  - %s\n' "${missing[@]}" >&2
    exit 1
  fi

  git add -- "$@"

  if git diff --cached --quiet; then
    echo "Skipping empty commit: $commit_message"
    return
  fi

  GIT_AUTHOR_DATE="$commit_date" \
  GIT_COMMITTER_DATE="$commit_date" \
    git commit --date="$commit_date" -m "$commit_message"
}

require_clean_worktree
require_final_ref

# ---------------------------------------------------------------------------
# Day 1 - Skeleton app and project configuration.
# ---------------------------------------------------------------------------
restore_from_final \
  ".cursorrules" \
  ".gitignore" \
  ".metadata" \
  "AGENTS.md" \
  "CLAUDE.md" \
  "analysis_options.yaml" \
  "pubspec.yaml" \
  "pubspec.lock" \
  "android" \
  "ios" \
  "linux" \
  "macos" \
  "web" \
  "windows"

write_file "lib/app.dart" <<'DART'
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Todo App')),
      ),
    );
  }
}
DART

write_file "lib/main.dart" <<'DART'
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  runApp(const App());
}
DART

format_dart "lib/app.dart" "lib/main.dart"
commit_paths "2026-06-23T09:12:00" "chore(config): initialize Flutter project scaffold" \
  ".cursorrules" \
  ".gitignore" \
  ".metadata" \
  "AGENTS.md" \
  "CLAUDE.md" \
  "analysis_options.yaml" \
  "pubspec.yaml" \
  "pubspec.lock" \
  "android" \
  "ios" \
  "linux" \
  "macos" \
  "web" \
  "windows" \
  "lib/app.dart" \
  "lib/main.dart"

# ---------------------------------------------------------------------------
# Day 2 - Todo domain without category dependency.
# ---------------------------------------------------------------------------
write_file "lib/features/todos/domain/entities/todo.dart" <<'DART'
class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  Todo copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            other.id == id &&
            other.title == title &&
            other.isCompleted == isCompleted &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted, createdAt);
}
DART

restore_from_final "lib/features/todos/domain/repositories/todo_repository.dart"
format_dart \
  "lib/features/todos/domain/entities/todo.dart" \
  "lib/features/todos/domain/repositories/todo_repository.dart"
commit_paths "2026-06-24T10:05:00" "feat(todos): add domain entity and repository contract" \
  "lib/features/todos/domain/entities/todo.dart" \
  "lib/features/todos/domain/repositories/todo_repository.dart"

# ---------------------------------------------------------------------------
# Day 3 - Todo Isar model and mapper without category relation.
# ---------------------------------------------------------------------------
write_file "lib/features/todos/data/models/todo_model.dart" <<'DART'
import 'package:isar_community/isar.dart';

part 'todo_model.g.dart';

@collection
class TodoModel {
  Id id = Isar.autoIncrement;

  late String title;

  bool isCompleted = false;

  late DateTime createdAt;
}
DART

write_file "lib/features/todos/data/mappers/todo_mapper.dart" <<'DART'
import '../../domain/entities/todo.dart';
import '../models/todo_model.dart';

extension TodoModelMapper on TodoModel {
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }
}

extension TodoEntityMapper on Todo {
  TodoModel toModel() {
    return TodoModel()
      ..id = id
      ..title = title
      ..isCompleted = isCompleted
      ..createdAt = createdAt;
  }
}
DART

format_dart \
  "lib/features/todos/data/models/todo_model.dart" \
  "lib/features/todos/data/mappers/todo_mapper.dart"
run_codegen
commit_paths "2026-06-25T09:42:00" "feat(todos): add Isar todo model and synchronous mapper" \
  "lib/features/todos/data/models/todo_model.dart" \
  "lib/features/todos/data/models/todo_model.g.dart" \
  "lib/features/todos/data/mappers/todo_mapper.dart"

# ---------------------------------------------------------------------------
# Day 4 - Todo repository with all I/O isolated in data layer.
# ---------------------------------------------------------------------------
restore_from_final \
  "lib/core/providers/isar_provider.dart" \
  "lib/features/todos/presentation/providers/todo_repository_provider.dart"

write_file "lib/features/todos/data/repositories/todo_repository_impl.dart" <<'DART'
import 'package:isar_community/isar.dart';

import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../mappers/todo_mapper.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Stream<List<Todo>> watchAll() {
    return _isar.todoModels
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<Todo?> watchById(int id) {
    return _isar.todoModels
        .watchObject(id, fireImmediately: true)
        .map((model) => model?.toEntity());
  }

  @override
  Future<List<Todo>> getAll() async {
    final models = await _isar.todoModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> add({required String title}) async {
    final model = TodoModel()
      ..title = title.trim()
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.todoModels.put(model);
    });
  }

  @override
  Future<void> toggleCompleted({required int id}) async {
    await _isar.writeTxn(() async {
      final model = await _isar.todoModels.get(id);
      if (model == null) {
        return;
      }

      model.isCompleted = !model.isCompleted;
      await _isar.todoModels.put(model);
    });
  }

  @override
  Future<void> delete({required int id}) async {
    await _isar.writeTxn(() async {
      await _isar.todoModels.delete(id);
    });
  }
}
DART

format_dart \
  "lib/core/providers/isar_provider.dart" \
  "lib/features/todos/data/repositories/todo_repository_impl.dart" \
  "lib/features/todos/presentation/providers/todo_repository_provider.dart"
run_codegen
commit_paths "2026-06-26T11:18:00" "feat(todos): implement local Isar repository" \
  "lib/core/providers/isar_provider.dart" \
  "lib/core/providers/isar_provider.g.dart" \
  "lib/features/todos/data/repositories/todo_repository_impl.dart" \
  "lib/features/todos/presentation/providers/todo_repository_provider.dart" \
  "lib/features/todos/presentation/providers/todo_repository_provider.g.dart"

# ---------------------------------------------------------------------------
# Day 5 - Todo list notifier and unit tests, still category-free.
# ---------------------------------------------------------------------------
restore_from_final "lib/features/todos/presentation/providers/todo_notifier.dart"

write_file "test/features/todos/presentation/providers/todo_notifier_test.dart" <<'DART'
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_notifier.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

const _tId = 1;
final _tCreatedAt = DateTime(2024, 1, 1);
final _tTodo = Todo(
  id: _tId,
  title: 'Test Todo',
  isCompleted: false,
  createdAt: _tCreatedAt,
);
final _tTodos = [_tTodo];

ProviderContainer _makeContainer(MockTodoRepository mock) {
  return ProviderContainer(
    overrides: [todoRepositoryProvider.overrideWithValue(mock)],
  );
}

void main() {
  late MockTodoRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockTodoRepository();
  });

  tearDown(() {
    container.dispose();
  });

  group('TodoList Notifier - build()', () {
    test('returns list from the first stream event', () async {
      when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value(_tTodos));

      container = _makeContainer(mockRepo);

      final result = await container.read(todoListProvider.future);

      expect(result, _tTodos);
      verify(() => mockRepo.watchAll()).called(1);
      verifyNever(() => mockRepo.getAll());
    });

    test('state becomes AsyncData on every new stream event', () async {
      final controller = StreamController<List<Todo>>();
      when(() => mockRepo.watchAll()).thenAnswer((_) => controller.stream);

      container = _makeContainer(mockRepo);

      final updatedTodo = _tTodo.copyWith(title: 'Updated');
      controller.add(_tTodos);
      await container.read(todoListProvider.future);

      controller.add([updatedTodo]);
      await Future.microtask(() {});

      final state = container.read(todoListProvider);
      expect(state, isA<AsyncData<List<Todo>>>());
      expect(state.value, [updatedTodo]);

      await controller.close();
    });
  });
}
DART

format_dart \
  "lib/features/todos/presentation/providers/todo_notifier.dart" \
  "test/features/todos/presentation/providers/todo_notifier_test.dart"
run_codegen
commit_paths "2026-06-29T09:30:00" "feat(todos): add reactive todo list notifier" \
  "lib/features/todos/presentation/providers/todo_notifier.dart" \
  "lib/features/todos/presentation/providers/todo_notifier.g.dart" \
  "test/features/todos/presentation/providers/todo_notifier_test.dart"

# ---------------------------------------------------------------------------
# Day 6 - Category integration and final Todo relation mapping.
# ---------------------------------------------------------------------------
restore_from_final \
  "lib/features/todos/domain/entities/todo.dart" \
  "lib/features/todos/domain/entities/category.dart" \
  "lib/features/todos/data/models/todo_model.dart" \
  "lib/features/todos/data/models/category_model.dart" \
  "lib/features/todos/data/mappers/todo_mapper.dart" \
  "lib/features/todos/data/mappers/category_mapper.dart" \
  "lib/features/todos/data/repositories/todo_repository_impl.dart"

format_dart \
  "lib/features/todos/domain/entities/todo.dart" \
  "lib/features/todos/domain/entities/category.dart" \
  "lib/features/todos/data/models/todo_model.dart" \
  "lib/features/todos/data/models/category_model.dart" \
  "lib/features/todos/data/mappers/todo_mapper.dart" \
  "lib/features/todos/data/mappers/category_mapper.dart" \
  "lib/features/todos/data/repositories/todo_repository_impl.dart"
run_codegen
commit_paths "2026-06-30T10:14:00" "feat(todos): add category relation mapping" \
  "lib/features/todos/domain/entities/todo.dart" \
  "lib/features/todos/domain/entities/category.dart" \
  "lib/features/todos/data/models/todo_model.dart" \
  "lib/features/todos/data/models/todo_model.g.dart" \
  "lib/features/todos/data/models/category_model.dart" \
  "lib/features/todos/data/models/category_model.g.dart" \
  "lib/features/todos/data/mappers/todo_mapper.dart" \
  "lib/features/todos/data/mappers/category_mapper.dart" \
  "lib/features/todos/data/repositories/todo_repository_impl.dart"

# ---------------------------------------------------------------------------
# Day 7 - Todo detail logic and UI without settings navigation.
# ---------------------------------------------------------------------------
restore_from_final \
  "lib/features/todos/presentation/providers/todo_detail_notifier.dart" \
  "lib/features/todos/presentation/screens/todo_screen_detail.dart" \
  "lib/features/todos/presentation/widgets/add_todo_fab.dart" \
  "lib/features/todos/presentation/widgets/todo_list_item.dart" \
  "test/features/todos/presentation/providers/todo_notifier_test.dart"

write_file "lib/app.dart" <<'DART'
import 'package:flutter/material.dart';

import 'features/todos/presentation/screens/todo_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}
DART

write_file "lib/main.dart" <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/providers/isar_provider.dart';
import 'features/todos/data/models/category_model.dart';
import 'features/todos/data/models/todo_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    TodoModelSchema,
    CategoryModelSchema,
  ], directory: directory.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const App(),
    ),
  );
}
DART

write_file "lib/features/todos/presentation/screens/todo_screen.dart" <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_notifier.dart';
import '../widgets/add_todo_fab.dart';
import '../widgets/todo_list_item.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zadania')),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nie udało się załadować zadań',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(todoListProvider),
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
        data: (todos) {
          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Brak zadań',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dodaj pierwsze zadanie przyciskiem poniżej',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: todos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoListItem(
                todo: todo,
                onToggle: () =>
                    ref.read(todoListProvider.notifier).toggleTodo(todo.id),
                onDelete: () =>
                    ref.read(todoListProvider.notifier).deleteTodo(todo.id),
              );
            },
          );
        },
      ),
      floatingActionButton: AddTodoFab(
        onAdd: (title) => ref.read(todoListProvider.notifier).addTodo(title),
      ),
    );
  }
}
DART

format_dart \
  "lib/app.dart" \
  "lib/main.dart" \
  "lib/features/todos/presentation/providers/todo_detail_notifier.dart" \
  "lib/features/todos/presentation/screens/todo_screen.dart" \
  "lib/features/todos/presentation/screens/todo_screen_detail.dart" \
  "lib/features/todos/presentation/widgets/add_todo_fab.dart" \
  "lib/features/todos/presentation/widgets/todo_list_item.dart" \
  "test/features/todos/presentation/providers/todo_notifier_test.dart"
run_codegen
commit_paths "2026-07-01T09:20:00" "feat(todos): add detail notifier and todo screens" \
  "lib/app.dart" \
  "lib/main.dart" \
  "lib/features/todos/presentation/providers/todo_detail_notifier.dart" \
  "lib/features/todos/presentation/providers/todo_detail_notifier.g.dart" \
  "lib/features/todos/presentation/screens/todo_screen.dart" \
  "lib/features/todos/presentation/screens/todo_screen_detail.dart" \
  "lib/features/todos/presentation/widgets/add_todo_fab.dart" \
  "lib/features/todos/presentation/widgets/todo_list_item.dart" \
  "test/features/todos/presentation/providers/todo_notifier_test.dart"

# ---------------------------------------------------------------------------
# Day 8 - Todo widget and golden tests against the Day 7 UI.
# ---------------------------------------------------------------------------
write_file "test/widget_test.dart" <<'DART'
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_boilerplate/app.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';

class FakeTodoRepository implements TodoRepository {
  final List<Todo> _todos = [];
  final _streamController = StreamController<List<Todo>>.broadcast();

  void _emit() {
    _streamController.add(List.unmodifiable(_todos));
  }

  @override
  Stream<List<Todo>> watchAll() async* {
    yield List.unmodifiable(_todos);
    yield* _streamController.stream;
  }

  @override
  Stream<Todo?> watchById(int id) async* {
    yield _todos
        .where((todo) => todo.id == id)
        .cast<Todo?>()
        .firstWhere((_) => true, orElse: () => null);
    yield* _streamController.stream.map(
      (todos) => todos
          .where((todo) => todo.id == id)
          .cast<Todo?>()
          .firstWhere((_) => true, orElse: () => null),
    );
  }

  @override
  Future<List<Todo>> getAll() async {
    return List.unmodifiable(_todos);
  }

  @override
  Future<void> add({required String title}) async {
    _todos.insert(
      0,
      Todo(
        id: _todos.length + 1,
        title: title,
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    );
    _emit();
  }

  @override
  Future<void> toggleCompleted({required int id}) async {}

  @override
  Future<void> delete({required int id}) async {}

  void dispose() {
    _streamController.close();
  }
}

void main() {
  late FakeTodoRepository repository;

  setUp(() {
    repository = FakeTodoRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  testWidgets('Todo screen loads and allows adding a task', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWithValue(repository)],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Brak zadań'), findsOneWidget);

    await tester.tap(find.text('Dodaj'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Kup mleko');
    await tester.tap(find.widgetWithText(FilledButton, 'Dodaj'));
    await tester.pumpAndSettle();

    expect(find.text('Kup mleko'), findsOneWidget);
    expect(find.text('Brak zadań'), findsNothing);
  });
}
DART

write_file "test/features/todos/presentation/screens/todo_screen_golden_test.dart" <<'DART'
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_boilerplate/app.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';

class FakeTodoRepository implements TodoRepository {
  final List<Todo> _todos = [];
  final _streamController = StreamController<List<Todo>>.broadcast();

  void _emit() {
    _streamController.add(List.unmodifiable(_todos));
  }

  @override
  Stream<List<Todo>> watchAll() async* {
    yield List.unmodifiable(_todos);
    yield* _streamController.stream;
  }

  @override
  Stream<Todo?> watchById(int id) async* {
    yield _todos
        .where((todo) => todo.id == id)
        .cast<Todo?>()
        .firstWhere((_) => true, orElse: () => null);
  }

  @override
  Future<List<Todo>> getAll() async {
    return List.unmodifiable(_todos);
  }

  @override
  Future<void> add({required String title}) async {
    _todos.insert(
      0,
      Todo(
        id: _todos.length + 1,
        title: title,
        isCompleted: false,
        createdAt: DateTime(2025, 1, 1, 10),
      ),
    );
    _emit();
  }

  @override
  Future<void> toggleCompleted({required int id}) async {}

  @override
  Future<void> delete({required int id}) async {}

  void dispose() {
    _streamController.close();
  }
}

void main() {
  late FakeTodoRepository repository;

  setUp(() {
    repository = FakeTodoRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('Todo Screen Golden Tests', () {
    testWidgets('Initial empty state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(repository)],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(App),
        matchesGoldenFile('goldens/todo_screen_empty.png'),
      );
    });

    testWidgets('Populated list state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await repository.add(title: 'Napisz dokumentację');
      await repository.add(title: 'Przetestuj aplikację');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(repository)],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(App),
        matchesGoldenFile('goldens/todo_screen_populated.png'),
      );
    });
  });
}
DART

format_dart \
  "test/widget_test.dart" \
  "test/features/todos/presentation/screens/todo_screen_golden_test.dart"
flutter test --update-goldens test/features/todos/presentation/screens/todo_screen_golden_test.dart
commit_paths "2026-07-01T15:45:00" "test(todos): add widget and golden coverage" \
  "test/widget_test.dart" \
  "test/features/todos/presentation/screens/todo_screen_golden_test.dart" \
  "test/features/todos/presentation/screens/goldens/todo_screen_empty.png" \
  "test/features/todos/presentation/screens/goldens/todo_screen_populated.png"

# ---------------------------------------------------------------------------
# Day 9 - Settings domain, singleton Isar model, mapper and repository.
# ---------------------------------------------------------------------------
restore_from_final \
  "lib/features/settings/domain/entities/user_preferences.dart" \
  "lib/features/settings/domain/repositories/user_preferences_repository.dart" \
  "lib/features/settings/data/models/user_preferences_model.dart" \
  "lib/features/settings/data/mappers/user_preferences_mapper.dart" \
  "lib/features/settings/data/repositories/user_preferences_repository_impl.dart"

format_dart \
  "lib/features/settings/domain/entities/user_preferences.dart" \
  "lib/features/settings/domain/repositories/user_preferences_repository.dart" \
  "lib/features/settings/data/models/user_preferences_model.dart" \
  "lib/features/settings/data/mappers/user_preferences_mapper.dart" \
  "lib/features/settings/data/repositories/user_preferences_repository_impl.dart"
run_codegen
commit_paths "2026-07-02T09:10:00" "feat(settings): add user preferences domain and Isar model" \
  "lib/features/settings/domain/entities/user_preferences.dart" \
  "lib/features/settings/domain/repositories/user_preferences_repository.dart" \
  "lib/features/settings/data/models/user_preferences_model.dart" \
  "lib/features/settings/data/models/user_preferences_model.g.dart" \
  "lib/features/settings/data/mappers/user_preferences_mapper.dart" \
  "lib/features/settings/data/repositories/user_preferences_repository_impl.dart"

# ---------------------------------------------------------------------------
# Day 10 - Final settings UI integration, app theme wiring and documentation.
# ---------------------------------------------------------------------------
restore_from_final \
  "lib/app.dart" \
  "lib/main.dart" \
  "lib/features/todos/presentation/screens/todo_screen.dart" \
  "lib/features/settings/presentation/providers/user_preferences_repository_provider.dart" \
  "lib/features/settings/presentation/providers/user_preferences_notifier.dart" \
  "lib/features/settings/presentation/screens/settings_screen.dart" \
  "test/widget_test.dart" \
  "test/features/todos/presentation/screens/todo_screen_golden_test.dart" \
  "test/features/settings/presentation/providers/user_preferences_notifier_test.dart" \
  "test/features/settings/presentation/screens/settings_screen_test.dart" \
  "test/features/settings/presentation/screens/settings_screen_golden_test.dart" \
  "README.md"

format_dart \
  "lib/app.dart" \
  "lib/main.dart" \
  "lib/features/todos/presentation/screens/todo_screen.dart" \
  "lib/features/settings/presentation/providers/user_preferences_repository_provider.dart" \
  "lib/features/settings/presentation/providers/user_preferences_notifier.dart" \
  "lib/features/settings/presentation/screens/settings_screen.dart" \
  "test/widget_test.dart" \
  "test/features/todos/presentation/screens/todo_screen_golden_test.dart" \
  "test/features/settings/presentation/providers/user_preferences_notifier_test.dart" \
  "test/features/settings/presentation/screens/settings_screen_test.dart" \
  "test/features/settings/presentation/screens/settings_screen_golden_test.dart"
run_codegen
flutter test --update-goldens
install_self
commit_paths "2026-07-02T16:35:00" "feat(settings): wire preferences UI and documentation" \
  "lib/app.dart" \
  "lib/main.dart" \
  "lib/features/todos/presentation/screens/todo_screen.dart" \
  "lib/features/settings/presentation/providers/user_preferences_repository_provider.dart" \
  "lib/features/settings/presentation/providers/user_preferences_repository_provider.g.dart" \
  "lib/features/settings/presentation/providers/user_preferences_notifier.dart" \
  "lib/features/settings/presentation/providers/user_preferences_notifier.g.dart" \
  "lib/features/settings/presentation/screens/settings_screen.dart" \
  "test/widget_test.dart" \
  "test/features/todos/presentation/screens/todo_screen_golden_test.dart" \
  "test/features/todos/presentation/screens/goldens/todo_screen_empty.png" \
  "test/features/todos/presentation/screens/goldens/todo_screen_populated.png" \
  "test/features/settings/presentation/providers/user_preferences_notifier_test.dart" \
  "test/features/settings/presentation/screens/settings_screen_test.dart" \
  "test/features/settings/presentation/screens/settings_screen_golden_test.dart" \
  "test/features/settings/presentation/screens/goldens/settings_screen_dark.png" \
  "README.md" \
  "scripts/create_atomic_history.sh"

echo "Compile-safe atomic history script completed."
