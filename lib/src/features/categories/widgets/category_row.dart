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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: const Text(
            'Transactions in this category will also be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(transactionsProvider.notifier)
        .deleteTransactionsByCategory(category.id);
    await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
  }
}
