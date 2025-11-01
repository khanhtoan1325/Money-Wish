import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:expanse_management/domain/models/budget_model.dart';
import 'package:expanse_management/domain/models/category_model.dart';

class FirebaseDbService {
  final fb.DatabaseReference _db = fb.FirebaseDatabase.instance.ref();

  // ✅ Lấy userId hiện tại
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ✅ Reference đến transactions của user hiện tại
  fb.DatabaseReference transactionsRef() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated. Please login first.');
    }
    return _db.child('users').child(userId).child('transactions');
  }

  // ✅ Thêm transaction
  Future<String> addTransaction(Transaction tx) async {
    final ref = transactionsRef().push();
    await ref.set(tx.toJson());
    return ref.key ?? '';
  }

  // ✅ Cập nhật transaction
  Future<void> updateTransaction(String id, Transaction tx) async {
    final ref = transactionsRef().child(id);
    await ref.update(tx.toJson());
  }

  // ✅ Xóa transaction
  Future<void> deleteTransaction(String id) async {
    final ref = transactionsRef().child(id);
    await ref.remove();
  }

  // ✅ Lấy tất cả transactions (dùng 1 lần)
  Future<List<TransactionWithId>> fetchAllTransactions() async {
    final snapshot = await transactionsRef().get();
    final List<TransactionWithId> list = [];
    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map<dynamic, dynamic>;
      map.forEach((key, value) {
        try {
          final tx = Transaction.fromJson(Map<String, dynamic>.from(value));
          list.add(TransactionWithId(id: key as String, transaction: tx));
        } catch (e) {
          print('Error parsing transaction: $e');
        }
      });
    }
    return list;
  }

  // ✅ Listen realtime changes (QUAN TRỌNG - dùng cho UI)
  Stream<List<TransactionWithId>> listenTransactions() {
    return transactionsRef().onValue.map((event) {
      final List<TransactionWithId> list = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          try {
            final tx = Transaction.fromJson(Map<String, dynamic>.from(value));
            list.add(TransactionWithId(id: key as String, transaction: tx));
          } catch (e) {
            print('Error parsing transaction: $e');
          }
        });
      }
      return list;
    });
  }

  // ==================== BUDGET METHODS ====================

  // ✅ Reference đến budgets của user hiện tại
  fb.DatabaseReference budgetsRef() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated. Please login first.');
    }
    return _db.child('users').child(userId).child('budgets');
  }

  // ✅ Thêm budget
  Future<String> addBudget(Budget budget) async {
    final ref = budgetsRef().push();
    await ref.set(budget.toJson());
    return ref.key ?? '';
  }

  // ✅ Cập nhật budget
  Future<void> updateBudget(String id, Budget budget) async {
    final ref = budgetsRef().child(id);
    await ref.update(budget.toJson());
  }

  // ✅ Xóa budget
  Future<void> deleteBudget(String id) async {
    final ref = budgetsRef().child(id);
    await ref.remove();
  }

  // ✅ Lấy tất cả budgets
  Future<List<BudgetWithId>> fetchAllBudgets() async {
    final snapshot = await budgetsRef().get();
    final List<BudgetWithId> list = [];
    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map<dynamic, dynamic>;
      map.forEach((key, value) {
        try {
          final budget = Budget.fromJson(Map<String, dynamic>.from(value));
          list.add(BudgetWithId(id: key as String, budget: budget));
        } catch (e) {
          print('Error parsing budget: $e');
        }
      });
    }
    return list;
  }

  // ✅ Listen realtime budgets
  Stream<List<BudgetWithId>> listenBudgets() {
    return budgetsRef().onValue.map((event) {
      final List<BudgetWithId> list = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          try {
            final budget = Budget.fromJson(Map<String, dynamic>.from(value));
            list.add(BudgetWithId(id: key as String, budget: budget));
          } catch (e) {
            print('Error parsing budget: $e');
          }
        });
      }
      return list;
    });
  }

  // ==================== CATEGORY METHODS ====================

  // ✅ Reference đến categories của user hiện tại
  fb.DatabaseReference categoriesRef() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated. Please login first.');
    }
    return _db.child('users').child(userId).child('categories');
  }

  // ✅ Thêm danh mục mới
  Future<String> addCategory(CategoryModel category) async {
    final ref = categoriesRef().push();
    await ref.set(category.toJson());
    return ref.key ?? '';
  }

  // ✅ Cập nhật danh mục
  Future<void> updateCategory(String id, CategoryModel category) async {
    final ref = categoriesRef().child(id);
    await ref.update(category.toJson());
  }

  // ✅ Xóa danh mục
  Future<void> deleteCategory(String id) async {
    final ref = categoriesRef().child(id);
    await ref.remove();
  }

  // ✅ Lấy toàn bộ danh mục
  Future<List<CategoryWithId>> fetchAllCategories() async {
    final snapshot = await categoriesRef().get();
    final List<CategoryWithId> list = [];
    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map<dynamic, dynamic>;
      map.forEach((key, value) {
        try {
          final cat = CategoryModel.fromJson(Map<String, dynamic>.from(value));
          list.add(CategoryWithId(id: key as String, category: cat));
        } catch (e) {
          print('Error parsing category: $e');
        }
      });
    }
    return list;
  }

  // ✅ Lắng nghe realtime (hiển thị UI tự động cập nhật)
  Stream<List<CategoryWithId>> listenCategories() {
    return categoriesRef().onValue.map((event) {
      final List<CategoryWithId> list = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        final map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          try {
            final cat = CategoryModel.fromJson(Map<String, dynamic>.from(value));
            list.add(CategoryWithId(id: key as String, category: cat));
          } catch (e) {
            print('Error parsing category: $e');
          }
        });
      }
      return list;
    });
  }

  // ==================== PROFILE METHODS ====================

  // ✅ Reference đến profile của user hiện tại
  fb.DatabaseReference profileRef() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated. Please login first.');
    }
    return _db.child('users').child(userId).child('profile');
  }

  // ✅ Lấy profile data
  Future<Map<String, dynamic>> getProfile() async {
    final snapshot = await profileRef().get();
    if (snapshot.exists && snapshot.value != null) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return {};
  }

  // ✅ Lưu/cập nhật profile data
  Future<void> updateProfile({
    String? displayName,
    String? gender,
    String? dateOfBirth,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      // Cập nhật displayName trong Firebase Auth
      await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
    }
    if (gender != null) {
      updates['gender'] = gender;
    }
    if (dateOfBirth != null) {
      updates['dateOfBirth'] = dateOfBirth;
    }
    updates['updatedAt'] = DateTime.now().toIso8601String();
    
    await profileRef().update(updates);
  }

  // ✅ Stream profile data để listen realtime
  Stream<Map<String, dynamic>> listenProfile() {
    return profileRef().onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return <String, dynamic>{};
    });
  }
}

class CategoryWithId {
  final String id;
  final CategoryModel category;

  CategoryWithId({required this.id, required this.category});
}



