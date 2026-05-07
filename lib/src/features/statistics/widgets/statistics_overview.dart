part of '../statistics_screen.dart';

class _ExpenseOverviewCard extends StatelessWidget {
  const _ExpenseOverviewCard({
    required this.totalExpense,
    required this.breakdown,
  });

  final double totalExpense;
  final List<_BreakdownItem> breakdown;

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      radius: context.scaled(24),
      padding: EdgeInsets.all(context.scaled(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Overview',
                style: context.appText.sectionTitle,
              ),
              Text(
                formatCurrency(totalExpense),
                style: context.appText.bodyStrong.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(18)),
          SizedBox(
            height: context.scaled(208),
                child: totalExpense == 0
                ? Center(
                    child: Text(
                      'No expense data yet',
                      style: context.appText.bodyStrong.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: context.scaled(54),
                      startDegreeOffset: -90,
                      sections: [
                        for (final item in breakdown)
                          PieChartSectionData(
                            value: item.amount,
                            color: item.category.color,
                            radius: context.scaled(35),
                            title: '${item.percentage.toStringAsFixed(0)}%',
                            titleStyle: TextStyle(
                              color: Colors.white,
                              fontSize: context.scaledFont(12, min: 12),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
