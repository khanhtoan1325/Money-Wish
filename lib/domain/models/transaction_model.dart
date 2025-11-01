import 'package:hive/hive.dart';
import 'category_model.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  CategoryModel category;

  @HiveField(1)
  String notes;

  @HiveField(2)
  String amount;

  @HiveField(3)
  String type; // Income hoặc Expense

  @HiveField(4)
  DateTime createAt;

  Transaction(
    this.type,
    this.amount,
    this.createAt,
    this.notes,
    this.category,
  );

  // ✅ Bổ sung copyWith để hỗ trợ update transaction
  Transaction copyWith({
    CategoryModel? category,
    String? notes,
    String? amount,
    String? type,
    DateTime? createAt,
  }) {
    return Transaction(
      type ?? this.type,
      amount ?? this.amount,
      createAt ?? this.createAt,
      notes ?? this.notes,
      category ?? this.category,
    );
  }

  // ✅ Chuyển sang JSON (để lưu lên Firebase)
  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(), // ✅ Đồng bộ với CategoryModel mới
      'notes': notes,
      'amount': amount,
      'type': type,
      'createAt': createAt.toIso8601String(),
    };
  }

  // ✅ Tạo Transaction từ JSON (Firebase → App)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'] != null
        ? Map<String, dynamic>.from(json['category'])
        : {};

    return Transaction(
      json['type'] as String? ?? '',
      json['amount'] as String? ?? '0',
      DateTime.tryParse(json['createAt'] ?? '') ?? DateTime.now(),
      json['notes'] as String? ?? '',
      CategoryModel.fromJson(Map<String, dynamic>.from(categoryData)),
    );
  }
}

// 🔹 Lớp phụ để chứa Transaction có id (Firebase Realtime Database)
class TransactionWithId {
  final String id;
  final Transaction transaction;

  TransactionWithId({
    required this.id,
    required this.transaction,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        ...transaction.toJson(),
      };

  factory TransactionWithId.fromJson(String id, Map<String, dynamic> json) {
    return TransactionWithId(
      id: id,
      transaction: Transaction.fromJson(json),
    );
  }
}
