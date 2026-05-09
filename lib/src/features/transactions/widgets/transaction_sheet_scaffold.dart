part of '../add_transaction_sheet.dart';

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.scaled(16),
        context.scaled(10),
        context.scaled(16),
        context.scaled(10),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaled(28)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHandle(),
          SizedBox(height: context.scaled(10)),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.appText.sheetTitle,
                ),
              ),
              AppBounceBuilder(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: context.scaled(38),
                  height: context.scaled(38),
                  decoration: BoxDecoration(
                    color: palette.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: palette.border),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow.withValues(
                          alpha: context.isDarkMode ? 0.22 : 0.08,
                        ),
                        blurRadius: context.scaled(7),
                        offset: Offset(0, context.scaled(3)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: palette.iconStrong,
                    size: context.scaled(17),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
