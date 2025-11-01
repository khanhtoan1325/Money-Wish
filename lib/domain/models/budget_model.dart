import 'package:expanse_management/domain/models/category_model.dart';

class Budget {
  final CategoryModel category;
  final String amount; // Ngân sách (chuỗi để dễ lưu trữ)
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final bool isRecurring; // Lặp lại theo tháng

  Budget({
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.notes,
    this.isRecurring = false,
  });

  // 🔸 Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(), // ✅ Đồng bộ với CategoryModel mới
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'isRecurring': isRecurring,
    };
  }

  // 🔸 Convert from JSON (Firebase)
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: CategoryModel.fromJson(
        Map<String, dynamic>.from(json['category'] ?? {}),
      ),
      amount: json['amount'] as String? ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      notes: json['notes'] as String? ?? '',
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  // 🔸 Copy method tiện cho update
  Budget copyWith({
    CategoryModel? category,
    String? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isRecurring,
  }) {
    return Budget(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}

// 🔹 Dùng để lưu Budget kèm ID từ Firebase
class BudgetWithId {
  final String id;
  final Budget budget;

  BudgetWithId({
    required this.id,
    required this.budget,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        ...budget.toJson(),
      };

  factory BudgetWithId.fromJson(String id, Map<String, dynamic> json) {
    return BudgetWithId(
      id: id,
      budget: Budget.fromJson(json),
    );
  }
}
