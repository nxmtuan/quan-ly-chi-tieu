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

class _ManageCategoriesRow extends ConsumerWidget {
  const _ManageCategoriesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      icon: Icons.category_rounded,
      iconColor: AppColors.success,
      title: 'Quản lý danh mục',
      subtitle: 'Chỉnh sửa nhóm thu nhập và chi tiêu',
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: () => showCategoryManagementSheet(context, ref),
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
        return AppBounceBuilder(
          onTap: null,
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
                            style: context.appText.bodyStrong.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: context.scaledFont(15, min: 14),
                            ),
                          ),
                          SizedBox(height: context.scaled(5)),
                          Text(
                            'Kết nối tài khoản Google',
                            style: context.appText.caption.copyWith(
                              color: AppColors.textSecondary,
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
      trailing: const Icon(
        Icons.logout_rounded,
        color: AppColors.danger,
      ),
      onTap: () => _confirmSignOut(context, ref),
    );
  }

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (context.mounted && ref.read(authProvider) != null) {
        AppToast.show(
          context,
          message: 'Đăng nhập thành công',
          type: AppToastType.success,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Không thể đăng nhập Google. Vui lòng kiểm tra cấu hình OAuth.',
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi ứng dụng không?',
      confirmText: 'Đăng xuất',
      confirmBackgroundColor: const Color(0xFFFEE2E2),
      confirmTextColor: const Color(0xFFDC2626),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (!context.mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Đăng xuất thành công',
        type: AppToastType.success,
      );
    }
  }
}

class _SyncDataRow extends ConsumerStatefulWidget {
  const _SyncDataRow();

  @override
  ConsumerState<_SyncDataRow> createState() => _SyncDataRowState();
}

class _SyncDataRowState extends ConsumerState<_SyncDataRow> {
  Future<void> _showSyncSheet() async {
    await showAppBottomSheet<void>(
      context: context,
      builder: (context) => const _SyncSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(autoSyncSettingsProvider);

    return _SettingsRow(
      icon: Icons.cloud_sync_rounded,
      iconColor: AppColors.primary,
      title: 'Đồng bộ dữ liệu',
      subtitle: _syncSummary(settings),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: _showSyncSheet,
    );
  }
}

class _SyncSettingsSheet extends ConsumerStatefulWidget {
  const _SyncSettingsSheet();

  @override
  ConsumerState<_SyncSettingsSheet> createState() => _SyncSettingsSheetState();
}

class _SyncSettingsSheetState extends ConsumerState<_SyncSettingsSheet> {
  bool _isSyncing = false;
  bool _isDeletingRemote = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(autoSyncSettingsProvider);

    return AppSheetScaffold(
      title: 'Cài đặt đồng bộ',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _SettingsActionCard(
              child: Column(
                children: [
                  _InlineSettingsSwitchRow(
                    icon: Icons.sync_rounded,
                    iconColor: AppColors.primary,
                    title: 'Tự động đồng bộ',
                    subtitle: settings.enabled
                        ? 'Đang bật đồng bộ theo lịch'
                        : 'Mặc định đang tắt',
                    value: settings.enabled,
                    onChanged: (value) async {
                      await ref
                          .read(autoSyncSettingsProvider.notifier)
                          .setEnabled(value);
                      if (context.mounted) {
                        AppToast.show(
                          context,
                          message: value
                              ? 'Đã bật tự động đồng bộ'
                              : 'Đã tắt tự động đồng bộ',
                          type: AppToastType.success,
                        );
                      }
                    },
                  ),
                  const _DividerIndent(),
                  _SettingsRow(
                    icon: Icons.schedule_rounded,
                    iconColor: AppColors.textPrimary,
                    title: 'Thời gian tự động đồng bộ',
                    subtitle: _syncScheduleLabel(settings),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: settings.enabled
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.35),
                    ),
                    onTap: settings.enabled
                        ? () => _showScheduleSheet(settings)
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: context.scaled(14)),
            _SettingsActionCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.cloud_upload_rounded,
                    iconColor: AppColors.success,
                    title: 'Đồng bộ ngay lập tức',
                    subtitle: _isSyncing
                        ? 'Đang thực hiện đồng bộ dữ liệu'
                        : 'Chạy đồng bộ thủ công ngay bây giờ',
                    trailing: _isSyncing
                        ? SizedBox(
                            width: context.scaled(20),
                            height: context.scaled(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                    onTap: _isSyncing ? null : _handleSyncNow,
                  ),
                  const _DividerIndent(),
                  _SettingsRow(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: AppColors.danger,
                    title: 'Xóa dữ liệu đã đồng bộ trên Drive',
                    subtitle: _isDeletingRemote
                        ? 'Đang xóa dữ liệu trên Google Drive'
                        : 'Gỡ file đồng bộ đã lưu trên Google Drive',
                    trailing: _isDeletingRemote
                        ? SizedBox(
                            width: context.scaled(20),
                            height: context.scaled(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                    onTap: _isDeletingRemote ? null : _confirmDeleteRemoteData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      action: AppPrimaryButton(
        label: 'Đóng',
        color: AppColors.primary,
        onTap: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _showScheduleSheet(AutoSyncSettings settings) async {
    final updated = await showAppBottomSheet<AutoSyncSettings>(
      context: context,
      builder: (context) => _AutoSyncScheduleSheet(initialSettings: settings),
    );

    if (updated != null) {
      await ref.read(autoSyncSettingsProvider.notifier).save(updated);
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đã lưu lịch tự động đồng bộ',
          type: AppToastType.success,
        );
      }
    }
  }

  Future<void> _handleSyncNow() async {
    setState(() => _isSyncing = true);
    try {
      final driveApi = await ref.read(authProvider.notifier).getDriveApi();
      if (driveApi == null) {
        throw Exception('Không thể kết nối với Google Drive');
      }

      final syncService = ref.read(syncServiceProvider(driveApi));
      await syncService.syncData();
      ref.invalidate(transactionsProvider);
      ref.invalidate(categoriesProvider);

      if (mounted) {
        AppToast.show(
          context,
          message: 'Đồng bộ dữ liệu thành công',
          type: AppToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Lỗi đồng bộ: $e',
          type: AppToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _confirmDeleteRemoteData() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa dữ liệu trên Drive',
      message:
          'Bạn có chắc muốn xóa dữ liệu đã đồng bộ trên Google Drive không?',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: const Color(0xFFFEE2E2),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isDeletingRemote = true);
    try {
      final driveApi = await ref.read(authProvider.notifier).getDriveApi();
      if (driveApi == null) {
        throw Exception('Không thể kết nối với Google Drive');
      }

      final syncService = ref.read(syncServiceProvider(driveApi));
      final deleted = await syncService.deleteRemoteData();

      if (mounted) {
        AppToast.show(
          context,
          message: deleted
              ? 'Đã xóa dữ liệu đồng bộ trên Drive'
              : 'Không tìm thấy dữ liệu đồng bộ trên Drive',
          type: deleted ? AppToastType.success : AppToastType.info,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Không thể xóa dữ liệu trên Drive: $e',
          type: AppToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingRemote = false);
      }
    }
  }
}

class _AutoSyncScheduleSheet extends ConsumerStatefulWidget {
  const _AutoSyncScheduleSheet({required this.initialSettings});

  final AutoSyncSettings initialSettings;

  @override
  ConsumerState<_AutoSyncScheduleSheet> createState() =>
      _AutoSyncScheduleSheetState();
}

class _AutoSyncScheduleSheetState
    extends ConsumerState<_AutoSyncScheduleSheet> {
  late AutoSyncScheduleType _scheduleType;
  late int _hour;
  late int _minute;
  late int _weekday;

  @override
  void initState() {
    super.initState();
    _scheduleType = widget.initialSettings.scheduleType;
    _hour = widget.initialSettings.hour;
    _minute = widget.initialSettings.minute;
    _weekday = widget.initialSettings.weekday;
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Chọn lịch tự động đồng bộ',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ScheduleTypeTabs(
            selectedType: _scheduleType,
            onSelected: (type) => setState(() => _scheduleType = type),
          ),
          SizedBox(height: context.scaled(18)),
          if (_scheduleType == AutoSyncScheduleType.daily)
            _ScheduleInfoCard(
              child: _TimeSelectorRow(
                hour: _hour,
                minute: _minute,
                onTap: _pickTime,
              ),
            )
          else
            _ScheduleInfoCard(
              child: Column(
                children: [
                  _WeekdaySelector(
                    selectedWeekday: _weekday,
                    onSelected: (weekday) =>
                        setState(() => _weekday = weekday),
                  ),
                  SizedBox(height: context.scaled(14)),
                  _TimeSelectorRow(
                    hour: _hour,
                    minute: _minute,
                    onTap: _pickTime,
                  ),
                ],
              ),
            ),
        ],
      ),
      action: AppPrimaryButton(
        label: 'Lưu lịch',
        color: AppColors.primary,
        onTap: () {
          Navigator.of(context).pop(
            widget.initialSettings.copyWith(
              scheduleType: _scheduleType,
              hour: _hour,
              minute: _minute,
              weekday: _weekday,
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showAppTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );

    if (picked != null && mounted) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(22)),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _InlineSettingsSwitchRow extends StatelessWidget {
  const _InlineSettingsSwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  style: context.appText.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: context.scaledFont(15, min: 14),
                  ),
                ),
                SizedBox(height: context.scaled(5)),
                Text(
                  subtitle,
                  style: context.appText.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ScheduleTypeTabs extends StatelessWidget {
  const _ScheduleTypeTabs({
    required this.selectedType,
    required this.onSelected,
  });

  final AutoSyncScheduleType selectedType;
  final ValueChanged<AutoSyncScheduleType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaled(3)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleTypeTab(
              label: 'Theo ngày',
              isActive: selectedType == AutoSyncScheduleType.daily,
              onTap: () => onSelected(AutoSyncScheduleType.daily),
            ),
          ),
          Expanded(
            child: _ScheduleTypeTab(
              label: 'Theo tuần',
              isActive: selectedType == AutoSyncScheduleType.weekly,
              onTap: () => onSelected(AutoSyncScheduleType.weekly),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTypeTab extends StatelessWidget {
  const _ScheduleTypeTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: context.scaled(14)),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(15)),
          border: isActive
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.appText.bodyStrong.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ScheduleInfoCard extends StatelessWidget {
  const _ScheduleInfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaled(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(20)),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _TimeSelectorRow extends StatelessWidget {
  const _TimeSelectorRow({
    required this.hour,
    required this.minute,
    required this.onTap,
  });

  final int hour;
  final int minute;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return _SettingsRow(
      icon: Icons.access_time_rounded,
      iconColor: AppColors.primary,
      title: 'Thời gian',
      subtitle: 'Giờ và phút tự động đồng bộ',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            display,
            style: context.appText.bodyStrong.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: context.scaled(6)),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.selectedWeekday,
    required this.onSelected,
  });

  final int selectedWeekday;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày trong tuần',
          style: context.appText.bodyStrong.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: context.scaled(10)),
        Wrap(
          spacing: context.scaled(8),
          runSpacing: context.scaled(8),
          children: [
            for (final weekday in List.generate(7, (index) => index + 1))
              _WeekdayChip(
                label: _weekdayLabel(weekday),
                isSelected: weekday == selectedWeekday,
                onTap: () => onSelected(weekday),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(12),
          vertical: context.scaled(10),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: context.appText.bodyStrong.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: context.scaledFont(13, min: 12),
          ),
        ),
      ),
    );
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
          Expanded(
              child: Text(
                'Ghi lại các khoản chi nhỏ mỗi ngày để có bức tranh tài chính rõ hơn.',
                style: context.appText.bodyStrong.copyWith(
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

String _syncSummary(AutoSyncSettings settings) {
  if (!settings.enabled) {
    return 'Tự động đồng bộ đang tắt';
  }

  return _syncScheduleLabel(settings);
}

String _syncScheduleLabel(AutoSyncSettings settings) {
  final time =
      '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}';

  return switch (settings.scheduleType) {
    AutoSyncScheduleType.daily => 'Mỗi ngày lúc $time',
    AutoSyncScheduleType.weekly =>
      'Mỗi ${_weekdayLabel(settings.weekday).toLowerCase()} lúc $time',
  };
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    1 => 'Thứ 2',
    2 => 'Thứ 3',
    3 => 'Thứ 4',
    4 => 'Thứ 5',
    5 => 'Thứ 6',
    6 => 'Thứ 7',
    _ => 'Chủ nhật',
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
    return AppBounceBuilder(
      onTap: onTap,
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
                    style: context.appText.bodyStrong.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: context.scaledFont(15, min: 14),
                    ),
                  ),
                  SizedBox(height: context.scaled(5)),
                  Text(
                    subtitle,
                    style: context.appText.caption.copyWith(
                      color: AppColors.textSecondary,
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
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

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
