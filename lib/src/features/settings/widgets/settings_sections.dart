part of '../settings_screen.dart';

class _ThemeSettingsRow extends ConsumerWidget {
  const _ThemeSettingsRow({required this.themeMode});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      icon: Icons.dark_mode_rounded,
      iconColor: AppColors.primary,
      title: 'Giao diện',
      subtitle: _themeLabel(themeMode),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () => _showThemeSheet(context, ref),
    );
  }

  Future<void> _showThemeSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return _ThemeModeSheet(
              selectedTheme: ref.watch(themeModeProvider),
              onSelected: (themeMode) {
                ref.read(themeModeProvider.notifier).setThemeMode(themeMode);
              },
            );
          },
        );
      },
    );
  }
}

class _ManageCategoriesRow extends StatelessWidget {
  const _ManageCategoriesRow();

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: Icons.category_rounded,
      iconColor: AppColors.success,
      title: 'Quản lý danh mục',
      subtitle: 'Chỉnh sửa nhóm thu nhập và chi tiêu',
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const CategoriesScreen(),
          ),
        );
      },
    );
  }
}

class _AuthSettingsRow extends ConsumerWidget {
  const _AuthSettingsRow({required this.authUser});

  final AuthUser? authUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (authUser == null) {
      return _SettingsRow(
        icon: Icons.login_rounded,
        iconColor: AppColors.primary,
        title: kIsWeb ? 'Tài khoản' : 'Đăng nhập',
        subtitle: 'Kết nối tài khoản Google',
        trailing: kIsWeb
            ? const SizedBox(
                width: 220,
                height: 44,
                child: GoogleWebSignInButton(),
              )
            : const Icon(Icons.login_rounded),
        onTap: kIsWeb ? null : () => _signIn(context, ref),
      );
    }

    return _SettingsRow(
      icon: Icons.logout_rounded,
      iconColor: AppColors.danger,
      title: 'Đăng xuất',
      subtitle: authUser!.email,
      trailing: const Icon(Icons.logout_rounded),
      onTap: () => ref.read(authProvider.notifier).signOut(),
    );
  }

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể đăng nhập Google. Vui lòng kiểm tra cấu hình OAuth.',
            ),
          ),
        );
      }
    }
  }
}

class _SettingsTipCard extends StatelessWidget {
  const _SettingsTipCard();

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      radius: 24,
      color: AppColors.primaryLight,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Ghi lại các khoản chi nhỏ mỗi ngày để có bức tranh tài chính rõ hơn.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _themeLabel(ThemeMode themeMode) {
  return switch (themeMode) {
    ThemeMode.light => 'Đang dùng giao diện sáng',
    ThemeMode.dark => 'Đang dùng giao diện tối',
    ThemeMode.system => 'Theo cài đặt của thiết bị',
  };
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
                      fontWeight: FontWeight.w700,
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

class _ThemeModeSheet extends StatelessWidget {
  const _ThemeModeSheet({
    required this.selectedTheme,
    required this.onSelected,
  });

  final ThemeMode selectedTheme;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppSheetContainer(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            appSheetBottomPadding(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSheetHeader(
                title: 'Chọn giao diện',
                subtitle: 'Áp dụng cho toàn bộ ứng dụng.',
                showCloseButton: false,
              ),
              const SizedBox(height: 54),
              Row(
                children: [
                  Expanded(
                    child: _ThemeModeOption(
                      icon: Icons.settings_suggest_rounded,
                      label: 'Theo máy',
                      isActive: selectedTheme == ThemeMode.system,
                      onTap: () => onSelected(ThemeMode.system),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeModeOption(
                      icon: Icons.light_mode_rounded,
                      label: 'Sáng',
                      isActive: selectedTheme == ThemeMode.light,
                      onTap: () => onSelected(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeModeOption(
                      icon: Icons.dark_mode_rounded,
                      label: 'Tối',
                      isActive: selectedTheme == ThemeMode.dark,
                      onTap: () => onSelected(ThemeMode.dark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: 'Đóng',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.55)
                : AppColors.border,
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
