import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../transactions/add_transaction_sheet.dart';
import 'custom_bottom_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexForPath(GoRouterState.of(context).uri.path);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar:
          CustomBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) => _goToIndex(context, index),
                onAddTransaction: () => showAddTransactionSheet(context),
              )
              .animate()
              .fadeIn(duration: 260.ms)
              .slideY(
                begin: 0.35,
                end: 0,
                duration: 360.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }

  int _indexForPath(String path) {
    return switch (path) {
      '/calendar' => 1,
      '/recurring' => 3,
      '/settings' => 4,
      _ => 0,
    };
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/calendar');
      case 2:
        showAddTransactionSheet(context);
      case 3:
        context.go('/recurring');
      case 4:
        context.go('/settings');
    }
  }
}
