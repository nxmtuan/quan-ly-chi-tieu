part of '../recent_transactions.dart';

enum _CategoryChartView { pie, bar }

class _CategoryDonutChart extends StatefulWidget {
  const _CategoryDonutChart({
    required this.items,
    required this.total,
    required this.selectedCategoryIds,
    required this.onSelectedCategoryChanged,
  });

  final List<_CategoryAmountItem> items;
  final double total;
  final Set<String> selectedCategoryIds;
  final ValueChanged<Set<String>> onSelectedCategoryChanged;

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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cơ cấu chi tiêu',
                  style: context.appText.sectionTitle,
                ),
              ),
              _ChartViewSwitch(
                selectedView: _selectedChartView,
                onSelected: _selectChartView,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = constraints.biggest.shortestSide;
                final isPieChart = _selectedChartView == _CategoryChartView.pie;

                return Align(
                  alignment: isPieChart
                      ? Alignment.center
                      : Alignment.bottomCenter,
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
                );
              },
            ),
          ),
        ],
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

    return SlideTransition(
      position: position,
      child: ScaleTransition(scale: scale, child: child),
    );
  }

  Widget _buildPieChart(
    List<_CategoryAmountItem> chartItems,
    double chartSize,
  ) {
    final chartSignature = chartItems
        .map((item) => '${item.category.id}:${item.amount}')
        .join('|');

    return TweenAnimationBuilder<double>(
      key: ValueKey('pie-progress-$chartSignature'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 920),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        final sections = <PieChartSectionData>[];
        var visibleAmount = 0.0;

        for (final entry in chartItems.indexed) {
          final sectionProgress = _staggeredProgress(
            animationValue,
            entry.$1,
            chartItems.length,
          );
          visibleAmount += entry.$2.amount * sectionProgress;
          sections.add(
            _buildSection(entry.$1, entry.$2, chartSize, sectionProgress),
          );
        }

        final remainingAmount = (widget.total - visibleAmount)
            .clamp(0.0, widget.total)
            .toDouble();
        if (remainingAmount > 0.001) {
          sections.add(
            PieChartSectionData(
              value: remainingAmount,
              color: Colors.transparent,
              radius: chartSize * 0.45,
              title: '',
              badgeWidget: const SizedBox.shrink(),
            ),
          );
        }

        return PieChart(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          PieChartData(
            centerSpaceRadius: 0,
            sectionsSpace: 4,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (event is! FlTapUpEvent) return;
                final index =
                    response?.touchedSection?.touchedSectionIndex ?? -1;
                if (index < 0 || index >= chartItems.length) return;

                final selectedItem = chartItems[index];
                final nextCategoryIds =
                    _isSameSelection(
                      widget.selectedCategoryIds,
                      selectedItem.highlightCategoryIdsOrSelf,
                    )
                    ? <String>{}
                    : selectedItem.highlightCategoryIdsOrSelf;

                setState(() {
                  _touchedIndex = _touchedIndex == index ? -1 : index;
                });
                widget.onSelectedCategoryChanged(nextCategoryIds);
              },
            ),
            sections: sections,
          ),
        );
      },
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: TweenAnimationBuilder<double>(
        key: ValueKey('bar-progress-$chartSignature'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 680),
        curve: Curves.easeOutCubic,
        builder: (context, animationValue, child) {
          return BarChart(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
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
                  if (event is! FlTapUpEvent) {
                    return;
                  }

                  final groupIndex = response?.spot?.touchedBarGroupIndex;
                  if (groupIndex == null ||
                      groupIndex < 0 ||
                      groupIndex >= chartItems.length) {
                    setState(() => _touchedBarIndex = null);
                    widget.onSelectedCategoryChanged(const {});
                    return;
                  }

                  final selectedItem = chartItems[groupIndex];
                  final nextCategoryIds =
                      _isSameSelection(
                        widget.selectedCategoryIds,
                        selectedItem.highlightCategoryIdsOrSelf,
                      )
                      ? <String>{}
                      : selectedItem.highlightCategoryIdsOrSelf;

                  setState(() {
                    _touchedBarIndex = _touchedBarIndex == groupIndex
                        ? null
                        : groupIndex;
                  });
                  widget.onSelectedCategoryChanged(nextCategoryIds);
                },
                touchTooltipData: BarTouchTooltipData(
                  direction: TooltipDirection.top,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipBorderRadius: BorderRadius.circular(6),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  tooltipMargin: 8,
                  maxContentWidth: 92,
                  getTooltipColor: (_) => const Color(0xE6333333),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < 0 || groupIndex >= chartItems.length) {
                      return null;
                    }

                    final item = chartItems[groupIndex];
                    return BarTooltipItem(
                      '${item.category.name}\n${formatCurrency(item.amount)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    );
                  },
                ),
              ),
              barGroups: [
                for (final entry in chartItems.indexed)
                  _buildBarGroup(entry.$1, entry.$2, animationValue),
              ],
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _buildBarGroup(
    int index,
    _CategoryAmountItem item,
    double animationValue,
  ) {
    final percent = ((item.amount / widget.total) * 100).round();

    return BarChartGroupData(
      x: index,
      showingTooltipIndicators: _touchedBarIndex == index
          ? const [0]
          : const [],
      barRods: [
        BarChartRodData(
          toY: item.amount * animationValue,
          width: context.scaled(54),
          color: item.color,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.scaled(6)),
          ),
          label: BarChartRodLabel(
            text: '$percent%\n${item.category.name}',
            style: TextStyle(
              color: item.color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 1.12,
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

    final visibleItems = widget.items.take(4).toList();
    final remainingItems = widget.items.skip(4).toList();
    final remainingAmount = remainingItems.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

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
        highlightCategoryIds: {
          for (final item in remainingItems) item.category.id,
        },
      ),
    ];
  }

  PieChartSectionData _buildSection(
    int index,
    _CategoryAmountItem item,
    double chartSize,
    double sectionProgress,
  ) {
    final isTouched = index == _touchedIndex;
    final percent = ((item.amount / widget.total) * 100).round();
    final isVisible = sectionProgress > 0.01;

    return PieChartSectionData(
      value: isVisible ? item.amount * sectionProgress : 0.0001,
      color: item.color.withValues(alpha: isVisible ? 1 : 0),
      radius: isTouched ? chartSize * 0.49 : chartSize * 0.45,
      cornerRadius: 10,
      title: sectionProgress > 0.82 && (percent >= 5 || isTouched)
          ? '$percent%'
          : '',
      titlePositionPercentageOffset: 0.55,
      badgeWidget: sectionProgress > 0.72
          ? Opacity(
              opacity: sectionProgress,
              child: _CategoryBadge(item: item, selected: isTouched),
            )
          : const SizedBox.shrink(),
      badgePositionPercentageOffset: 0.98,
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: isTouched ? 14.0 : 12.0,
        fontWeight: FontWeight.w700,
        shadows: const [
          Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
    );
  }

  double _staggeredProgress(double animationValue, int index, int itemCount) {
    return ((animationValue * itemCount) - index).clamp(0.0, 1.0).toDouble();
  }

  bool _isSameSelection(Set<String> left, Set<String> right) {
    return left.length == right.length && left.containsAll(right);
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.item, required this.selected});

  final _CategoryAmountItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedScale(
      scale: selected ? 1.16 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: selected ? 38.0 : 33.0,
            height: selected ? 38.0 : 33.0,
            decoration: BoxDecoration(
              color: palette.surfaceElevated,
              borderRadius: BorderRadius.circular(999),
              border: Border.fromBorderSide(
                BorderSide(color: palette.surfaceElevated, width: 2.2),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Icon(
                  item.category.iconData,
                  color: item.color,
                  size: selected ? 18.0 : 15.0,
                ),
              ),
            ),
          ),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xE6333333),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${item.category.name}\n${formatCurrency(item.amount)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BarCategoryIcon extends StatelessWidget {
  const _BarCategoryIcon({required this.item});

  final _CategoryAmountItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: palette.surfaceElevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.fromBorderSide(
              BorderSide(color: palette.surfaceElevated, width: 2.2),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Icon(item.category.iconData, color: item.color, size: 15),
            ),
          ),
        ),
      ],
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
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(13),
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
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 38,
        height: 29,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? AppColors.primary
              : context.appPalette.textSecondary,
        ),
      ),
    );
  }
}
