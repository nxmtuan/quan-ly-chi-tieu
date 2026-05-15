import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/budget/budget_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/recurring/recurring_screen.dart';
import '../../features/savings/savings_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/statistics/statistics_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const HomeScreen());
          },
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const CalendarScreen());
          },
        ),
        GoRoute(
          path: '/wallet',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const SavingsScreen());
          },
        ),
        GoRoute(
          path: '/statistics',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const StatisticsScreen());
          },
        ),
        GoRoute(
          path: '/recurring',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const RecurringScreen());
          },
        ),
        GoRoute(
          path: '/budget',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const BudgetScreen());
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) {
        return _buildSettingsPage(
          state: state,
          child: const SafeArea(bottom: false, child: SettingsScreen()),
        );
      },
    ),
  ],
);

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ClipRect(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.985,
                end: 1,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

CustomTransitionPage<void> _buildSettingsPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      );
    },
  );
}
