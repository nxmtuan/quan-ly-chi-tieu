part of '../add_transaction_sheet.dart';

Future<MoneySource?> showAllMoneySourcesSheet(
  BuildContext context, {
  required List<MoneySource> moneySources,
  required String? initialSelectedSourceId,
  required Color actionColor,
}) {
  return showAppBottomSheet<MoneySource>(
    context: context,
    builder: (context) => _AllMoneySourcesSheet(
      moneySources: moneySources,
      initialSelectedSourceId: initialSelectedSourceId,
      actionColor: actionColor,
    ),
  );
}

class _AllMoneySourcesSheet extends StatefulWidget {
  const _AllMoneySourcesSheet({
    required this.moneySources,
    required this.initialSelectedSourceId,
    required this.actionColor,
  });

  final List<MoneySource> moneySources;
  final String? initialSelectedSourceId;
  final Color actionColor;

  @override
  State<_AllMoneySourcesSheet> createState() => _AllMoneySourcesSheetState();
}

class _AllMoneySourcesSheetState extends State<_AllMoneySourcesSheet> {
  String? _selectedSourceId;

  @override
  void initState() {
    super.initState();
    _selectedSourceId = widget.initialSelectedSourceId;
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Chọn nguồn tiền',
      body: SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.only(bottom: context.scaled(12)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - context.scaled(16)) / 3;

            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Wrap(
                  spacing: context.scaled(8),
                  runSpacing: context.scaled(8),
                  children: [
                    for (final source in widget.moneySources)
                      SizedBox(
                        width: itemWidth,
                        child: _MoneySourceTile(
                          source: source,
                          selected: source.id == _selectedSourceId,
                          actionColor: widget.actionColor,
                          onTap: () {
                            setState(() {
                              _selectedSourceId = source.id;
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
                final createdSource = await showMoneySourceEditorSheet(context);
                if (createdSource != null && context.mounted) {
                  Navigator.of(context).pop(createdSource);
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
                  'Thêm nguồn tiền',
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
              onTap: _selectedSourceId == null
                  ? null
                  : () {
                      final source = widget.moneySources
                          .where((item) => item.id == _selectedSourceId)
                          .firstOrNull;
                      if (source != null) {
                        Navigator.of(context).pop(source);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
