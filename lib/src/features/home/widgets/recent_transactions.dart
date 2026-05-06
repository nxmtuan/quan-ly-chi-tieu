import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/flat_card.dart';
import '../../../models/category.dart';
import '../../../models/transaction.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../transactions/add_transaction_sheet.dart';

const _modernChartPalette = [
  Color(0xFFE91E63),
  Color(0xFF8E24AA),
  Color(0xFFFF7043),
  Color(0xFF00A6A6),
  Color(0xFF42A5F5),
  Color(0xFFFFC107),
  Color(0xFF7E57C2),
  Color(0xFF66BB6A),
];

enum _CategoryChartView { pie, bar }

class RecentTransactions extends ConsumerStatefulWidget {
  const RecentTransactions({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  ConsumerState<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends ConsumerState<RecentTransactions> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final items = _buildCategoryItems(categories);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 340,
          child: total == 0
              ? const FlatCard(child: Center(child: Text('Chưa có dữ liệu')))
              : _CategoryDonutChart(items: items, total: total),
        ),
        const SizedBox(height: 18),
        FlatCard(
          padding: EdgeInsets.zero,
          radius: 24,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _CategoryTabs(
                  selectedType: _selectedType,
                  onSelected: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _selectedType == TransactionType.expense
                        ? 'Chưa có khoản chi nào'
                        : 'Chưa có khoản thu nào',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                for (final entry in items.indexed)
                  _CategoryAmountRow(
                        item: entry.$2,
                        total: total,
                        showDivider: entry.$1 != items.length - 1,
                      )
                      .animate(delay: Duration(milliseconds: 38 * entry.$1))
                      .fadeIn(duration: 240.ms)
                      .slideX(
                        begin: 0.04,
                        end: 0,
                        duration: 280.ms,
                        curve: Curves.easeOutCubic,
                      ),
            ],
          ),
        ),
      ],
    );
  }

  List<_CategoryAmountItem> _buildCategoryItems(List<Category> categories) {
    final totals = <String, double>{};

    for (final transaction in widget.transactions) {
      if (transaction.type != _selectedType) {
        continue;
      }

      totals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final items = [
      for (final entry in totals.entries)
        _CategoryAmountItem(
          category: categories.firstWhere(
            (category) => category.id == entry.key,
            orElse: () => Category(
              id: entry.key,
              name: 'Khác',
              iconData: Icons.category_rounded,
              colorHex: AppColors.textSecondary.toARGB32(),
              type: _selectedType,
            ),
          ),
          amount: entry.value,
          color: AppColors.textSecondary,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return [
      for (final entry in items.indexed)
        _CategoryAmountItem(
          category: entry.$2.category,
          amount: entry.$2.amount,
          color: _modernChartPalette[entry.$1 % _modernChartPalette.length],
        ),
    ];
  }
}

class _CategoryDonutChart extends StatefulWidget {
  const _CategoryDonutChart({required this.items, required this.total});

  final List<_CategoryAmountItem> items;
  final double total;

  @override
  State<_CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<_CategoryDonutChart> {
  int _touchedIndex = -1;
  int? _touchedBarIndex;
  _CategoryChartView _selectedChartView = _CategoryChartView.pie;
  bool _isForwardChartTransition = true;

  @override
  Widget build(BuildContext context) {
    final chartItems = _chartItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2338).withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final chartSize = width < 360 ? 210.0 : 232.0;
          final isPieChart = _selectedChartView == _CategoryChartView.pie;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cơ cấu chi tiêu',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  _ChartViewSwitch(
                    selectedView: _selectedChartView,
                    onSelected: _selectChartView,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: isPieChart ? chartSize : width,
                    height: chartSize,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 360),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: _buildChartTransition,
                      layoutBuilder: (currentChild, previousChildren) {
                        return currentChild ?? const SizedBox.shrink();
                      },
                      child: isPieChart
                          ? _buildPieChart(chartItems, chartSize)
                          : _buildBarChart(chartItems),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _selectChartView(_CategoryChartView view) {
    if (view == _selectedChartView) {
      return;
    }

    setState(() {
      _isForwardChartTransition = view.index > _selectedChartView.index;
      _selectedChartView = view;
      _touchedIndex = -1;
      _touchedBarIndex = null;
    });
  }

  Widget _buildChartTransition(Widget child, Animation<double> animation) {
    final isIncoming = child.key == ValueKey(_selectedChartView);
    final incomingOffset = Offset(_isForwardChartTransition ? 0.18 : -0.18, 0);
    final outgoingOffset = Offset(_isForwardChartTransition ? -0.18 : 0.18, 0);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoingAnimation = ReverseAnimation(curvedAnimation);
    final position = isIncoming
        ? Tween<Offset>(
            begin: incomingOffset,
            end: Offset.zero,
          ).animate(curvedAnimation)
        : Tween<Offset>(
            begin: Offset.zero,
            end: outgoingOffset,
          ).animate(outgoingAnimation);
    final scale = isIncoming
        ? Tween<double>(begin: 0.96, end: 1).animate(curvedAnimation)
        : Tween<double>(begin: 1, end: 0.96).animate(outgoingAnimation);

    return ClipRect(
      child: SlideTransition(
        position: position,
        child: ScaleTransition(scale: scale, child: child),
      ),
    );
  }

  Widget _buildPieChart(
    List<_CategoryAmountItem> chartItems,
    double chartSize,
  ) {
    return PieChart(
      key: const ValueKey(_CategoryChartView.pie),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      PieChartData(
        centerSpaceRadius: 0,
        sectionsSpace: 4,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            final touchedSection = response?.touchedSection;
            final index = touchedSection?.touchedSectionIndex ?? -1;

            if (!event.isInterestedForInteractions ||
                index < 0 ||
                index >= chartItems.length) {
              if (_touchedIndex != -1) {
                setState(() => _touchedIndex = -1);
              }
              return;
            }

            if (_touchedIndex != index) {
              setState(() => _touchedIndex = index);
            }
          },
        ),
        sections: [
          for (final entry in chartItems.indexed)
            _buildSection(entry.$1, entry.$2, chartSize),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<_CategoryAmountItem> chartItems) {
    final maxAmount = chartItems.fold<double>(
      0,
      (value, item) => item.amount > value ? item.amount : value,
    );

    return BarChart(
      key: const ValueKey(_CategoryChartView.bar),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutQuad,
      BarChartData(
        minY: 0,
        maxY: maxAmount == 0 ? 1 : maxAmount * 1.28,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartItems.length) {
                  return const SizedBox.shrink();
                }

                final item = chartItems[index];

                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: _BarCategoryIcon(item: item),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            final groupIndex = response?.spot?.touchedBarGroupIndex;

            if (event.isInterestedForInteractions && groupIndex != null) {
              if (_touchedBarIndex != groupIndex) {
                setState(() => _touchedBarIndex = groupIndex);
              }
              return;
            }

            if (_touchedBarIndex != null) {
              setState(() => _touchedBarIndex = null);
            }
          },
        ),
        barGroups: [
          for (final entry in chartItems.indexed)
            _buildBarGroup(entry.$1, entry.$2),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int index, _CategoryAmountItem item) {
    final isTouched = index == _touchedBarIndex;
    final percent = ((item.amount / widget.total) * 100).round();

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: item.amount,
          width: isTouched ? 30 : 24,
          gradient: LinearGradient(
            colors: [item.color.withValues(alpha: 0.62), item.color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(9),
          label: BarChartRodLabel(
            text: '$percent%',
            style: TextStyle(
              color: item.color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              shadows: const [
                Shadow(
                  color: Colors.white,
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_CategoryAmountItem> get _chartItems {
    if (widget.items.length <= 4) {
      return widget.items;
    }

    final visibleItems = widget.items.take(3).toList();
    final remainingAmount = widget.items
        .skip(3)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return [
      ...visibleItems,
      _CategoryAmountItem(
        category: Category(
          id: 'remaining',
          name: 'Còn lại',
          iconData: Icons.more_horiz_rounded,
          colorHex: const Color(0xFFFFC107).toARGB32(),
          type: visibleItems.first.category.type,
        ),
        amount: remainingAmount,
        color: const Color(0xFFFFC107),
      ),
    ];
  }

  PieChartSectionData _buildSection(
    int index,
    _CategoryAmountItem item,
    double chartSize,
  ) {
    final isTouched = index == _touchedIndex;
    final percent = ((item.amount / widget.total) * 100).round();

    return PieChartSectionData(
      value: item.amount,
      color: item.color,
      radius: isTouched ? chartSize * 0.39 : chartSize * 0.35,
      cornerRadius: 10,
      title: percent >= 5 || isTouched ? '$percent%' : '',
      titlePositionPercentageOffset: 0.55,
      badgeWidget: _CategoryBadge(item: item, selected: isTouched),
      badgePositionPercentageOffset: 0.98,
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: isTouched ? 16 : 14,
        fontWeight: FontWeight.w900,
        shadows: const [
          Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.item, required this.selected});

  final _CategoryAmountItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${item.category.name}: ${formatCurrency(item.amount)}',
      child: AnimatedScale(
        scale: selected ? 1.16 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Container(
          width: selected ? 42 : 36,
          height: selected ? 42 : 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF111827), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.26 : 0.18),
                blurRadius: selected ? 10 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              item.category.iconData,
              color: item.color,
              size: selected ? 20 : 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarCategoryIcon extends StatelessWidget {
  const _BarCategoryIcon({required this.item});

  final _CategoryAmountItem item;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${item.category.name}: ${formatCurrency(item.amount)}',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: item.color.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.12),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(item.category.iconData, color: item.color, size: 17),
        ),
      ),
    );
  }
}

class _ChartViewSwitch extends StatelessWidget {
  const _ChartViewSwitch({
    required this.selectedView,
    required this.onSelected,
  });

  final _CategoryChartView selectedView;
  final ValueChanged<_CategoryChartView> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChartViewButton(
            icon: Icons.pie_chart_rounded,
            isSelected: selectedView == _CategoryChartView.pie,
            onTap: () => onSelected(_CategoryChartView.pie),
          ),
          _ChartViewButton(
            icon: Icons.bar_chart_rounded,
            isSelected: selectedView == _CategoryChartView.bar,
            onTap: () => onSelected(_CategoryChartView.bar),
          ),
        ],
      ),
    );
  }
}

class _ChartViewButton extends StatelessWidget {
  const _ChartViewButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 42,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selectedType, required this.onSelected});

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CategoryTab(
              label: 'Chi tiêu',
              isSelected: selectedType == TransactionType.expense,
              color: AppColors.danger,
              onTap: () => onSelected(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _CategoryTab(
              label: 'Thu nhập',
              isSelected: selectedType == TransactionType.income,
              color: AppColors.success,
              onTap: () => onSelected(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CategoryAmountRow extends StatelessWidget {
  const _CategoryAmountRow({
    required this.item,
    required this.total,
    required this.showDivider,
  });

  final _CategoryAmountItem item;
  final double total;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((item.amount / total) * 100).round();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.category.iconData,
                  color: item.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(item.amount),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: Divider(height: 1, color: AppColors.border),
          ),
      ],
    );
  }
}

class _CategoryAmountItem {
  const _CategoryAmountItem({
    required this.category,
    required this.amount,
    required this.color,
  });

  final Category category;
  final double amount;
  final Color color;
}

class TransactionRow extends ConsumerWidget {
  const TransactionRow({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TransactionRow(
      transaction: transaction,
      category: ref.watch(categoryByIdProvider(transaction.categoryId)),
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  const _TransactionRow({required this.transaction, required this.category});

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = transaction.isExpense ? AppColors.danger : AppColors.success;
    final sign = transaction.isExpense ? '-' : '+';

    return FlatCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 24,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (category?.color ?? color).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              category?.iconData ?? Icons.wallet_rounded,
              color: category?.color ?? color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note.isEmpty
                      ? category?.name ?? 'Transaction'
                      : transaction.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${category?.name ?? 'Other'} • ${formatShortDate(transaction.date)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${formatCurrency(transaction.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    showAddTransactionSheet(context, transaction: transaction);
                  }
                  if (value == 'delete') {
                    ref
                        .read(transactionsProvider.notifier)
                        .deleteTransaction(transaction.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
