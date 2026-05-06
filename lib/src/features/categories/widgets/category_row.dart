part of '../categories_screen.dart';

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlatCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.iconData, color: category.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                showCategoryDialog(context, ref, category: category),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: () => _deleteCategory(context, ref),
            icon: const Icon(Icons.delete_rounded, color: AppColors.danger),
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
