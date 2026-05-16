part of '../add_transaction_sheet.dart';

Future<Category?> showAllCategoriesSheet(
  BuildContext context, {
  required List<Category> categories,
  required String? initialSelectedCategoryId,
  required TransactionType transactionType,
  required Color actionColor,
  Set<String> disabledCategoryIds = const {},
}) {
  return showAppBottomSheet<Category>(
    context: context,
    builder: (context) => _AllCategoriesSheet(
      categories: categories,
      initialSelectedCategoryId: initialSelectedCategoryId,
      transactionType: transactionType,
      actionColor: actionColor,
      disabledCategoryIds: disabledCategoryIds,
    ),
  );
}

class _AllCategoriesSheet extends StatefulWidget {
  const _AllCategoriesSheet({
    required this.categories,
    required this.initialSelectedCategoryId,
    required this.transactionType,
    required this.actionColor,
    required this.disabledCategoryIds,
  });

  final List<Category> categories;
  final String? initialSelectedCategoryId;
  final TransactionType transactionType;
  final Color actionColor;
  final Set<String> disabledCategoryIds;

  @override
  State<_AllCategoriesSheet> createState() => _AllCategoriesSheetState();
}

class _AllCategoriesSheetState extends State<_AllCategoriesSheet> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId =
        widget.disabledCategoryIds.contains(widget.initialSelectedCategoryId)
        ? null
        : widget.initialSelectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Chọn danh mục',
      body: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(bottom: context.scaled(12)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - context.scaled(24)) / 4;

            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Wrap(
                  spacing: context.scaled(8),
                  runSpacing: context.scaled(8),
                  children: [
                    for (final category in widget.categories)
                      SizedBox(
                        width: itemWidth,
                        child: _CategoryTile(
                          category: category,
                          selected: category.id == _selectedCategoryId,
                          enabled: !widget.disabledCategoryIds.contains(
                            category.id,
                          ),
                          actionColor: widget.actionColor,
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () async {
                final createdCategory = await showCategoryEditorSheet(
                  context,
                  initialType: widget.transactionType,
                );
                if (createdCategory != null && context.mounted) {
                  Navigator.of(context).pop(createdCategory);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: context.appPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                  border: Border.all(color: context.appPalette.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Thêm danh mục',
                  style: context.appText.buttonLabel.copyWith(
                    color: context.appPalette.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: AppPrimaryButton(
              label: 'Chọn',
              color: widget.actionColor,
              onTap:
                  _selectedCategoryId == null ||
                      widget.disabledCategoryIds.contains(_selectedCategoryId)
                  ? null
                  : () {
                      final category = widget.categories
                          .where((item) => item.id == _selectedCategoryId)
                          .firstOrNull;
                      if (category != null) {
                        Navigator.of(context).pop(category);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
