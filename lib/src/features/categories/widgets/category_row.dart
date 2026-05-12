part of '../categories_screen.dart';

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canDelete = !isDefaultCategoryId(category.id);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaled(14)),
      child: Row(
        children: [
          Container(
            width: context.scaled(44),
            height: context.scaled(44),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(context.scaled(15)),
            ),
            child: Icon(
              category.iconData,
              color: category.color,
              size: context.scaled(22),
            ),
          ),
          SizedBox(width: context.scaled(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: context.appText.bodyStrong),
                SizedBox(height: context.scaled(3)),
                Text(
                  category.type == TransactionType.income
                      ? 'Thu nhập'
                      : 'Chi tiêu',
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _ActionIconButton(
            icon: Icons.edit_rounded,
            onTap: () => showCategoryDialog(context, ref, category: category),
          ),
          if (canDelete) ...[
            SizedBox(width: context.scaled(8)),
            _ActionIconButton(
              icon: Icons.delete_rounded,
              color: AppColors.danger,
              backgroundColor: AppColors.danger.withValues(alpha: 0.1),
              onTap: () => _deleteCategory(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa danh mục',
      message:
          'Các giao dịch trong danh mục này sẽ được chuyển về Chưa phân loại.',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: context.appPalette.dangerSoft,
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(transactionsProvider.notifier)
        .reassignTransactionsByCategory(
          category.id,
          uncategorizedCategoryIdFor(category.type),
        );
    await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
    if (context.mounted) {
      AppToast.show(
        context,
        message: 'Đã xóa danh mục',
        type: AppToastType.success,
      );
    }
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(38),
        height: context.scaled(38),
        decoration: BoxDecoration(
          color: backgroundColor ?? palette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(color: palette.border),
        ),
        child: Icon(
          icon,
          color: color ?? palette.textPrimary,
          size: context.scaled(18),
        ),
      ),
    );
  }
}
