import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/flat_card.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeEnabled = ref.watch(themeToggleProvider);

    return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
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
              radius: 30,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppColors.lavender,
                    title: 'Theme Toggle',
                    subtitle: themeEnabled
                        ? 'Dark mode prepared'
                        : 'Light mode active',
                    trailing: CupertinoSwitch(
                      value: themeEnabled,
                      activeTrackColor: AppColors.lavender,
                      onChanged: (value) {
                        ref
                            .read(themeToggleProvider.notifier)
                            .setEnabled(value: value);
                      },
                    ),
                  ),
                  const _DividerIndent(),
                  _SettingsRow(
                    icon: Icons.category_rounded,
                    iconColor: AppColors.mint,
                    title: 'Manage Categories',
                    subtitle: 'Edit income and expense groups',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {},
                  ),
                  const _DividerIndent(),
                  _SettingsRow(
                    icon: Icons.ios_share_rounded,
                    iconColor: AppColors.blue,
                    title: 'Export Data',
                    subtitle: 'Download your transactions',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FlatCard(
              radius: 28,
              color: AppColors.lavenderLight,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: AppColors.lavender,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Keep logging small expenses daily for clearer insights.',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DividerIndent extends StatelessWidget {
  const _DividerIndent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 72),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
