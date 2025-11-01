import 'package:expanse_management/Constants/days.dart';
import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/transaction_detail_screen.dart';
import 'package:intl/intl.dart';

enum TimeFilter { day, month, year }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseDbService _firebaseService = FirebaseDbService();
  final AppLocalizations _appLocalizations = AppLocalizations();
  TimeFilter _selectedFilter = TimeFilter.day;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<TransactionWithId>>(
          stream: _firebaseService.listenTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: errorColor),
                      const SizedBox(height: 16),
                      Text('${_appLocalizations.get('error')}: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text(_appLocalizations.get('retry')),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 340, child: _head(context, [], _appLocalizations)),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<String>(
                              valueListenable: _appLocalizations.languageNotifier,
                              builder: (context, lang, _) => Text(_appLocalizations.get('no_transactions'),
                                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<String>(
                              valueListenable: _appLocalizations.languageNotifier,
                              builder: (context, lang, _) => Text(_appLocalizations.get('add_first_transaction'),
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final allTransactions = snapshot.data!;

            // ✅ Lọc giao dịch theo bộ lọc ngày / tháng / năm
            final filteredTransactions = allTransactions.where((tx) {
              final date = tx.transaction.createAt;
              switch (_selectedFilter) {
                case TimeFilter.day:
                  return date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                case TimeFilter.month:
                  return date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                case TimeFilter.year:
                  return date.year == _selectedDate.year;
              }
            }).toList();

            final transactions = filteredTransactions;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: 340, child: _head(context, transactions, _appLocalizations)),
                ),

                // 🔹 Bộ lọc thời gian
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ChoiceChip(
                              label: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(_appLocalizations.get('day'), style: TextStyle(
                                  color: _selectedFilter == TimeFilter.day 
                                      ? Colors.white 
                                      : (isDark ? Colors.white70 : Colors.black),
                                )),
                              ),
                              selected: _selectedFilter == TimeFilter.day,
                              selectedColor: primaryColor,
                              onSelected: (_) => setState(() => _selectedFilter = TimeFilter.day),
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(_appLocalizations.get('month'), style: TextStyle(
                                  color: _selectedFilter == TimeFilter.month 
                                      ? Colors.white 
                                      : (isDark ? Colors.white70 : Colors.black),
                                )),
                              ),
                              selected: _selectedFilter == TimeFilter.month,
                              selectedColor: primaryColor,
                              onSelected: (_) => setState(() => _selectedFilter = TimeFilter.month),
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(_appLocalizations.get('year'), style: TextStyle(
                                  color: _selectedFilter == TimeFilter.year 
                                      ? Colors.white 
                                      : (isDark ? Colors.white70 : Colors.black),
                                )),
                              ),
                              selected: _selectedFilter == TimeFilter.year,
                              selectedColor: primaryColor,
                              onSelected: (_) => setState(() => _selectedFilter = TimeFilter.year),
                            ),
                          ],
                        ),

                        // 🔹 Hiển thị ngày rõ ràng + icon lịch
                        Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.calendar_today, color: primaryColor),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Tiêu đề Transactions History
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions History',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Danh sách giao dịch
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final txWithId = transactions[index];
                      return listTransaction(txWithId, context);
                    },
                    childCount: transactions.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget listTransaction(TransactionWithId txWithId, BuildContext context) {
    return Dismissible(
      key: Key(txWithId.id),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('confirm')),
              ),
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('confirm_delete_transaction')),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: ValueListenableBuilder<String>(
                    valueListenable: _appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Text(_appLocalizations.get('cancel')),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: ValueListenableBuilder<String>(
                    valueListenable: _appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Text(_appLocalizations.get('delete')),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        try {
          await _firebaseService.deleteTransaction(txWithId.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa giao dịch!'),
              backgroundColor: successColor,
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: $e'),
              backgroundColor: errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: getTransaction(txWithId.transaction, context),
    );
  }

  ListTile getTransaction(Transaction transaction, BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'images/${transaction.category.categoryImage}',
          height: 40,
        ),
      ),
      title: Text(
        transaction.notes,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${days[transaction.createAt.weekday - 1]}  ${transaction.createAt.day}/${transaction.createAt.month}/${transaction.createAt.year}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Text(
        formatCurrency(int.parse(transaction.amount)),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: transaction.type == 'Expense' ? expenseColor : incomeColor,
        ),
      ),
    );
  }
}

// 🔹 Phần header hiển thị tổng số dư, thu, chi
Stack _head(BuildContext context, List<TransactionWithId> transactions, AppLocalizations appLocalizations) {
  int totalIncome = 0;
  int totalExpense = 0;

  for (var txWithId in transactions) {
    final amount = int.tryParse(txWithId.transaction.amount) ?? 0;
    if (txWithId.transaction.type == 'Income') {
      totalIncome += amount;
    } else if (txWithId.transaction.type == 'Expense') {
      totalExpense += amount;
    }
  }

  final totalBalance = totalIncome - totalExpense;

  return Stack(
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
        child: Stack(
          children: [
            Positioned(
              top: 30,
              right: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Cài đặt',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, left: 30),
              child: Text(
                "MoneyWise",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Container(
            height: 180,
            width: 360,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(47, 125, 121, 0.3),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
              color: primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: appLocalizations.languageNotifier,
                        builder: (context, lang, _) => Text(appLocalizations.get('total_balance'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white)),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        formatCurrency(totalBalance),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 13,
                            backgroundColor: incomeColor,
                            child: Icon(Icons.arrow_upward,
                                color: Colors.black, size: 19),
                          ),
                          const SizedBox(width: 7),
                          ValueListenableBuilder<String>(
                            valueListenable: appLocalizations.languageNotifier,
                            builder: (context, lang, _) => Text(
                              appLocalizations.get('income'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color.fromARGB(255, 216, 216, 216),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 13,
                            backgroundColor: expenseColor,
                            child: Icon(Icons.arrow_downward,
                                color: Colors.black, size: 19),
                          ),
                          const SizedBox(width: 7),
                          ValueListenableBuilder<String>(
                            valueListenable: appLocalizations.languageNotifier,
                            builder: (context, lang, _) => Text(
                              appLocalizations.get('expenses'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color.fromARGB(255, 216, 216, 216),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrency(totalIncome),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        formatCurrency(totalExpense),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
