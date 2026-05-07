part of '../statistics_screen.dart';

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange, required this.onChanged});

  final String selectedRange;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const ranges = ['Week', 'Month', 'Year'];

    return Container(
      padding: EdgeInsets.all(context.scaled(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(24)),
      ),
      child: Row(
        children: [
          for (final range in ranges)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(range),
                borderRadius: BorderRadius.circular(context.scaled(18)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(vertical: context.scaled(12)),
                  decoration: BoxDecoration(
                    color: selectedRange == range
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.scaled(18)),
                  ),
                  child: Text(
                    range,
                    textAlign: TextAlign.center,
                    style: context.appText.bodyStrong.copyWith(
                      color: selectedRange == range
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: context.scaledFont(13, min: 12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
