import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 86),
        child: _AddTransactionButton(
          onTap: () => showAddTransactionSheet(context),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _goToIndex(context, index),
      ),
    );
  }

  int _indexForPath(String path) {
    return switch (path) {
      '/statistics' => 1,
      '/settings' => 2,
      _ => 0,
    };
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/statistics');
      case 2:
        context.go('/settings');
    }
  }
}

class _AddTransactionButton extends StatelessWidget {
  const _AddTransactionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.mint, AppColors.lavender],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.lavender.withValues(alpha: 0.28),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}
