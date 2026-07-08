class Category {
  const Category({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final int id;

  /// Display name of the category, e.g. "Work", "Personal".
  final String name;

  /// ARGB hex color string, e.g. "FF6200EE".
  final String colorHex;

  Category copyWith({int? id, String? name, String? colorHex}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Category &&
            other.id == id &&
            other.name == name &&
            other.colorHex == colorHex;
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex);
}
