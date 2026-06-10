import 'package:flutter/material.dart';
import 'package:flux_bank/screens/home/home_screen.dart';
import 'package:flux_bank/screens/transactions/transactions_screen.dart';
import 'package:flux_bank/screens/cards/cards_screen.dart';
import 'package:flux_bank/screens/mobile_money/mobile_money_screen.dart';
import 'package:flux_bank/screens/profile/profile_screen.dart';
import 'package:flux_bank/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Tab indices
  static const int momoTabIndex = 3;

  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _pages => [
    HomeScreen(
      onTopUp: () => _switchToTab(momoTabIndex),
      onSeeAll: () => _switchToTab(1),
    ),
    const TransactionsScreen(),
    const CardsScreen(),
    const MobileMoneyScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.shell,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.textPrimary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 22),
              activeIcon: Icon(Icons.home, size: 22),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 22),
              activeIcon: Icon(Icons.receipt_long, size: 22),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined, size: 22),
              activeIcon: Icon(Icons.credit_card, size: 22),
              label: 'Cards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_android_outlined, size: 22),
              activeIcon: Icon(Icons.phone_android, size: 22),
              label: 'MoMo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 22),
              activeIcon: Icon(Icons.person, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
