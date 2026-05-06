part of '../settings_screen.dart';

class _ThemeSettingsRow extends ConsumerWidget {
  const _ThemeSettingsRow({required this.themeMode});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      icon: Icons.dark_mode_rounded,
      iconColor: AppColors.primary,
      title: 'Theme',
      subtitle: _themeLabel(themeMode),
      trailing: DropdownButton<ThemeMode>(
        value: themeMode,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(16),
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(themeModeProvider.notifier).setThemeMode(value);
          }
        },
      ),
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
      title: 'Manage Categories',
      subtitle: 'Edit income and expense groups',
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
        title: kIsWeb ? 'Google account' : 'Sign in with Google',
        subtitle: 'Connect Google account',
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
      title: 'Sign out',
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
              'Keep logging small expenses daily for clearer insights.',
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
    ThemeMode.light => 'Light mode active',
    ThemeMode.dark => 'Dark mode active',
    ThemeMode.system => 'Follow system setting',
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
