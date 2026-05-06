part of '../add_transaction_sheet.dart';

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.scaled(16),
        context.scaled(10),
        context.scaled(16),
        context.scaled(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.scaled(20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: context.scaled(38),
                  height: context.scaled(38),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.08),
                        blurRadius: context.scaled(7),
                        offset: Offset(0, context.scaled(3)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF374151),
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
