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
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.appPalette.textSecondary,
      ),
      onTap: () => _showThemeSheet(context, ref),
    );
  }

  Future<void> _showThemeSheet(BuildContext context, WidgetRef ref) async {
    await showAppBottomSheet<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return _ThemeModeSheet(
              selectedTheme: ref.watch(themeModeProvider),
              onSelected: (themeMode) {
                ref.read(themeModeProvider.notifier).setThemeMode(themeMode);
                AppToast.show(
                  context,
                  message: 'Đã cập nhật giao diện',
                  type: AppToastType.success,
                );
              },
            );
          },
        );
      },
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
    return AppSheetScaffold(
      title: 'Chọn giao diện',
      subtitle: 'Áp dụng cho toàn bộ ứng dụng.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: context.scaled(24)),
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
        ],
      ),
      action: AppPrimaryButton(
        label: 'Đóng',
        color: AppColors.primary,
        onTap: () => Navigator.of(context).pop(),
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
    final color = isActive
        ? AppColors.primary
        : context.appPalette.textSecondary;

    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(10),
          vertical: context.scaled(14),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.appPalette.surface,
          borderRadius: BorderRadius.circular(context.scaled(18)),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.55)
                : context.appPalette.border,
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
              style: context.appText.bodyStrong.copyWith(
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

String _themeLabel(ThemeMode themeMode) {
  return switch (themeMode) {
    ThemeMode.light => 'Đang dùng giao diện sáng',
    ThemeMode.dark => 'Đang dùng giao diện tối',
    ThemeMode.system => 'Theo cài đặt của thiết bị',
  };
}
