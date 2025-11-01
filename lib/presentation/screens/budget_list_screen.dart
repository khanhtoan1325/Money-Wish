import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/budget_model.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:expanse_management/presentation/screens/budget_detail_screen.dart';
import 'package:expanse_management/services/budget_notification_helper.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({Key? key}) : super(key: key);

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseDbService _firebaseService = FirebaseDbService();
  final BudgetNotificationHelper _notificationHelper = BudgetNotificationHelper();
  final AppLocalizations _appLocalizations = AppLocalizations();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Khởi tạo scheduled notifications khi vào màn hình budget
    _notificationHelper.initializeAllScheduledNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Tính tổng chi tiêu trong budget period
  int calculateSpent(Budget budget, List<TransactionWithId> transactions) {
    int total = 0;
    for (var txWithId in transactions) {
      final tx = txWithId.transaction;
      // Chỉ tính Expense trong category này và trong thời gian budget
      if (tx.type == 'Expense' &&
          tx.category.title == budget.category.title &&
          tx.createAt.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
          tx.createAt.isBefore(budget.endDate.add(const Duration(days: 1)))) {
        total += int.tryParse(tx.amount) ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(
                  _appLocalizations.get('budgets'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => TabBar(
                  controller: _tabController,
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: isDark ? Colors.white70 : Colors.grey,
                  tabs: [
                    Tab(text: _appLocalizations.get('active').toUpperCase()),
                    Tab(text: _appLocalizations.get('ended').toUpperCase()),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: StreamBuilder<List<BudgetWithId>>(
                stream: _firebaseService.listenBudgets(),
                builder: (context, budgetSnapshot) {
                  if (budgetSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (budgetSnapshot.hasError) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _appLocalizations.languageNotifier,
                      builder: (context, lang, _) => Center(
                        child: Text('${_appLocalizations.get('error')}: ${budgetSnapshot.error}'),
                      ),
                    );
                  }

                  final allBudgets = budgetSnapshot.data ?? [];

                  return StreamBuilder<List<TransactionWithId>>(
                    stream: _firebaseService.listenTransactions(),
                    builder: (context, txSnapshot) {
                      final transactions = txSnapshot.data ?? [];

                      return Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Active budgets
                                _buildBudgetList(
                                  allBudgets.where((b) => 
                                    b.budget.endDate.isAfter(DateTime.now())
                                  ).toList(),
                                  transactions,
                                  isActive: true,
                                ),
                                // Ended budgets
                                _buildBudgetList(
                                  allBudgets.where((b) => 
                                    b.budget.endDate.isBefore(DateTime.now())
                                  ).toList(),
                                  transactions,
                                  isActive: false,
                                ),
                              ],
                            ),
                          ),
                          // Nút thêm ở dưới cùng (có padding bottom để tránh che bởi bottom nav)
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
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add-budget');
                                },
                                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                                label: ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Text(
                                    _appLocalizations.get('add_new_budget'),
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList(
    List<BudgetWithId> budgets,
    List<TransactionWithId> transactions,
    {required bool isActive}
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (budgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (context, lang, _) => Column(
                children: [
                  Text(
                    isActive
                        ? _appLocalizations.get('no_budgets_yet')
                        : _appLocalizations.get('no_ended_budgets'),
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _appLocalizations.get('tap_plus_to_create'),
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budgetWithId = budgets[index];
        final budget = budgetWithId.budget;
        final budgetAmount = int.tryParse(budget.amount) ?? 0;
        final spent = calculateSpent(budget, transactions);
        final remaining = budgetAmount - spent;
        final progress = budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;

        return GestureDetector(
          onTap: () {
            // Navigate to Budget Detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BudgetDetailScreen(
                  budgetWithId: budgetWithId,
                ),
              ),
            );
          },
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: isDark ? 0 : 2,
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Image.asset(
                              'images/${budget.category.categoryImage}',
                              width: 28,
                              height: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.category.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Text(
                                    remaining < 0 
                                        ? '${_appLocalizations.get('overspent')} ${formatCurrency(-remaining)}'
                                        : '${_appLocalizations.get('remaining')} ${formatCurrency(remaining)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: remaining < 0 ? Colors.red : (isDark ? Colors.white70 : Colors.grey),
                                      fontWeight: remaining < 0 ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Date range
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.white54 : Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${budget.startDate.day}/${budget.startDate.month}/${budget.startDate.year} - ${budget.endDate.day}/${budget.endDate.month}/${budget.endDate.year}',
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(
                                  _appLocalizations.get('spent_today'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Text(
                                formatCurrency(spent),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: isDark ? Colors.white24 : Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? Colors.red
                                    : progress >= 0.8
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(
                                  _appLocalizations.get('total_budget'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Text(
                                formatCurrency(budgetAmount),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}