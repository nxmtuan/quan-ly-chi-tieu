import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/flat_card.dart';
import '../../models/auth_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/google_web_sign_in_button.dart';
import '../categories/categories_screen.dart';

part 'widgets/settings_sections.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authUser = ref.watch(authProvider);

    return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize your tracker',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            FlatCard(
              radius: 24,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _ThemeSettingsRow(themeMode: themeMode),
                  const _DividerIndent(),
                  const _ManageCategoriesRow(),
                  const _DividerIndent(),
                  _AuthSettingsRow(authUser: authUser),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SettingsTipCard(),
          ],
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 340.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
