import 'package:flutter/material.dart';
import '../../../domain/models/wallet_model.dart';

import '../widgets/wallet_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final List<Wallet> wallets = [
    Wallet(
      id: '1',
      name: 'Ví Tiền Mặt',
      balance: 2500000,
      icon: '0xe263', // Icons.account_balance_wallet
      color: '0xFF4CAF50',
    ),
    Wallet(
      id: '2',
      name: 'Ví Ngân Hàng',
      balance: 7200000,
      icon: '0xe04b', // Icons.account_balance
      color: '0xFF2196F3',
    ),
    Wallet(
      id: '3',
      name: 'Ví Momo',
      balance: 1800000,
      icon: '0xe87c', // Icons.phone_android
      color: '0xFFFF4081',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý ví điện tử 💳'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return WalletCard(wallet: wallet);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // mở form thêm ví sau này
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
