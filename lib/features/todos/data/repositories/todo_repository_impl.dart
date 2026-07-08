import 'package:isar_community/isar.dart';

import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../mappers/todo_mapper.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._isar);

  final Isar _isar;

  /// Loads the [IsarLink] relation on [model] and converts it to a domain [Todo].
  ///
  /// This is the single place where the "load before map" contract is satisfied.
  /// All read paths go through this helper so the mapper remains free of I/O.
  Future<Todo> _loadAndMap(TodoModel model) async {
    await model.category.load();
    return model.toEntity();
  }

  @override
  Stream<List<Todo>> watchAll() {
    return _isar.todoModels
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        // asyncMap is required here: unlike map(), it awaits the Future returned
        // by _loadAndMap before emitting the next value, so the stream always
        // carries fully-hydrated domain entities.
        .asyncMap((models) => Future.wait(models.map(_loadAndMap)));
  }

  @override
  Stream<Todo?> watchById(int id) {
    return _isar.todoModels
        .watchObject(id, fireImmediately: true)
        .asyncMap(
          (model) => model != null ? _loadAndMap(model) : Future.value(null),
        );
  }

  @override
  Future<List<Todo>> getAll() async {
    final models = await _isar.todoModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    // Load all links in parallel for efficiency.
    return Future.wait(models.map(_loadAndMap));
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
