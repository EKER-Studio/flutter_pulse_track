import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_boilerplate/app.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/presentation/providers/user_preferences_repository_provider.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';

// Używamy FakeTodoRepository, podobnie jak w widget testach, by wstrzyknąć stałe dane.
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
        createdAt: DateTime(
          2025,
          1,
          1,
          10,
          0,
        ), // Zamrożona data, aby Golden Test był deterministyczny
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

class FakeUserPreferencesRepository implements UserPreferencesRepository {
  final _preferences = UserPreferences.defaults();

  @override
  Stream<UserPreferences> watch() async* {
    yield _preferences;
  }

  @override
  Future<UserPreferences> get() async {
    return _preferences;
  }

  @override
  Future<void> updateThemeMode(UserThemeMode themeMode) async {}

  @override
  Future<void> updateNotificationsEnabled(bool isEnabled) async {}
}

void main() {
  late FakeTodoRepository repository;
  late FakeUserPreferencesRepository userPreferencesRepository;

  setUp(() {
    repository = FakeTodoRepository();
    userPreferencesRepository = FakeUserPreferencesRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('Todo Screen Golden Tests', () {
    testWidgets('Initial empty state', (tester) async {
      // 1. Zamrożenie wymiarów ekranu (np. klasyczny profil telefonu, 1080x2400)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      // 2. Budowanie widgetu ze wstrzykniętym fake repo
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(repository),
            userPreferencesRepositoryProvider.overrideWithValue(
              userPreferencesRepository,
            ),
          ],
          child: const App(),
        ),
      );

      // 3. Oczekiwanie na ustabilizowanie się klatek (wszystkie ładowania zakończone)
      await tester.pumpAndSettle();

      // 4. Porównanie wyrenderowanego piksela do pliku referencyjnego
      await expectLater(
        find.byType(App),
        matchesGoldenFile('goldens/todo_screen_empty.png'),
      );

      // Sprzątanie po teście
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Populated list state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      // Dodanie deterministycznego zadania
      await repository.add(title: 'Napisz dokumentację');
      await repository.add(title: 'Przetestuj aplikację');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(repository),
            userPreferencesRepositoryProvider.overrideWithValue(
              userPreferencesRepository,
            ),
          ],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(App),
        matchesGoldenFile('goldens/todo_screen_populated.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
