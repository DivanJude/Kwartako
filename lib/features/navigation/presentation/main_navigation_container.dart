import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../transaction/presentation/transaction_history_screen.dart';
import '../../debt/presentation/debt_management_screen.dart';
import '../../insights/presentation/insights_screen.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content pages stack
          IndexedStack(
            index: _currentIndex,
            children: [
              const DashboardScreen(),
              const TransactionHistoryScreen(),
              const DebtManagementScreen(),
              const InsightsScreen(),
            ],
          ),
          
          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: KwartaKoBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}
