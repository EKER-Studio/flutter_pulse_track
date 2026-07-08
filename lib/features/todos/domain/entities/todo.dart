import 'category.dart';

class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    this.category,
  });

  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  /// Optional category this todo belongs to.
  /// Null when the todo has not been assigned to any category.
  final Category? category;

  Todo copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    // Use a sentinel to distinguish "pass null explicitly" from "keep current value".
    Object? category = _sentinel,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      category: category == _sentinel ? this.category : category as Category?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            other.id == id &&
            other.title == title &&
            other.isCompleted == isCompleted &&
            other.createdAt == createdAt &&
            other.category == category;
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted, createdAt, category);
}

// Private sentinel used by copyWith to distinguish "omitted" from explicit null.
const Object _sentinel = Object();
