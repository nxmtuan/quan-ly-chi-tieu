part of '../categories_screen.dart';

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlatCard(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(16),
        vertical: context.scaled(14),
      ),
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
            child: Text(
              category.name,
              style: context.appText.bodyStrong.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                showCategoryDialog(context, ref, category: category),
            icon: Icon(Icons.edit_rounded, size: context.scaled(21)),
          ),
          IconButton(
            onPressed: () => _deleteCategory(context, ref),
            icon: Icon(
              Icons.delete_rounded,
              color: AppColors.danger,
              size: context.scaled(21),
            ),
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
