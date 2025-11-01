import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/budget_model.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expanse_management/presentation/screens/edit_budget_screen.dart';


class BudgetDetailScreen extends StatefulWidget {
  final BudgetWithId budgetWithId;

  const BudgetDetailScreen({Key? key, required this.budgetWithId})
      : super(key: key);

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final FirebaseDbService _firebaseService = FirebaseDbService();

  // Tính tổng chi tiêu
  int calculateSpent(Budget budget, List<TransactionWithId> transactions) {
    int total = 0;
    for (var txWithId in transactions) {
      final tx = txWithId.transaction;
      if (tx.type == 'Expense' &&
          tx.category.title == budget.category.title &&
          tx.createAt.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
          tx.createAt.isBefore(budget.endDate.add(const Duration(days: 1)))) {
        total += int.tryParse(tx.amount) ?? 0;
      }
    }
    return total;
  }

  // Lấy danh sách transactions trong budget
  List<TransactionWithId> getTransactionsInBudget(
      Budget budget, List<TransactionWithId> transactions) {
    return transactions.where((txWithId) {
      final tx = txWithId.transaction;
      return tx.type == 'Expense' &&
          tx.category.title == budget.category.title &&
          tx.createAt.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
          tx.createAt.isBefore(budget.endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Tính chi tiêu trung bình mỗi ngày
  double calculateDailyAverage(int spent, Budget budget) {
    final days = budget.endDate.difference(budget.startDate).inDays + 1;
    return days > 0 ? spent / days : 0;
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budgetWithId.budget;
    final budgetAmount = int.tryParse(budget.amount) ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(budget.category.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async{
              // TODO: Navigate to Edit Budget
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditBudgetScreen(
                    budgetId: widget.budgetWithId.id,
                    budget: widget.budgetWithId.budget,
                  ),
                ),
              );

              if (result == true) {
                setState(() {}); // Reload lại dữ liệu sau khi chỉnh sửa
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa ngân sách'),
                  content: const Text('Bạn có chắc chắn muốn xóa ngân sách này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await _firebaseService.deleteBudget(widget.budgetWithId.id);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Đã xóa ngân sách'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionWithId>>(
        stream: _firebaseService.listenTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];
          final spent = calculateSpent(budget, transactions);
          final remaining = budgetAmount - spent;
          final progress = budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;
          final dailyAverage = calculateDailyAverage(spent, budget);
          final budgetTransactions = getTransactionsInBudget(budget, transactions);

          final daysTotal = budget.endDate.difference(budget.startDate).inDays + 1;
          final daysPassed = DateTime.now().difference(budget.startDate).inDays + 1;
          final daysRemaining = budget.endDate.difference(DateTime.now()).inDays;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header card with budget info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'images/${budget.category.categoryImage}',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formatCurrency(budgetAmount),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Còn lại ${formatCurrency(remaining)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: remaining < 0 ? Colors.red.shade200 : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white30,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? Colors.red
                                : progress >= 0.8
                                    ? Colors.orange
                                    : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% đã sử dụng',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Date range
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${budget.startDate.day}/${budget.startDate.month}/${budget.startDate.year} - ${budget.endDate.day}/${budget.endDate.month}/${budget.endDate.year}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Còn lại $daysRemaining ngày',
                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Chi tiêu hôm nay',
                              formatCurrency(spent),
                              Icons.trending_up,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Trung bình/ngày',
                              formatCurrency(dailyAverage.toInt()),
                              Icons.analytics_outlined,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Tiêu chuẩn chi tiêu',
                              formatCurrency(budgetAmount),
                              Icons.account_balance_wallet,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Số giao dịch',
                              '${budgetTransactions.length}',
                              Icons.receipt_long,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Simple line chart (spending over time)
                      if (budgetTransactions.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Biểu đồ chi tiêu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _generateChartData(budgetTransactions, budget),
                                  isCurved: true,
                                  color: primaryColor,
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: primaryColor.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Transaction list
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chi tiết giao dịch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      budgetTransactions.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(32),
                              child: const Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 60, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có giao dịch nào',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: budgetTransactions.length,
                              itemBuilder: (context, index) {
                                final tx = budgetTransactions[index].transaction;
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'images/${tx.category.categoryImage}',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  title: Text(
                                    tx.notes,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${tx.createAt.day}/${tx.createAt.month}/${tx.createAt.year}',
                                  ),
                                  trailing: Text(
                                    formatCurrency(int.parse(tx.amount)),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData(List<TransactionWithId> transactions, Budget budget) {
    if (transactions.isEmpty) return [];
    
    // Group by day and calculate cumulative spending
    Map<int, double> dailySpending = {};
    for (var txWithId in transactions) {
      final tx = txWithId.transaction;
      final daysSinceStart = tx.createAt.difference(budget.startDate).inDays;
      dailySpending[daysSinceStart] = (dailySpending[daysSinceStart] ?? 0) + 
          (double.tryParse(tx.amount) ?? 0);
    }

    // Create cumulative chart data
    List<FlSpot> spots = [];
    double cumulative = 0;
    final sortedDays = dailySpending.keys.toList()..sort();
    
    for (var day in sortedDays) {
      cumulative += dailySpending[day]!;
      spots.add(FlSpot(day.toDouble(), cumulative));
    }

    return spots;
  }
}