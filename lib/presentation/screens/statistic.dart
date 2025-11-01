import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/presentation/widgets/circular_chart.dart';
import 'package:expanse_management/presentation/widgets/column_chart.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:flutter/material.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  get selectedDate => null;

  @override
  State<Statistics> createState() => _StatisticsState();
}

ValueNotifier<int> notifier = ValueNotifier<int>(0);

class _StatisticsState extends State<Statistics>
    with SingleTickerProviderStateMixin {
  // ✅ Thay Hive bằng Firebase
  final FirebaseDbService _firebaseService = FirebaseDbService();
  final AppLocalizations _appLocalizations = AppLocalizations();
  List listTransaction = [[], [], [], []];
  List<Transaction> currListTransaction = [];
  List<Transaction> allTransactions = []; // ✅ Lưu tất cả transactions từ Firebase
  int indexColor = 0;

  DateTime selectedDate = DateTime.now();
  late int totalIn;
  late int totalEx;
  late int total;

  late TabController _tabController;
  late bool isCircularChartSelected;

  @override
  void initState() {
    super.initState();
    notifier.value = 0;
    isCircularChartSelected = false;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Filter transactions theo timeframe
  List<Transaction> getTransactionToday(DateTime date, List<Transaction> transactions) {
    return transactions.where((tx) {
      return tx.createAt.year == date.year &&
          tx.createAt.month == date.month &&
          tx.createAt.day == date.day;
    }).toList();
  }

  List<Transaction> getTransactionWeek(DateTime date, List<Transaction> transactions) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return transactions.where((tx) {
      return tx.createAt.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          tx.createAt.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> getTransactionMonth(DateTime date, List<Transaction> transactions) {
    return transactions.where((tx) {
      return tx.createAt.year == date.year && tx.createAt.month == date.month;
    }).toList();
  }

  List<Transaction> getTransactionYear(DateTime date, List<Transaction> transactions) {
    return transactions.where((tx) {
      return tx.createAt.year == date.year;
    }).toList();
  }

  void fetchTransactions(List<Transaction> transactions) {
    listTransaction[0] = getTransactionToday(selectedDate, transactions);
    listTransaction[1] = getTransactionWeek(selectedDate, transactions);
    listTransaction[2] = getTransactionMonth(selectedDate, transactions);
    listTransaction[3] = getTransactionYear(selectedDate, transactions);
    
    currListTransaction = listTransaction[notifier.value];
    totalIn = totalFilterdIncome(currListTransaction);
    totalEx = totalFilterdExpense(currListTransaction);
    total = totalIn - totalEx;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<TransactionWithId>>(
          // ✅ Listen từ Firebase realtime
          stream: _firebaseService.listenTransactions(),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
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

            // Empty state
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _appLocalizations.get('no_data'),
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _appLocalizations.get('add_transactions_to_see'),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ Có data - extract transactions
            allTransactions = snapshot.data!.map((txWithId) => txWithId.transaction).toList();
            fetchTransactions(allTransactions);

            return ValueListenableBuilder<int>(
              valueListenable: notifier,
              builder: (BuildContext context, int value, Widget? child) {
                currListTransaction = listTransaction[value];
                totalIn = totalFilterdIncome(currListTransaction);
                totalEx = totalFilterdExpense(currListTransaction);
                total = totalIn - totalEx;
                fetchTransactions(allTransactions);
                return customScrollView();
              },
            );
          },
        ),
      ),
    );
  }

  CustomScrollView customScrollView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(
                  _appLocalizations.get('statistics'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Day/Week/Month/Year selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(4, (index) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final dayKeys = ['day', 'week', 'month', 'year'];
                      return ValueListenableBuilder<String>(
                        valueListenable: _appLocalizations.languageNotifier,
                        builder: (context, lang, _) => GestureDetector(
                          onTap: () {
                            setState(() {
                              indexColor = index;
                              notifier.value = index;
                              if (indexColor == 1) {
                                selectedDate = DateTime.now().subtract(
                                  Duration(days: DateTime.now().weekday - 1),
                                );
                              } else {
                                selectedDate = DateTime.now();
                              }
                              fetchTransactions(allTransactions);
                            });
                          },
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: indexColor == index
                                  ? primaryColor
                                  : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _appLocalizations.get(dayKeys[index]),
                              style: TextStyle(
                                color: indexColor == index 
                                    ? Colors.white 
                                    : (isDark ? Colors.white70 : Colors.black),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Date navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getFormattedDate(indexColor, selectedDate),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (indexColor == 0) {
                                selectedDate = selectedDate.subtract(const Duration(days: 1));
                              } else if (indexColor == 1) {
                                selectedDate = selectedDate.subtract(const Duration(days: 7));
                              } else if (indexColor == 2) {
                                selectedDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month - 1,
                                  selectedDate.day,
                                );
                              } else if (indexColor == 3) {
                                selectedDate = DateTime(
                                  selectedDate.year - 1,
                                  selectedDate.month,
                                  selectedDate.day,
                                );
                              }
                            });
                            fetchTransactions(allTransactions);
                          },
                          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                        const SizedBox(width: 15),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (indexColor == 0) {
                                selectedDate = selectedDate.add(const Duration(days: 1));
                              } else if (indexColor == 1) {
                                selectedDate = selectedDate.add(const Duration(days: 7));
                              } else if (indexColor == 2) {
                                selectedDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month + 1,
                                  selectedDate.day,
                                );
                              } else if (indexColor == 3) {
                                selectedDate = DateTime(
                                  selectedDate.year + 1,
                                  selectedDate.month,
                                  selectedDate.day,
                                );
                              }
                              fetchTransactions(allTransactions);
                            });
                          },
                          icon: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Chart tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ValueListenableBuilder<String>(
                  valueListenable: _appLocalizations.languageNotifier,
                  builder: (context, lang, _) => TabBar(
                    controller: _tabController,
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    unselectedLabelColor: isDark ? Colors.white70 : Colors.black,
                    tabs: [
                      Tab(text: _appLocalizations.get('column')),
                      Tab(text: _appLocalizations.get('circular')),
                    ],
                    onTap: (index) {
                      setState(() {
                        isCircularChartSelected = index == 1;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              // Charts
              ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => isCircularChartSelected
                    ? Column(
                        children: [
                          CircularChart(
                            title: _appLocalizations.get('income'),
                            currIndex: indexColor,
                            transactions: currListTransaction,
                          ),
                          CircularChart(
                            title: _appLocalizations.get('expenses'),
                            currIndex: indexColor,
                            transactions: currListTransaction,
                          ),
                        ],
                      )
                    : ColumnChart(
                        transactions: currListTransaction,
                        currIndex: indexColor,
                      ),
              ),

              const SizedBox(height: 10),

              // Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: _appLocalizations.languageNotifier,
                          builder: (context, lang, _) => Row(
                            children: [
                              const CircleAvatar(
                                radius: 13,
                                backgroundColor: incomeColor,
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.black,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _appLocalizations.get('income'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: incomeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatCurrency(totalIn),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: incomeColor,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: _appLocalizations.languageNotifier,
                          builder: (context, lang, _) => Row(
                            children: [
                              const CircleAvatar(
                                radius: 13,
                                backgroundColor: expenseColor,
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.black,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _appLocalizations.get('expenses'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: expenseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatCurrency(totalEx),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: expenseColor,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(height: 1, color: Colors.grey, thickness: 1),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: _appLocalizations.languageNotifier,
                          builder: (context, lang, _) => Row(
                            children: [
                              const SizedBox(width: 30),
                              Text(
                                '${_appLocalizations.get('total')}:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatCurrency(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Top Spending header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ValueListenableBuilder<String>(
                  valueListenable: _appLocalizations.languageNotifier,
                  builder: (context, lang, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _appLocalizations.get('top_spending'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.swap_vert, size: 25, color: Colors.grey)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        
        // Transaction list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    'images/${currListTransaction[index].category.categoryImage}',
                    height: 40,
                  ),
                ),
                title: Text(
                  currListTransaction[index].notes,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${currListTransaction[index].createAt.day}/${currListTransaction[index].createAt.month}/${currListTransaction[index].createAt.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  formatCurrency(int.parse(currListTransaction[index].amount)),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: currListTransaction[index].type == 'Expense'
                        ? expenseColor
                        : incomeColor,
                  ),
                ),
              );
            },
            childCount: currListTransaction.length,
          ),
        )
      ],
    );
  }
}