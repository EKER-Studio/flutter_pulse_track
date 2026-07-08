import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/todo.dart';
import 'todo_repository_provider.dart';

part 'todo_notifier.g.dart';

@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    final completer = Completer<List<Todo>>();

    final subscription = repository.watchAll().listen(
      (todos) {
        if (!completer.isCompleted) {
          completer.complete(todos);
        }
        state = AsyncData(todos);
      },
      onError: (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        state = AsyncError(error, stackTrace);
      },
    );

    ref.onDispose(subscription.cancel);

    return completer.future;
  }

  Future<void> addTodo(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    try {
      await ref.read(todoRepositoryProvider).add(title: trimmedTitle);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> toggleTodo(int id) async {
    try {
      await ref.read(todoRepositoryProvider).toggleCompleted(id: id);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await ref.read(todoRepositoryProvider).delete(id: id);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
