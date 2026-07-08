import 'package:isar_community/isar.dart';

import 'category_model.dart';

part 'todo_model.g.dart';

@collection
class TodoModel {
  Id id = Isar.autoIncrement;

  late String title;

  bool isCompleted = false;

  late DateTime createdAt;

  /// Optional link to a category. Load with `await category.load()` before reading `.value`.
  final category = IsarLink<CategoryModel>();
}
