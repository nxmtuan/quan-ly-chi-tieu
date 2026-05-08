import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/calendar_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/placeholder/coming_soon_screen.dart';
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
            return _buildPage(
              state: state,
              child: const ComingSoonScreen(
                title: 'Ví',
                icon: Icons.account_balance_wallet_rounded,
              ),
            );
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
            return _buildPage(
              state: state,
              child: const ComingSoonScreen(
                title: 'Giao dịch định kỳ',
                icon: Icons.repeat_rounded,
              ),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            return _buildPage(state: state, child: const SettingsScreen());
          },
        ),
      ],
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
