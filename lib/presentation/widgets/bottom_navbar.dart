import 'package:expanse_management/presentation/screens/add_transaction.dart';
import 'package:expanse_management/presentation/screens/home.dart';
import 'package:expanse_management/presentation/screens/search_screen.dart';
import 'package:expanse_management/presentation/screens/statistic.dart';
import 'package:flutter/material.dart';
import 'package:expanse_management/presentation/screens/budget_list_screen.dart';
import 'package:expanse_management/Constants/color.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int indexColor = 0;

  final List<Widget> screens = [
    const Home(),              // 0
    const Statistics(),        // 1
    const BudgetListScreen(),  // 2
    const SearchScreen(),      // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[indexColor],
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🌟 Nhóm bên trái FAB
              Row(
                children: [
                  _buildNavItem(Icons.home, 0),
                  const SizedBox(width: 10),
                  _buildNavItem(Icons.bar_chart_outlined, 1),
                ],
              ),

              // 🌟 Nhóm bên phải FAB
              Row(
                children: [
                  _buildNavItem(Icons.account_balance_wallet, 2), // Ngân sách
                  const SizedBox(width: 10),
                  _buildNavItem(Icons.search_outlined, 3),        // Tìm kiếm
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          indexColor = index;
        });
      },
      child: Container(
        height: 40,
        width: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 28,
          color: indexColor == index ? primaryColor : Colors.grey,
        ),
      ),
    );
  }
}