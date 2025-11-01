import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/Constants/default_categories.dart';
import 'package:expanse_management/Constants/limits.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/category_model.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/budget_notification_helper.dart';
import 'package:expanse_management/services/app_localizations.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final FirebaseDbService _dbService = FirebaseDbService();
  final BudgetNotificationHelper _notificationHelper = BudgetNotificationHelper();
  final AppLocalizations _appLocalizations = AppLocalizations();
  List<CategoryModel> incomeCategories = defaultIncomeCategories;
  List<CategoryModel> expenseCategories = defaultExpenseCategories;
  
  DateTime date = DateTime.now();
  CategoryModel? selectedCategoryItem;
  String? selectedTypeItem;

  final List<String> types = ['Income', 'Expense'];
  final TextEditingController explainC = TextEditingController();
  FocusNode explainFocus = FocusNode();
  final TextEditingController amountC = TextEditingController();
  FocusNode amountFocus = FocusNode();

  bool isAmountValid = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    explainFocus.addListener(() {
      setState(() {});
    });
    amountFocus.addListener(() {
      setState(() {});
    });

    _listenToCategories();
  }

  void _listenToCategories() {
    _dbService.listenCategories().listen((customCategories) {
      setState(() {
        incomeCategories = [
          ...customCategories.map((c) => c.category).where((c) => c.type == 'Income'),
          ...defaultIncomeCategories,
        ];
        expenseCategories = [
          ...customCategories.map((c) => c.category).where((c) => c.type == 'Expense'),
          ...defaultExpenseCategories,
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            backgroundAddContainer(context),
            Positioned(
              top: 120,
              child: mainAddContainer(),
            )
          ],
        ),
      ),
    );
  }

  Container mainAddContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 680,
      width: 360,
      child: Column(
        children: [
          const SizedBox(height: 35),
          typeField(),
          const SizedBox(height: 35),
          noteField(),
          const SizedBox(height: 35),
          amountField(),
          const SizedBox(height: 35),
          categoryField(),
          const SizedBox(height: 35),
          timeField(),
          const SizedBox(height: 35),
          addTransaction(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ Sửa lại method addTransaction - CHỈ LƯU FIREBASE
  GestureDetector addTransaction() {
    bool isWarningShown = false;
    return GestureDetector(
      onTap: _isLoading ? null : () async {
        // Validate fields
        if (selectedCategoryItem == null ||
            selectedTypeItem == null ||
            explainC.text.isEmpty ||
            amountC.text.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (ctx, lang, _) => AlertDialog(
                title: Text(_appLocalizations.get('error')),
                content: Text(_appLocalizations.get('fill_all_info')),
                actions: [
                  TextButton(
                    child: Text(_appLocalizations.get('ok')),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
          return;
        }

        double amount = double.tryParse(amountC.text) ?? 0.0;
        if (amount <= 0) {
          showDialog(
            context: context,
            builder: (context) => ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (ctx, lang, _) => AlertDialog(
                title: Text(_appLocalizations.get('error')),
                content: Text(_appLocalizations.get('amount_required')),
                actions: [
                  TextButton(
                    child: Text(_appLocalizations.get('ok')),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
          return;
        }

        // Check spending limit (soft warning, allow proceed)
        if (selectedTypeItem == 'Expense' &&
            amount > limitPerExpense &&
            !isWarningShown) {
          isWarningShown = true;
          final proceed = await showDialog<bool>(
            context: context,
            builder: (context) => ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (ctx, lang, _) => AlertDialog(
                title: Text(_appLocalizations.get('spending_limit_exceeded')),
                content: Text(
                  _appLocalizations.translateWithParams(
                    'spending_limit_warning',
                    {
                      'amount': formatCurrency(amount.toInt()),
                      'limit': formatCurrency(limitPerExpense),
                      'percent': (amount / limitPerExpense * 100).toStringAsFixed(0),
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(_appLocalizations.get('later')),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(_appLocalizations.get('continue_add')),
                  ),
                ],
              ),
            ),
          );
          if (proceed != true) {
            setState(() => _isLoading = false);
            return;
          }
        }

        setState(() => _isLoading = true);

        var newTransaction = Transaction(
          selectedTypeItem!,
          amountC.text,
          date,
          explainC.text,
          selectedCategoryItem!,
        );

        // ✅ CHỈ LƯU VÀO FIREBASE
        try {
          await FirebaseDbService().addTransaction(newTransaction);
          
          // 🔔 Kiểm tra và gửi thông báo budget warning sau khi thêm transaction
          if (selectedTypeItem == 'Expense' && newTransaction.amount.isNotEmpty) {
            try {
              // Get current budgets and transactions
              final budgets = await _dbService.fetchAllBudgets();
              final transactions = await _dbService.fetchAllTransactions();
              
              // Check for budget warnings
              await _notificationHelper.checkAndSendBudgetWarnings(budgets, transactions);
              
              // Check for unusual spending
              await _notificationHelper.checkUnusualSpending(transactions, null);
            } catch (e) {
              // Ignore notification errors, don't fail the transaction
              print('Notification error: $e');
            }
          }
          
          if (!mounted) return;
          Navigator.of(context).pop();
          
          // Show success message
          if (!mounted) return;
          final appLocalizations = AppLocalizations();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: appLocalizations.languageNotifier,
                builder: (ctx, lang, _) => Text('✅ ${appLocalizations.get('transaction_added')}'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          
          showDialog(
            context: context,
            builder: (context) => ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (ctx, lang, _) => AlertDialog(
                title: Text(_appLocalizations.get('error')),
                content: Text('${_appLocalizations.get('cant_save_transaction')}: $e'),
                actions: [
                  TextButton(
                    child: Text(_appLocalizations.get('ok')),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _isLoading ? Colors.grey : primaryColor,
        ),
        height: 50,
        width: 140,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(
                  _appLocalizations.get('add'),
                  style: const TextStyle(
                    fontFamily: 'f',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Padding timeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: const Color(0xffC5C5C5)),
        ),
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030),
            );
            if (newDate == null) return;
            setState(() {
              date = newDate;
            });
          },
          child: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(
              '${_appLocalizations.get('date')}: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Padding amountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amountFocus,
        controller: amountC,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          labelText: _appLocalizations.get('amount'),
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade800),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: primaryColor),
          ),
          errorText: isAmountValid ? null : _appLocalizations.get('amount_required'),
        ),
        onChanged: (value) {
          setState(() {
            if (value.isEmpty) {
              isAmountValid = true;
            } else {
              isAmountValid = double.tryParse(value) != null && double.parse(value) > 0;
            }
          });
        },
      ),
    );
  }

  Padding typeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: primaryColor),
        ),
        child: DropdownButton<String>(
          value: selectedTypeItem,
          items: types
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Image.asset('images/$e.png'),
                        ),
                        const SizedBox(width: 10),
                        Text(e, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => types
              .map((e) => Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Image.asset('images/$e.png'),
                      ),
                      const SizedBox(width: 5),
                      Text(e),
                    ],
                  ))
              .toList(),
          hint: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(
              _appLocalizations.get('select_type'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
          onChanged: (value) {
            setState(() {
              selectedTypeItem = value!;
              selectedCategoryItem = null;
            });
          },
        ),
      ),
    );
  }

  Padding noteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        focusNode: explainFocus,
        controller: explainC,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          labelText: _appLocalizations.get('notes'),
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade800),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: primaryColor),
          ),
        ),
      ),
    );
  }

  Padding categoryField() {
    final List<CategoryModel> currCategories =
        selectedTypeItem == 'Income' ? incomeCategories : expenseCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: primaryColor),
        ),
        child: DropdownButton<CategoryModel>(
          value: selectedCategoryItem,
          items: currCategories
              .map(
                (e) => DropdownMenuItem<CategoryModel>(
                  value: e,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Image.asset('images/${e.categoryImage}'),
                      ),
                      const SizedBox(width: 10),
                      Text(e.title, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (BuildContext context) => currCategories
              .map(
                (e) => Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Image.asset('images/${e.categoryImage}'),
                    ),
                    const SizedBox(width: 5),
                    Text(e.title),
                  ],
                ),
              )
              .toList(),
          hint: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(
              _appLocalizations.get('select_category'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
          onChanged: (value) {
            setState(() {
              selectedCategoryItem = value;
            });
          },
        ),
      ),
    );
  }

  Column backgroundAddContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _appLocalizations.languageNotifier,
                      builder: (context, lang, _) => Text(
                        _appLocalizations.get('add_transaction'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.attach_file_outlined, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}