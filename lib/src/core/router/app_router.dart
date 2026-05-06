import 'package:go_router/go_router.dart';

import '../../features/home/home_dashboard_screen.dart';
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
            return const NoTransitionPage(child: HomeScreen());
          },
        ),
        GoRoute(
          path: '/statistics',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: StatisticsScreen());
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            return const NoTransitionPage(child: SettingsScreen());
          },
        ),
      ],
    ),
  ],
);
