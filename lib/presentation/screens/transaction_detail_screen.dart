import 'package:flutter/material.dart';
import '../../domain/models/transaction_model.dart';
import '../../services/app_localizations.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations();
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: appLocalizations.languageNotifier,
          builder: (context, lang, _) => Text(appLocalizations.get('transaction_details')),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<String>(
          valueListenable: appLocalizations.languageNotifier,
          builder: (context, lang, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${appLocalizations.get('category')}: ${transaction.category.title}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('${appLocalizations.get('amount')}: ${transaction.amount} VND',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('${appLocalizations.get('type')}: ${transaction.type == 'Income' ? appLocalizations.get('income') : appLocalizations.get('expenses')}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('${appLocalizations.get('date')}: ${transaction.createAt.day}/${transaction.createAt.month}/${transaction.createAt.year}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('${appLocalizations.get('note')}: ${transaction.notes}', 
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
