import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/domain/models/budget_model.dart';
import 'package:expanse_management/domain/models/category_model.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:flutter/material.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;
  final String budgetId;

  const EditBudgetScreen({
    Key? key,
    required this.budget,
    required this.budgetId,
  }) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountC;
  late TextEditingController _notesC;

  late CategoryModel selectedCategory;
  late DateTime startDate;
  late DateTime endDate;
  late bool isRecurring;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountC = TextEditingController(text: widget.budget.amount);
    _notesC = TextEditingController(text: widget.budget.notes);
    selectedCategory = widget.budget.category;
    startDate = widget.budget.startDate;
    endDate = widget.budget.endDate;
    isRecurring = widget.budget.isRecurring;
  }

  @override
  void dispose() {
    _amountC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedBudget = Budget(
        category: selectedCategory,
        amount: _amountC.text,
        startDate: startDate,
        endDate: endDate,
        notes: _notesC.text,
        isRecurring: isRecurring,
      );

      await FirebaseDbService()
          .updateBudget(widget.budgetId, updatedBudget);

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã cập nhật ngân sách thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật ngân sách: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Chỉnh sửa ngân sách'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateBudget,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Danh mục ---
              const Text('Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<CategoryModel>(
                value: selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [selectedCategory].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.title),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 20),

              // --- Số tiền ---
              const Text('Số tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Nhập số tiền',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Ghi chú ---
              const Text('Ghi chú', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesC,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // --- Lặp lại ---
              Row(
                children: [
                  Checkbox(
                    value: isRecurring,
                    onChanged: (v) => setState(() => isRecurring = v ?? false),
                    activeColor: primaryColor,
                  ),
                  const Text('Lặp lại hàng tháng'),
                ],
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Cập nhật ngân sách',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
