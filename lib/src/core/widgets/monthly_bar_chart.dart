import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import '../utils/formatters.dart';

class MonthlyBarChartPoint {
  const MonthlyBarChartPoint({
    required this.label,
    required this.month,
    required this.amount,
    required this.selected,
  });

  final String label;
  final DateTime month;
  final double amount;
  final bool selected;
}

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.points,
    required this.color,
    required this.onSelected,
    this.limitAmount,
    this.showAmountLabels = false,
    this.maxYMultiplier = 1.24,
  });

  final List<MonthlyBarChartPoint> points;
  final Color color;
  final ValueChanged<DateTime> onSelected;
  final double? limitAmount;
  final bool showAmountLabels;
  final double maxYMultiplier;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final maxAmount = points.fold<double>(
      0,
      (current, item) => math.max(current, item.amount),
    );
    final chartMaxAmount = math.max(maxAmount, limitAmount ?? 0);
    final maxY = chartMaxAmount <= 0 ? 1.0 : chartMaxAmount * maxYMultiplier;
    final chartSignature = points
        .map(
          (point) =>
              '${point.month.year}-${point.month.month}:${point.amount}:${point.selected}',
        )
        .join('|');

    return TweenAnimationBuilder<double>(
      key: ValueKey('monthly-bar-$chartSignature-${limitAmount ?? 0}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 680),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            minY: 0,
            gridData: const FlGridData(show: false),
            extraLinesData: _extraLinesData(context),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions || response == null) {
                  return;
                }

                final groupIndex = response.spot?.touchedBarGroupIndex;
                if (groupIndex == null ||
                    groupIndex < 0 ||
                    groupIndex >= points.length) {
                  return;
                }

                onSelected(points[groupIndex].month);
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => palette.textPrimary,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (group.x < 0 || group.x >= points.length) {
                    return null;
                  }

                  return BarTooltipItem(
                    formatCurrency(points[group.x].amount),
                    context.appText.captionStrong.copyWith(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: context.scaled(36),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }

                    final point = points[index];
                    return SideTitleWidget(
                      meta: meta,
                      space: context.scaled(8),
                      child: Text(
                        point.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appText.caption.copyWith(
                          color: point.selected ? color : palette.textSecondary,
                          fontSize: context.scaledFont(10, min: 9),
                          fontWeight: point.selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var index = 0; index < points.length; index++)
                BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: points[index].amount * animationValue,
                      width: context.scaled(54),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(context.scaled(6)),
                      ),
                      color: points[index].selected
                          ? color
                          : points[index].amount > 0
                          ? color.withValues(alpha: 0.42)
                          : palette.surfaceMuted,
                      label: BarChartRodLabel(
                        text: showAmountLabels && points[index].amount > 0
                            ? formatCurrency(points[index].amount)
                            : '',
                        style: context.appText.captionStrong.copyWith(
                          color: palette.textSecondary,
                          fontSize: context.scaledFont(10, min: 9),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  ExtraLinesData _extraLinesData(BuildContext context) {
    final limit = limitAmount;
    if (limit == null) {
      return const ExtraLinesData();
    }

    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: limit,
          color: AppColors.primary.withValues(alpha: 0.55),
          strokeWidth: context.scaled(1.2),
          dashArray: const [7, 6],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(bottom: context.scaled(4)),
            labelResolver: (_) => formatCurrency(limit).replaceAll(' ₫', ''),
            style: context.appText.captionStrong.copyWith(
              color: AppColors.primary,
              fontSize: context.scaledFont(10, min: 9),
            ),
          ),
        ),
      ],
    );
  }
}
