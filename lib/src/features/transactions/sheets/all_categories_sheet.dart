part of '../add_transaction_sheet.dart';

Future<Category?> showAllCategoriesSheet(
  BuildContext context, {
  required List<Category> categories,
  required String? initialSelectedCategoryId,
  required Color actionColor,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _AllCategoriesSheet(
        categories: categories,
        initialSelectedCategoryId: initialSelectedCategoryId,
        actionColor: actionColor,
      );
    },
  );
}

class _AllCategoriesSheet extends StatefulWidget {
  const _AllCategoriesSheet({
    required this.categories,
    required this.initialSelectedCategoryId,
    required this.actionColor,
  });

  final List<Category> categories;
  final String? initialSelectedCategoryId;
  final Color actionColor;

  @override
  State<_AllCategoriesSheet> createState() => _AllCategoriesSheetState();
}

class _AllCategoriesSheetState extends State<_AllCategoriesSheet> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialSelectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetContainer(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.scaled(16),
            0,
            context.scaled(16),
            appSheetBottomPadding(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSheetHeader(
                title: 'Chọn danh mục',
                subtitle: 'Hiển thị toàn bộ danh mục của nhóm hiện tại.',
              ),
              SizedBox(height: context.scaled(14)),
              Flexible(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth =
                          (constraints.maxWidth - context.scaled(24)) / 4;

                      return Wrap(
                        spacing: context.scaled(8),
                        runSpacing: context.scaled(8),
                        children: [
                          for (final category in widget.categories)
                            SizedBox(
                              width: itemWidth,
                              child: _CategoryTile(
                                category: category,
                                selected: category.id == _selectedCategoryId,
                                actionColor: widget.actionColor,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = category.id;
                                  });
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: context.scaled(16)),
              AppPrimaryButton(
                label: 'Chọn',
                color: widget.actionColor,
                onTap: _selectedCategoryId == null
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
            ],
          ),
        ),
      ),
    );
  }
}
