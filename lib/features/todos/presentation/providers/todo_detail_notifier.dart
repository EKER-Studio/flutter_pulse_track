import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/todo.dart';
import 'todo_repository_provider.dart';

part 'todo_detail_notifier.g.dart';

@riverpod
class TodoDetail extends _$TodoDetail {
  @override
  Future<Todo?> build(int id) async {
    final repository = ref.watch(todoRepositoryProvider);
    final completer = Completer<Todo?>();

    final subscription = repository
        .watchById(id)
        .listen(
          (todo) {
            if (!completer.isCompleted) {
              completer.complete(todo);
            }
            state = AsyncData(todo);
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
}
