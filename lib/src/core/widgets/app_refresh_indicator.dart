import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../utils/app_data_refresh.dart';

class AppRefreshIndicator extends ConsumerWidget {
  const AppRefreshIndicator({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function(WidgetRef ref)? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () async {
        await (onRefresh ?? refreshAppData)(ref);
      },
      child: child,
    );
  }
}
