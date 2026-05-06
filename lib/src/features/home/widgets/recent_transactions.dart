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
          height: 304,
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

  @override
  Widget build(BuildContext context) {
    final chartItems = _chartItems;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cơ cấu chi tiêu',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Theo danh mục',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Tháng này',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final chartSize = width < 360 ? 170.0 : 190.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ChartConnectorPainter(items: chartItems),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.08),
                      child: SizedBox(
                        width: chartSize,
                        height: chartSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              PieChartData(
                                centerSpaceRadius: chartSize * 0.26,
                                sectionsSpace: 4,
                                startDegreeOffset: -90,
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    final touchedSection =
                                        response?.touchedSection;
                                    final index =
                                        touchedSection?.touchedSectionIndex ??
                                        -1;

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
                                    _buildSection(
                                      entry.$1,
                                      entry.$2,
                                      chartSize,
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              width: chartSize * 0.43,
                              height: chartSize * 0.43,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Icon(
                                Icons.bar_chart_rounded,
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.9,
                                ),
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (chartItems.length > 1)
                      Positioned(
                        left: 0,
                        top: 68,
                        child: _ChartLabel(
                          item: chartItems[1],
                          percent: _percent(chartItems[1]),
                          selected: _touchedIndex == 1,
                          onTap: () => setState(() => _touchedIndex = 1),
                        ),
                      ),
                    if (chartItems.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 168,
                        child: _ChartLabel(
                          item: chartItems[0],
                          percent: _percent(chartItems[0]),
                          selected: _touchedIndex == 0,
                          onTap: () => setState(() => _touchedIndex = 0),
                        ),
                      ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ChartDotIndicator(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _percent(_CategoryAmountItem item) {
    return ((item.amount / widget.total) * 100).round();
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
    final percent = _percent(item);

    return PieChartSectionData(
      value: item.amount,
      color: item.color,
      radius: isTouched ? chartSize * 0.31 : chartSize * 0.29,
      cornerRadius: 12,
      title: percent >= 5 || isTouched ? '$percent%' : '',
      titlePositionPercentageOffset: 0.64,
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: isTouched ? 17 : 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  const _ChartLabel({
    required this.item,
    required this.percent,
    required this.selected,
    required this.onTap,
  });

  final _CategoryAmountItem item;
  final int percent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedScale(
        scale: selected ? 1.06 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 112,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: selected ? 0.16 : 0.06),
                blurRadius: selected ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.category.iconData, color: item.color),
              ),
              const SizedBox(width: 9),
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
                    const SizedBox(height: 2),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartDotIndicator extends StatelessWidget {
  const _ChartDotIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _ChartConnectorPainter extends CustomPainter {
  const _ChartConnectorPainter({required this.items});

  final List<_CategoryAmountItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 13);
    if (items.length > 1) {
      _drawDashedLine(
        canvas,
        const Offset(104, 98),
        Offset(center.dx - 68, center.dy - 48),
        items[1].color,
      );
    }
    if (items.isNotEmpty) {
      _drawDashedLine(
        canvas,
        Offset(center.dx + 72, center.dy + 56),
        Offset(size.width - 112, 193),
        items[0].color,
      );
      final paint = Paint()
        ..color = items[0].color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(center.dx + 72, center.dy + 56), 4, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    if (distance <= 0) {
      return;
    }

    final direction = (end - start) / distance;
    var progress = 0.0;
    while (progress < distance) {
      final dashStart = start + direction * progress;
      final dashEnd =
          start + direction * (progress + dashWidth).clamp(0, distance);
      canvas.drawLine(dashStart, dashEnd, paint);
      progress += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _ChartConnectorPainter oldDelegate) {
    return oldDelegate.items != items;
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
        padding: const EdgeInsets.only(bottom: 12),
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
