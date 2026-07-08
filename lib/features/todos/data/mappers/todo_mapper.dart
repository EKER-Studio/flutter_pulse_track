import '../../domain/entities/todo.dart';
import '../models/todo_model.dart';
import 'category_mapper.dart';

extension TodoModelMapper on TodoModel {
  /// Converts this model to a domain [Todo].
  ///
  /// **Precondition**: `await model.category.load()` must be called before
  /// invoking this method. The repository is responsible for satisfying this
  /// contract; the mapper itself performs no I/O.
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
      category: category.value?.toEntity(),
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
    // Note: the IsarLink is managed separately by the repository
    // to keep writes explicit (see TodoRepositoryImpl).
  }
}
