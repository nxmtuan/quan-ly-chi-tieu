import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/flat_card.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => _showCategoryDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          for (final type in TransactionType.values) ...[
            Text(
              type == TransactionType.income ? 'Income' : 'Expense',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            for (final category in categories.where(
              (item) => item.type == type,
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryRow(category: category),
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

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
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                _showCategoryDialog(context, ref, category: category),
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

Future<void> _showCategoryDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
}) async {
  final nameController = TextEditingController(text: category?.name ?? '');
  var type = category?.type ?? TransactionType.expense;
  var iconData = category?.iconData ?? Icons.category_rounded;
  var colorHex = category?.colorHex ?? AppColors.primary.toARGB32();

  final icons = [
    Icons.restaurant_rounded,
    Icons.shopping_bag_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.favorite_rounded,
    Icons.flight_takeoff_rounded,
    Icons.payments_rounded,
    Icons.laptop_mac_rounded,
    Icons.category_rounded,
  ];

  final colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.danger,
    AppColors.warning,
  ];

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(category == null ? 'Add Category' : 'Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Category name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<TransactionType>(
                    value: type,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: TransactionType.expense,
                        child: Text('Expense'),
                      ),
                      DropdownMenuItem(
                        value: TransactionType.income,
                        child: Text('Income'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => type = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in icons)
                        ChoiceChip(
                          selected: item == iconData,
                          label: Icon(item, size: 18),
                          onSelected: (_) => setState(() => iconData = item),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final item in colors)
                        InkWell(
                          onTap: () =>
                              setState(() => colorHex = item.toARGB32()),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: item,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorHex == item.toARGB32()
                                    ? AppColors.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    return;
                  }

                  final updatedCategory = Category(
                    id:
                        category?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name,
                    iconData: iconData,
                    colorHex: colorHex,
                    type: type,
                  );

                  if (category == null) {
                    await ref
                        .read(categoriesProvider.notifier)
                        .addCategory(updatedCategory);
                  } else {
                    await ref
                        .read(categoriesProvider.notifier)
                        .updateCategory(updatedCategory);
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
}
