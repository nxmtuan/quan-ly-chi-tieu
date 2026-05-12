part of '../settings_screen.dart';

class _BiometricUnlockRow extends ConsumerWidget {
  const _BiometricUnlockRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(biometricLockProvider);

    return _SettingsRow(
      icon: Icons.fingerprint_rounded,
      iconColor: AppColors.primary,
      title: 'Bảo mật ứng dụng',
      subtitle: lockState.enabled
          ? lockState.lockTrigger.label
          : 'Chưa bật khóa ứng dụng',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.appPalette.textSecondary,
      ),
      onTap: () => _showBiometricLockSheet(context),
    );
  }

  Future<void> _showBiometricLockSheet(BuildContext context) async {
    await showAppBottomSheet<void>(
      context: context,
      builder: (context) => const _BiometricLockSettingsSheet(),
    );
  }
}

class _BiometricLockSettingsSheet extends ConsumerWidget {
  const _BiometricLockSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(biometricLockProvider);

    return AppSheetScaffold(
      title: 'Bảo mật ứng dụng',
      subtitle: 'Chọn cách khóa app khi bạn rời đi.',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsActionCard(
              child: _InlineSettingsSwitchRow(
                icon: Icons.fingerprint_rounded,
                iconColor: AppColors.primary,
                title: 'Mở khóa bằng sinh trắc học',
                subtitle: 'Dùng vân tay hoặc Face ID để khóa',
                value: lockState.enabled,
                onChanged: lockState.isAuthenticating
                    ? null
                    : (value) => _setBiometricUnlock(context, ref, value),
              ),
            ),
            SizedBox(height: context.scaled(14)),
            Text(
              'Thời điểm khóa ứng dụng',
              style: context.appText.sectionTitle,
            ),
            SizedBox(height: context.scaled(10)),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: lockState.enabled ? 1 : 0.45,
              child: _SettingsActionCard(
                child: Column(
                  children: [
                    _BiometricLockTriggerOption(
                      title: 'Khi tắt máy',
                      subtitle: 'Khóa khi màn hình thiết bị tắt.',
                      value: BiometricLockTrigger.onScreenOff,
                      selectedValue: lockState.lockTrigger,
                      enabled: lockState.enabled,
                    ),
                    const _DividerIndent(),
                    _BiometricLockTriggerOption(
                      title: 'Khi thoát ứng dụng',
                      subtitle: 'Khóa ngay khi rời ứng dụng.',
                      value: BiometricLockTrigger.onAppExit,
                      selectedValue: lockState.lockTrigger,
                      enabled: lockState.enabled,
                    ),
                    const _DividerIndent(),
                    _BiometricLockTriggerOption(
                      title: 'Khóa sau 2 phút rời ứng dụng',
                      subtitle: 'Khóa ứng dụng nếu rời đi quá 2 phút.',
                      value: BiometricLockTrigger.afterTwoMinutes,
                      selectedValue: lockState.lockTrigger,
                      enabled: lockState.enabled,
                    ),
                  ],
                ),
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

  Future<void> _setBiometricUnlock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      await ref.read(biometricLockProvider.notifier).disable();
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Đã tắt mở khóa bằng bảo mật thiết bị',
          type: AppToastType.success,
        );
      }
      return;
    }

    final result = await ref.read(biometricLockProvider.notifier).enable();
    if (!context.mounted) {
      return;
    }

    AppToast.show(
      context,
      message: result.success
          ? 'Đã bật mở khóa bằng bảo mật thiết bị'
          : result.message ?? 'Không thể bật mở khóa bằng bảo mật thiết bị',
      type: result.success ? AppToastType.success : AppToastType.error,
    );
  }
}

class _BiometricLockTriggerOption extends ConsumerWidget {
  const _BiometricLockTriggerOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final BiometricLockTrigger value;
  final BiometricLockTrigger selectedValue;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == selectedValue;
    final textColor = enabled
        ? context.appPalette.textPrimary
        : context.appPalette.textSecondary;

    return AppBounceBuilder(
      onTap: enabled
          ? () => ref.read(biometricLockProvider.notifier).setLockTrigger(value)
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(18),
          vertical: context.scaled(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.appText.bodyStrong.copyWith(
                      color: textColor,
                      fontSize: context.scaledFont(15, min: 14),
                    ),
                  ),
                  SizedBox(height: context.scaled(5)),
                  Text(
                    subtitle,
                    style: context.appText.caption.copyWith(
                      color: context.appPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.scaled(12)),
            selected
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : SizedBox(width: context.scaled(24)),
          ],
        ),
      ),
    );
  }
}
