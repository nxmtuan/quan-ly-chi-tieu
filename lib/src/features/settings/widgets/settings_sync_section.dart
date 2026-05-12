part of '../settings_screen.dart';

class _SyncDataRow extends ConsumerStatefulWidget {
  const _SyncDataRow();

  @override
  ConsumerState<_SyncDataRow> createState() => _SyncDataRowState();
}

class _SyncDataRowState extends ConsumerState<_SyncDataRow> {
  Future<void> _showSyncSheet() async {
    ref.read(autoSyncStatusProvider.notifier).reload();
    await showAppBottomSheet<void>(
      context: context,
      builder: (context) => const _SyncSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(autoSyncSettingsProvider);
    final syncStatus = ref.watch(autoSyncStatusProvider);

    return _SettingsRow(
      icon: Icons.cloud_sync_rounded,
      iconColor: AppColors.primary,
      title: 'Đồng bộ dữ liệu',
      subtitle: _syncSummary(settings, syncStatus),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.appPalette.textSecondary,
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
    final syncStatus = ref.watch(autoSyncStatusProvider);

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
                    subtitle: _autoSyncSwitchSubtitle(
                      syncStatus,
                      enabled: settings.enabled,
                    ),
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
                    iconColor: context.appPalette.textPrimary,
                    title: 'Thời gian tự động đồng bộ',
                    subtitle: _syncScheduleLabel(settings),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: settings.enabled
                          ? context.appPalette.textSecondary
                          : context.appPalette.textSecondary.withValues(
                              alpha: 0.35,
                            ),
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
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: context.appPalette.textSecondary,
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
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: context.appPalette.textSecondary,
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
        if (mounted) {
          AppToast.show(
            context,
            message: _driveConnectionErrorMessage(),
            type: AppToastType.error,
          );
        }
        return;
      }

      final syncService = ref.read(syncServiceProvider(driveApi));
      await syncService.syncData();
      await ref
          .read(autoSyncStatusProvider.notifier)
          .markSuccess(DateTime.now());
      ref.read(transactionsProvider.notifier).reload();
      ref.read(categoriesProvider.notifier).reload();
      ref.read(moneySourcesProvider.notifier).reload();
      ref.read(savingsGoalsProvider.notifier).reload();
      ref.read(recurringItemsProvider.notifier).reload();

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
          message: 'Đồng bộ thất bại. Vui lòng thử lại.',
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
      confirmBackgroundColor: context.appPalette.dangerSoft,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isDeletingRemote = true);
    try {
      final driveApi = await ref.read(authProvider.notifier).getDriveApi();
      if (driveApi == null) {
        if (mounted) {
          AppToast.show(
            context,
            message: _driveConnectionErrorMessage(),
            type: AppToastType.error,
          );
        }
        return;
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

  String _driveConnectionErrorMessage() {
    final authUser = ref.read(authProvider);
    if (authUser == null) {
      return 'Phiên Google đã hết hạn. Vui lòng đăng nhập lại để tiếp tục đồng bộ.';
    }

    return 'Kết nối Google Drive đang tạm thời không ổn định. Vui lòng thử lại.';
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
                    onSelected: (weekday) => setState(() => _weekday = weekday),
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

class _ScheduleTypeTabs extends StatelessWidget {
  const _ScheduleTypeTabs({
    required this.selectedType,
    required this.onSelected,
  });

  final AutoSyncScheduleType selectedType;
  final ValueChanged<AutoSyncScheduleType> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.all(context.scaled(3)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: palette.border),
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
            color: isActive
                ? AppColors.primary
                : context.appPalette.textSecondary,
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
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.all(context.scaled(14)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(20)),
        border: Border.all(color: palette.border),
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
    final display =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return _SettingsRow(
      icon: Icons.access_time_rounded,
      iconColor: AppColors.primary,
      title: 'Thời gian',
      subtitle: 'Giờ và phút tự động đồng bộ',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(display, style: context.appText.bodyStrong),
          SizedBox(width: context.scaled(6)),
          Icon(
            Icons.chevron_right_rounded,
            color: context.appPalette.textSecondary,
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
        Text('Ngày trong tuần', style: context.appText.bodyStrong),
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
              : context.appPalette.surface,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.35)
                : context.appPalette.border,
          ),
        ),
        child: Text(
          label,
          style: context.appText.bodyStrong.copyWith(
            color: isSelected
                ? AppColors.primary
                : context.appPalette.textPrimary,
            fontSize: context.scaledFont(13, min: 12),
          ),
        ),
      ),
    );
  }
}

String _syncSummary(AutoSyncSettings settings, AutoSyncStatus status) {
  final syncSubtitle = _autoSyncSwitchSubtitle(
    status,
    enabled: settings.enabled,
  );
  if (syncSubtitle !=
      (settings.enabled
          ? 'Đang bật đồng bộ theo lịch'
          : 'Tự động đồng bộ đang tắt')) {
    return syncSubtitle;
  }

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

String _autoSyncSwitchSubtitle(AutoSyncStatus status, {required bool enabled}) {
  if (status.type == AutoSyncStatusType.success &&
      status.lastSuccessAt != null) {
    final formatted = DateFormat(
      'HH:mm dd/MM/yyyy',
    ).format(status.lastSuccessAt!.toLocal());
    return 'Đã đồng bộ thành công lúc $formatted';
  }

  if (status.type == AutoSyncStatusType.failure && status.retryAt != null) {
    final remainingMinutes = _remainingRetryMinutes(status.retryAt!);
    if (remainingMinutes != null) {
      return 'Đồng bộ thất bại, thử lại sau $remainingMinutes phút';
    }
  }

  return enabled ? 'Đang bật đồng bộ theo lịch' : 'Tự động đồng bộ đang tắt';
}

int? _remainingRetryMinutes(DateTime retryAt) {
  final difference = retryAt.difference(DateTime.now());
  if (difference.isNegative || difference.inSeconds <= 0) {
    return null;
  }

  return ((difference.inSeconds / 60).ceil()).clamp(1, 9999).toInt();
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
