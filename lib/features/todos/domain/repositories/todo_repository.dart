import '../entities/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> watchAll();

  Stream<Todo?> watchById(int id);

  Future<List<Todo>> getAll();

  Future<void> add({required String title});

  Future<void> toggleCompleted({required int id});

  Future<void> delete({required int id});
}
