part of '../categories_screen.dart';

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text(
                  category.name,
                  style: context.appText.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: context.scaled(3)),
                Text(
                  category.type == TransactionType.income ? 'Thu nhập' : 'Chi tiêu',
                  style: context.appText.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _ActionIconButton(
            icon: Icons.edit_rounded,
            onTap: () => showCategoryDialog(context, ref, category: category),
          ),
          SizedBox(width: context.scaled(8)),
          _ActionIconButton(
            icon: Icons.delete_rounded,
            color: AppColors.danger,
            backgroundColor: AppColors.danger.withValues(alpha: 0.1),
            onTap: () => _deleteCategory(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa danh mục',
      message: 'Các giao dịch trong danh mục này cũng sẽ bị xóa.',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: const Color(0xFFFEE2E2),
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(transactionsProvider.notifier)
        .deleteTransactionsByCategory(category.id);
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
    this.color = AppColors.textPrimary,
    this.backgroundColor = const Color(0xFFF8FAFC),
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(38),
        height: context.scaled(38),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: color,
          size: context.scaled(18),
        ),
      ),
    );
  }
}
