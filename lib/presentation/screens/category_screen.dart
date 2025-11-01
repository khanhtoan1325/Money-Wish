import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/Constants/default_categories.dart';
import 'package:expanse_management/domain/models/category_model.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  final FirebaseDbService _dbService = FirebaseDbService();
  final AppLocalizations _appLocalizations = AppLocalizations();
  List<CategoryWithId> customCategories = [];
  List<CategoryModel> expenseCategories = [];
  List<CategoryModel> incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _listenToCategories();
  }

  void _listenToCategories() {
    _dbService.listenCategories().listen((categories) {
      customCategories = categories;
      _updateCategoryLists();
    });
  }

  void _updateCategoryLists() {
    expenseCategories = [
      ...customCategories.map((c) => c.category).where((c) => c.type == 'Expense'),
      ...defaultExpenseCategories
    ];

    incomeCategories = [
      ...customCategories.map((c) => c.category).where((c) => c.type == 'Income'),
      ...defaultIncomeCategories
    ];

    setState(() {});
  }

  void _showAddOrEditDialog({CategoryWithId? categoryWithId}) {
    final TextEditingController titleController =
        TextEditingController(text: categoryWithId?.category.title ?? '');
    String selectedType = categoryWithId?.category.type ?? 'Income';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (context, lang, _) => AlertDialog(
                title: Text(categoryWithId == null 
                    ? _appLocalizations.get('add_category') 
                    : _appLocalizations.get('edit_category')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: _appLocalizations.get('category_name'),
                        hintText: _appLocalizations.get('category_name_hint'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: [
                        DropdownMenuItem(
                          value: 'Income',
                          child: Text(_appLocalizations.get('income')),
                        ),
                        DropdownMenuItem(
                          value: 'Expense',
                          child: Text(_appLocalizations.get('expenses')),
                        ),
                      ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                      decoration: InputDecoration(
                        labelText: _appLocalizations.get('type'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_appLocalizations.get('cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: ValueListenableBuilder<String>(
                              valueListenable: _appLocalizations.languageNotifier,
                              builder: (ctx, lang, _) => Text(_appLocalizations.get('enter_category_name')),
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        final newCategory = CategoryModel(
                          title: title,
                          categoryImage: 'Others.png', // icon mặc định
                          type: selectedType,
                        );

                        if (categoryWithId == null) {
                          // Thêm mới
                          await _dbService.addCategory(newCategory);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (ctx, lang, _) => Text(_appLocalizations.get('category_added')),
                              ),
                            ),
                          );
                        } else {
                          // Cập nhật
                          await _dbService.updateCategory(categoryWithId.id, newCategory);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (ctx, lang, _) => Text(_appLocalizations.get('category_updated')),
                              ),
                            ),
                          );
                        }

                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: ValueListenableBuilder<String>(
                              valueListenable: _appLocalizations.languageNotifier,
                              builder: (ctx, lang, _) => Text('${_appLocalizations.get('error')}: $e'),
                            ),
                          ),
                        );
                      }
                    },
                    child: ValueListenableBuilder<String>(
                      valueListenable: _appLocalizations.languageNotifier,
                      builder: (context, lang, _) => Text(
                        categoryWithId == null 
                            ? _appLocalizations.get('add') 
                            : _appLocalizations.get('save'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteCategory(String categoryId) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ValueListenableBuilder<String>(
          valueListenable: _appLocalizations.languageNotifier,
          builder: (ctx, lang, _) => AlertDialog(
            title: Text(_appLocalizations.get('confirm')),
            content: Text(_appLocalizations.get('confirm_delete_category')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_appLocalizations.get('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(_appLocalizations.get('delete')),
              ),
            ],
          ),
        ),
      );

      if (confirmed == true) {
        await _dbService.deleteCategory(categoryId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (ctx, lang, _) => Text(_appLocalizations.get('category_deleted')),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (ctx, lang, _) => Text('${_appLocalizations.get('error')}: $e'),
          ),
        ),
      );
    }
  }

  Widget _buildCategoryList(List<CategoryModel> categories, String type) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = categories[index];
          final isDefault = (defaultExpenseCategories + defaultIncomeCategories)
              .any((def) => def.title == category.title);

          // Tìm categoryId nếu là custom category
          CategoryWithId? categoryWithId;
          if (!isDefault) {
            categoryWithId = customCategories.firstWhere(
              (c) => c.category.title == category.title && c.category.type == type,
              orElse: () => CategoryWithId(id: '', category: category),
            );
          }

          return ListTile(
            leading: Image.asset(
              'images/${category.categoryImage}',
              height: 40,
            ),
            title: Text(category.title),
            trailing: isDefault
                ? ValueListenableBuilder<String>(
                    valueListenable: _appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Chip(
                      label: Text(_appLocalizations.get('default'), 
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.grey,
                    ),
                  )
                : PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit' && categoryWithId != null) {
                        _showAddOrEditDialog(categoryWithId: categoryWithId);
                      } else if (value == 'delete' && categoryWithId != null && categoryWithId.id.isNotEmpty) {
                        _deleteCategory(categoryWithId.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ValueListenableBuilder<String>(
                          valueListenable: _appLocalizations.languageNotifier,
                          builder: (ctx, lang, _) => Text(_appLocalizations.get('edit')),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ValueListenableBuilder<String>(
                          valueListenable: _appLocalizations.languageNotifier,
                          builder: (ctx, lang, _) => Text(_appLocalizations.get('delete')),
                        ),
                      ),
                    ],
                  ),
          );
        },
        childCount: categories.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: ValueListenableBuilder<String>(
          valueListenable: _appLocalizations.languageNotifier,
          builder: (context, lang, _) => Text(_appLocalizations.get('categories')),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _appLocalizations.languageNotifier,
                      builder: (context, lang, _) => Text(
                        _appLocalizations.get('income'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ),
                ),
                _buildCategoryList(incomeCategories, 'Income'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _appLocalizations.languageNotifier,
                      builder: (context, lang, _) => Text(
                        _appLocalizations.get('expenses'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                _buildCategoryList(expenseCategories, 'Expense'),
                // Thêm padding ở dưới để không bị che bởi nút
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          ),
          // Nút thêm ở dưới cùng (có margin bottom để tránh che bởi bottom nav)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            margin: const EdgeInsets.only(bottom: 80), // Khoảng cách với bottom nav
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddOrEditDialog(),
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                label: ValueListenableBuilder<String>(
                  valueListenable: _appLocalizations.languageNotifier,
                  builder: (context, lang, _) => Text(
                    _appLocalizations.get('add_new_category'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
