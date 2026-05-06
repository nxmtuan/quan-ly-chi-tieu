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
      if (kIsWeb) {
        return InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(context.scaled(24)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaled(8),
              vertical: context.scaled(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.scaled(46),
                      height: context.scaled(46),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(
                          context.scaled(16),
                        ),
                      ),
                      child: Icon(
                        Icons.login_rounded,
                        color: AppColors.primary,
                        size: context.scaled(22),
                      ),
                    ),
                    SizedBox(width: context.scaled(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tài khoản',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: context.scaledFont(15, min: 14),
                            ),
                          ),
                          SizedBox(height: context.scaled(5)),
                          Text(
                            'Kết nối tài khoản Google',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.scaledFont(12, min: 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scaled(12)),
                SizedBox(
                  height: context.scaled(42),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: GoogleWebSignInButton(),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return _SettingsRow(
        icon: Icons.login_rounded,
        iconColor: AppColors.primary,
        title: 'Đăng nhập',
        subtitle: 'Kết nối tài khoản Google',
        trailing: const Icon(Icons.login_rounded),
        onTap: () => _signIn(context, ref),
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
      radius: context.scaled(24),
      color: AppColors.primaryLight,
      child: Row(
        children: [
          Container(
            width: context.scaled(48),
            height: context.scaled(48),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(context.scaled(15)),
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: AppColors.primary,
              size: context.scaled(22),
            ),
          ),
          SizedBox(width: context.scaled(14)),
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
      borderRadius: BorderRadius.circular(context.scaled(24)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(8),
          vertical: context.scaled(12),
        ),
        child: Row(
          children: [
            Container(
              width: context.scaled(46),
              height: context.scaled(46),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(context.scaled(16)),
              ),
              child: Icon(icon, color: iconColor, size: context.scaled(22)),
            ),
            SizedBox(width: context.scaled(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: context.scaledFont(15, min: 14),
                    ),
                  ),
                  SizedBox(height: context.scaled(5)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.scaledFont(12, min: 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.scaled(12)),
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
    return Padding(
      padding: EdgeInsets.only(left: context.scaled(66)),
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
            context.scaled(16),
            0,
            context.scaled(16),
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
              SizedBox(height: context.scaled(54)),
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
                  SizedBox(width: context.scaled(10)),
                  Expanded(
                    child: _ThemeModeOption(
                      icon: Icons.light_mode_rounded,
                      label: 'Sáng',
                      isActive: selectedTheme == ThemeMode.light,
                      onTap: () => onSelected(ThemeMode.light),
                    ),
                  ),
                  SizedBox(width: context.scaled(10)),
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
              SizedBox(height: context.scaled(18)),
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
      borderRadius: BorderRadius.circular(context.scaled(18)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(10),
          vertical: context.scaled(14),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(18)),
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
              width: context.scaled(40),
              height: context.scaled(40),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.scaled(13)),
              ),
              child: Icon(icon, color: color, size: context.scaled(20)),
            ),
            SizedBox(height: context.scaled(10)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: context.scaledFont(13, min: 12),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
