import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/data/utilty.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final FirebaseDbService _firebaseService = FirebaseDbService();
  final AppLocalizations _appLocalizations = AppLocalizations();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: ValueListenableBuilder<String>(
          valueListenable: _appLocalizations.languageNotifier,
          builder: (context, lang, _) => Text(_appLocalizations.get('search')),
        ),
      ),
      body: Column(
        children: [
          // Ô nhập tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              cursorColor: primaryColor,
              controller: searchController,
              decoration: InputDecoration(
                labelText: _appLocalizations.get('search_by_notes'),
                labelStyle: const TextStyle(color: primaryColor),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        color: primaryColor,
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Danh sách kết quả
          Expanded(
            child: StreamBuilder<List<TransactionWithId>>(
              stream: _firebaseService.listenTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<String>(
                          valueListenable: _appLocalizations.languageNotifier,
                          builder: (context, lang, _) => Text('${_appLocalizations.get('error')}: ${snapshot.error}'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: ValueListenableBuilder<String>(
                            valueListenable: _appLocalizations.languageNotifier,
                            builder: (context, lang, _) => Text(_appLocalizations.get('retry')),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allTransactions = snapshot.data ?? [];

                // ✅ Lọc theo từ khóa tìm kiếm
                final filteredTransactions = searchQuery.isEmpty
                    ? allTransactions
                    : allTransactions
                        .where((txWithId) =>
                            (txWithId.transaction.notes ?? '')
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()))
                        .toList();

                // Không có kết quả
                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isEmpty
                              ? Icons.search_off
                              : Icons.sentiment_dissatisfied,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            return Column(
                              children: [
                                ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Text(
                                    searchQuery.isEmpty
                                        ? _appLocalizations.get('search_enter_keywords')
                                        : _appLocalizations.translateWithParams(
                                            'search_no_results',
                                            {'query': searchQuery},
                                          ),
                                    style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.grey),
                                  ),
                                ),
                                if (searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ValueListenableBuilder<String>(
                                    valueListenable: _appLocalizations.languageNotifier,
                                    builder: (context, lang, _) => Text(
                                      _appLocalizations.get('search_try_different'),
                                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                // ✅ Hiển thị danh sách kết quả
                return Column(
                  children: [
                    if (searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Text(
                                    _appLocalizations.translateWithParams(
                                      'search_found_results',
                                      {'count': filteredTransactions.length.toString()},
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    // ✅ Danh sách
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index].transaction;

                          // ✅ Đảm bảo an toàn null (nếu dữ liệu Firebase thiếu)
                          final categoryImage = tx.category?.categoryImage ?? 'Others.png';
                          final note = tx.notes ?? '';
                          final date = tx.createAt ?? DateTime.now();
                          final type = tx.type ?? 'Expense';
                          final amount = tx.amount ?? '0';

                          return Builder(
                            builder: (context) {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.asset(
                                    'images/$categoryImage',
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.image_not_supported, color: isDark ? Colors.white54 : Colors.grey),
                                  ),
                                ),
                                title: Text(
                                  note,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                trailing: Text(
                                  formatCurrency(int.tryParse(amount) ?? 0),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: type == 'Expense' ? Colors.red : Colors.green,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
