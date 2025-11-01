import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String? id; // 🔹 Thêm ID để thao tác với Firebase

  @HiveField(1)
  String title;

  @HiveField(2)
  String categoryImage;

  @HiveField(3)
  String type; // "Income" hoặc "Expense"

  CategoryModel({
    this.id,
    required this.title,
    required this.categoryImage,
    required this.type,
  });

  // 🔸 Dùng cho Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryImage': categoryImage,
      'type': type,
    };
  }

  // 🔸 Tạo từ dữ liệu Firebase
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      categoryImage: json['categoryImage'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}
