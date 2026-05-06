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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 86),
        child:
            _AddTransactionButton(onTap: () => showAddTransactionSheet(context))
                .animate(delay: 180.ms)
                .fadeIn(duration: 260.ms)
                .scale(
                  begin: const Offset(0.72, 0.72),
                  end: const Offset(1, 1),
                  duration: 360.ms,
                  curve: Curves.easeOutBack,
                ),
      ),
      bottomNavigationBar:
          CustomBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) => _goToIndex(context, index),
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
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: isDark ? 12 : 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}
