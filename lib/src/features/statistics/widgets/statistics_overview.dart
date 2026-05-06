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
      radius: 24,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Expense Overview',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              Text(
                formatCurrency(totalExpense),
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
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
                      centerSpaceRadius: 58,
                      startDegreeOffset: -90,
                      sections: [
                        for (final item in breakdown)
                          PieChartSectionData(
                            value: item.amount,
                            color: item.category.color,
                            radius: 38,
                            title: '${item.percentage.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
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
