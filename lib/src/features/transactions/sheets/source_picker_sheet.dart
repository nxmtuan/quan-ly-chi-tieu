part of '../add_transaction_sheet.dart';

Future<String?> showTransactionSourceSheet(
  BuildContext context, {
  required String selectedSource,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _SourcePickerSheet(selectedSource: selectedSource);
    },
  );
}

class _SourcePickerSheet extends StatelessWidget {
  const _SourcePickerSheet({required this.selectedSource});

  final String selectedSource;

  @override
  Widget build(BuildContext context) {
    return AppSheetContainer(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            appSheetBottomPadding(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSheetHeader(
                title: 'Chọn nguồn tiền',
                showCloseButton: false,
              ),
              const SizedBox(height: 54),
              Row(
                children: [
                  for (final entry in ['Tiền mặt', 'Chuyển khoản', 'Khác'].indexed) ...[
                    Expanded(
                      child: _SourceSheetOption(
                        source: entry.$2,
                        icon: _sourceIcon(entry.$2),
                        selected: entry.$2 == selectedSource,
                        onTap: () => Navigator.of(context).pop(entry.$2),
                      ),
                    ),
                    if (entry.$1 != 2) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: 'Đóng',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSheetOption extends StatelessWidget {
  const _SourceSheetOption({
    required this.source,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String source;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.55)
                : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              source,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _sourceIcon(String source) {
  return switch (source) {
    'Tiền mặt' => Icons.payments_rounded,
    'Chuyển khoản' => Icons.swap_horiz_rounded,
    _ => Icons.account_balance_wallet_rounded,
  };
}
