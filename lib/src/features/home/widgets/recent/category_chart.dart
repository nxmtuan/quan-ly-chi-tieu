part of '../recent_transactions.dart';

enum _CategoryChartView { pie, bar }

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
      padding: EdgeInsets.all(context.scaled(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2338).withValues(alpha: 0.16),
            blurRadius: context.scaled(15),
            offset: Offset(0, context.scaled(7)),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final chartSize = width < 360
              ? context.scaled(270)
              : context.scaled(350);
          final isPieChart = _selectedChartView == _CategoryChartView.pie;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cơ cấu chi tiêu',
                      style: context.appText.sectionTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _ChartViewSwitch(
                    selectedView: _selectedChartView,
                    onSelected: _selectChartView,
                  ),
                ],
              ),
              SizedBox(height: context.scaled(12)),
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
    final chartSignature = chartItems
        .map((item) => '${item.category.id}:${item.amount}')
        .join('|');

    return PieChart(
      key: ValueKey('pie-$chartSignature'),
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
    final chartSignature = chartItems
        .map((item) => '${item.category.id}:${item.amount}')
        .join('|');
    final maxAmount = chartItems.fold<double>(
      0,
      (value, item) => item.amount > value ? item.amount : value,
    );

    return BarChart(
      key: ValueKey('bar-$chartSignature'),
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
          width: isTouched ? context.scaled(36) : context.scaled(30),
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
              fontWeight: FontWeight.w700,
              fontSize: context.scaledFont(16, min: 13),
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
        fontSize: context.scaledFont(isTouched ? 14 : 12, min: 12),
        fontWeight: FontWeight.w700,
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
    final scale = context.adaptiveScale;

    return Tooltip(
      message: '${item.category.name}: ${formatCurrency(item.amount)}',
      child: AnimatedScale(
        scale: selected ? 1.16 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Container(
          width: context.scaled(selected ? 38 : 33),
          height: context.scaled(selected ? 38 : 33),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white,
              width: 2.2 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: selected ? 0.35 : 0.15),
                blurRadius: context.scaled(selected ? 8 : 5),
                offset: Offset(0, context.scaled(selected ? 4 : 2)),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              item.category.iconData,
              color: Colors.white,
              size: context.scaled(selected ? 18 : 15),
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
        width: context.scaled(33),
        height: context.scaled(33),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white,
            width: 2.2 * context.adaptiveScale,
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.15),
              blurRadius: context.scaled(5),
              offset: Offset(0, context.scaled(2)),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            item.category.iconData,
            color: Colors.white,
            size: context.scaled(15),
          ),
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
      padding: EdgeInsets.all(context.scaled(3)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(13)),
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
      borderRadius: BorderRadius.circular(context.scaled(10)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: context.scaled(38),
        height: context.scaled(29),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(10)),
        ),
        child: Icon(
          icon,
          size: context.scaled(20),
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
