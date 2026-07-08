import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String name;

  /// ARGB hex color string, e.g. "FF6200EE".
  late String colorHex;
}
