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
              const Text(
                'Expense Overview',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              Text(
                formatCurrency(totalExpense),
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(18)),
          SizedBox(
            height: context.scaled(208),
            child: totalExpense == 0
                ? const Center(
                    child: Text(
                      'No expense data yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
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
                              fontSize: context.scaled(11),
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
