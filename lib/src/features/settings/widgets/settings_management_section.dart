part of '../settings_screen.dart';

class _ManageCategoriesRow extends ConsumerWidget {
  const _ManageCategoriesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      icon: Icons.category_rounded,
      iconColor: AppColors.success,
      title: 'Quản lý danh mục',
      subtitle: 'Chỉnh sửa nhóm thu nhập và chi tiêu',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.appPalette.textSecondary,
      ),
      onTap: () => showCategoryManagementSheet(context, ref),
    );
  }
}

class _ManageMoneySourcesRow extends ConsumerWidget {
  const _ManageMoneySourcesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: AppColors.primary,
      title: 'Quản lý nguồn tiền',
      subtitle: 'Chỉnh sửa danh sách nguồn tiền',
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.appPalette.textSecondary,
      ),
      onTap: () => showMoneySourceManagementSheet(context, ref),
    );
  }
}
