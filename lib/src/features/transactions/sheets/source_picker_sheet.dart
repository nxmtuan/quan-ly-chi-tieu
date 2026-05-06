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
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSheetHandle(),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chọn nguồn tiền',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final source in ['Tiền mặt', 'Chuyển khoản', 'Khác'])
              _SourceOptionTile(
                source: source,
                selected: source == selectedSource,
                onTap: () => Navigator.of(context).pop(source),
              ),
          ],
        ),
      ),
    );
  }
}
