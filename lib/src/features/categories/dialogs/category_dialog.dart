part of '../categories_screen.dart';

Future<void> showCategoryDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
}) async {
  final nameController = TextEditingController(text: category?.name ?? '');
  var type = category?.type ?? TransactionType.expense;
  var iconData = category?.iconData ?? Icons.category_rounded;
  var colorHex = category?.colorHex ?? AppColors.primary.toARGB32();

  const colors = [
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
                      for (final item in categoryIconOptions)
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
                        AppBounceBuilder(
                          onTap: () =>
                              setState(() => colorHex = item.toARGB32()),
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
