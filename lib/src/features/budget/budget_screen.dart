import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/flat_card.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../home/models/home_summary_scope.dart';
import '../home/widgets/summary_card.dart';
import 'budget_detail_sheet.dart';
import 'budget_sheet.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsForMonthProvider(_selectedMonth));
    final spentByCategory = ref.watch(
      budgetSpentByCategoryProvider(_selectedMonth),
    );
    final categories = ref.watch(
      categoriesByTypeProvider(TransactionType.expense),
    );
    final categoriesById = {
      for (final category in categories) category.id: category,
    };

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child:
          ListView(
                padding: EdgeInsets.fromLTRB(
                  context.scaled(24),
                  context.scaled(22),
                  context.scaled(24),
                  context.scaled(176) + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  const AppPageHeader(
                    subtitle: 'Ngân sách',
                    title: 'Theo dõi hạn mức',
                  ),
                  SizedBox(height: context.scaled(20)),
                  _MonthControl(
                    month: _selectedMonth,
                    onPick: _pickMonth,
                    onPrevious: () => setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    }),
                    onNext: () => setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    }),
                  ),
                  SizedBox(height: context.scaled(18)),
                  _BudgetListHeader(
                    count: budgets.length,
                    onAdd: () => showBudgetSheet(context),
                  ),
                  SizedBox(height: context.scaled(12)),
                  if (budgets.isEmpty)
                    _EmptyBudgetCard(
                      hasExpenseCategories: categories.isNotEmpty,
                      onAdd: categories.isEmpty
                          ? null
                          : () => showBudgetSheet(context),
                    )
                  else
                    for (final budget in budgets)
                      Padding(
                        padding: EdgeInsets.only(bottom: context.scaled(12)),
                        child: _BudgetCard(
                          budget: budget,
                          category: categoriesById[budget.categoryId],
                          spentAmount: spentByCategory[budget.categoryId] ?? 0,
                        ),
                      ),
                ],
              )
              .animate()
              .fadeIn(duration: 260.ms)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: 340.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }

  Future<void> _pickMonth() async {
    final selectedScope = await showMonthPickerSheet(
      context,
      initialScope: HomeSummaryScope.month(_selectedMonth),
      lastMonth: DateTime.now(),
    );

    final anchor = selectedScope?.anchor;
    if (anchor == null || !mounted) {
      return;
    }

    setState(() => _selectedMonth = DateTime(anchor.year, anchor.month));
  }
}

class _MonthControl extends StatelessWidget {
  const _MonthControl({
    required this.month,
    required this.onPick,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPick;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(8),
        vertical: context.scaled(8),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _MonthIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          Expanded(
            child: AppBounceBuilder(
              onTap: onPick,
              child: Text(
                formatMonthYear(month),
                textAlign: TextAlign.center,
                style: context.appText.bodyStrong.copyWith(
                  fontSize: context.scaledFont(15, min: 14),
                ),
              ),
            ),
          ),
          _MonthIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _MonthIconButton extends StatelessWidget {
  const _MonthIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(38),
        height: context.scaled(38),
        decoration: BoxDecoration(
          color: context.appPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(14)),
        ),
        child: Icon(
          icon,
          color: context.appPalette.textPrimary,
          size: context.scaled(22),
        ),
      ),
    );
  }
}

class _SummaryAmount extends StatelessWidget {
  const _SummaryAmount({
    required this.label,
    required this.value,
    this.alignCenter = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignCenter;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : alignCenter
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: context.appText.caption.copyWith(
            color: context.appPalette.textSecondary,
          ),
        ),
        SizedBox(height: context.scaled(3)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd
              ? TextAlign.end
              : alignCenter
              ? TextAlign.center
              : TextAlign.start,
          style: context.appText.captionStrong.copyWith(
            color: context.appPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BudgetListHeader extends StatelessWidget {
  const _BudgetListHeader({required this.count, required this.onAdd});

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Danh mục đã đặt $count',
            style: context.appText.bodyStrong,
          ),
        ),
        AppBounceBuilder(
          onTap: onAdd,
          child: Container(
            width: context.scaled(38),
            height: context.scaled(38),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: context.scaled(24),
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.category,
    required this.spentAmount,
  });

  final Budget budget;
  final Category? category;
  final double spentAmount;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final status = _BudgetStatus.fromBudget(budget, spentAmount);
    final progress = budget.progressWith(spentAmount);
    final percent = budget.usagePercentWith(spentAmount);
    final categoryColor = category?.color ?? AppColors.primary;

    return AppBounceBuilder(
      onTap: () => showBudgetDetailSheet(
        context,
        budget: budget,
        category: category,
        spentAmount: spentAmount,
      ),
      child: FlatCard(
        showShadow: false,
        radius: context.scaled(24),
        padding: EdgeInsets.all(context.scaled(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.scaled(48),
                  height: context.scaled(48),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.scaled(17)),
                  ),
                  child: Icon(
                    category?.iconData ?? Icons.category_rounded,
                    color: categoryColor,
                    size: context.scaled(22),
                  ),
                ),
                SizedBox(width: context.scaled(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Danh mục đã xóa',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.appText.fieldValue,
                      ),
                      SizedBox(height: context.scaled(6)),
                      _StatusChip(status: status),
                    ],
                  ),
                ),
                SizedBox(width: context.scaled(10)),
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textSecondary,
                  size: context.scaled(22),
                ),
              ],
            ),
            SizedBox(height: context.scaled(14)),
            Row(
              children: [
                Text(
                  '${percent.round()}%',
                  style: context.appText.bodyStrong.copyWith(
                    color: status.color,
                  ),
                ),
                SizedBox(width: context.scaled(10)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: context.scaled(8),
                      backgroundColor: palette.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation(status.color),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scaled(12)),
            Row(
              children: [
                Expanded(
                  child: _SummaryAmount(
                    label: 'Đã dùng',
                    value: formatCurrency(spentAmount),
                  ),
                ),
                Expanded(
                  child: _SummaryAmount(
                    label: 'Còn lại',
                    value: formatCurrency(
                      budget.remainingAmountWith(spentAmount),
                    ),
                    alignCenter: true,
                  ),
                ),
                Expanded(
                  child: _SummaryAmount(
                    label: 'Hạn mức',
                    value: formatCurrency(budget.limitAmount),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scaled(12)),
            Wrap(
              spacing: context.scaled(7),
              runSpacing: context.scaled(7),
              children: [
                _InfoChip(
                  icon: Icons.calendar_month_rounded,
                  label: formatMonthYear(budget.periodStart),
                ),
                _InfoChip(
                  icon: Icons.notifications_active_rounded,
                  label: 'Cảnh báo ${budget.warningPercent.round()}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(9),
        vertical: context.scaled(5),
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: context.appText.captionStrong.copyWith(
          color: status.color,
          fontSize: context.scaledFont(11, min: 10),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(8),
        vertical: context.scaled(5),
      ),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: palette.textSecondary, size: context.scaled(13)),
          SizedBox(width: context.scaled(4)),
          Text(
            label,
            style: context.appText.captionStrong.copyWith(
              color: palette.textSecondary,
              fontSize: context.scaledFont(11, min: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetCard extends StatelessWidget {
  const _EmptyBudgetCard({
    required this.hasExpenseCategories,
    required this.onAdd,
  });

  final bool hasExpenseCategories;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onAdd,
      child: FlatCard(
        showShadow: false,
        radius: context.scaled(24),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_rounded,
              color: AppColors.primary,
              size: context.scaled(36),
            ),
            SizedBox(height: context.scaled(10)),
            Text('Chưa có ngân sách', style: context.appText.bodyStrong),
            SizedBox(height: context.scaled(6)),
            Text(
              hasExpenseCategories
                  ? 'Bấm nút + để đặt hạn mức chi tiêu'
                  : 'Hãy tạo danh mục chi tiêu trước',
              textAlign: TextAlign.center,
              style: context.appText.caption.copyWith(
                color: context.appPalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStatus {
  const _BudgetStatus({required this.label, required this.color});

  final String label;
  final Color color;

  factory _BudgetStatus.fromBudget(Budget budget, double spentAmount) {
    if (budget.isExceededWith(spentAmount)) {
      return const _BudgetStatus(
        label: 'Đã vượt ngân sách',
        color: AppColors.danger,
      );
    }

    if (budget.isNearLimitWith(spentAmount)) {
      return const _BudgetStatus(
        label: 'Gần vượt ngân sách',
        color: AppColors.warning,
      );
    }

    return const _BudgetStatus(
      label: 'Trong hạn mức',
      color: AppColors.primary,
    );
  }
}
