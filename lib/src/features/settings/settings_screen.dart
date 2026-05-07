import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_sheet.dart';
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
          padding: EdgeInsets.fromLTRB(
            context.scaled(24),
            context.scaled(16),
            context.scaled(24),
            context.scaled(120),
          ),
          children: [
            Text(
              'Cài đặt',
              style: context.appText.pageEyebrow,
            ),
            SizedBox(height: context.scaled(5)),
            Text(
              'Tuỳ chỉnh ứng dụng',
              style: context.appText.pageTitle.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                fontSize: context.scaledFont(27, min: 24),
              ),
            ),
            SizedBox(height: context.scaled(24)),
            FlatCard(
              radius: context.scaled(24),
              padding: EdgeInsets.all(context.scaled(10)),
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
            SizedBox(height: context.scaled(24)),
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
