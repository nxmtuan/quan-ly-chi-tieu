part of '../statistics_screen.dart';

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange, required this.onChanged});

  final StatisticsRange selectedRange;
  final ValueChanged<StatisticsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    const ranges = StatisticsRange.values;
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.all(context.scaled(6)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(24)),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          for (final range in ranges)
            Expanded(
              child: AppBounceBuilder(
                onTap: () => onChanged(range),
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
                    switch (range) {
                      StatisticsRange.week => 'Week',
                      StatisticsRange.month => 'Month',
                      StatisticsRange.year => 'Year',
                    },
                    textAlign: TextAlign.center,
                    style: context.appText.bodyStrong.copyWith(
                      color: selectedRange == range
                          ? Colors.white
                          : palette.textSecondary,
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
