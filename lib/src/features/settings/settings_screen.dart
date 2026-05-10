import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_time_picker.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/flat_card.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../models/auth_user.dart';
import '../../models/auto_sync_settings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/money_source_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../auth/google_web_sign_in_button.dart';
import '../categories/category_management_sheet.dart';
import 'money_source_management_sheet.dart';

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
            context.scaled(120) + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const AppPageHeader(
              subtitle: 'Cài đặt',
              title: 'Tuỳ chỉnh ứng dụng',
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
                  const _ManageMoneySourcesRow(),
                  if (authUser != null) ...[
                    const _DividerIndent(),
                    const _SyncDataRow(),
                  ],
                ],
              ),
            ),
            SizedBox(height: context.scaled(24)),
            const _SettingsTipCard(),
            SizedBox(height: context.scaled(24)),
            FlatCard(
              radius: context.scaled(24),
              padding: EdgeInsets.all(context.scaled(10)),
              child: Column(
                children: [
                  _AuthSettingsRow(authUser: authUser),
                ],
              ),
            ),
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
