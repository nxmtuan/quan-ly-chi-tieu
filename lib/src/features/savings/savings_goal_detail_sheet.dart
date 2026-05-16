import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/category.dart';
import '../../models/savings_goal.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/savings_goal_provider.dart';
import '../../providers/transaction_provider.dart';
import 'savings_goal_sheet.dart';

void showSavingsGoalDetailSheet(
  BuildContext context, {
  required SavingsGoal goal,
  required double savedAmount,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return _SavingsGoalDetailSheet(goal: goal, savedAmount: savedAmount);
    },
  );
}

class _SavingsGoalDetailSheet extends ConsumerWidget {
  const _SavingsGoalDetailSheet({
    required this.goal,
    required this.savedAmount,
  });

  final SavingsGoal goal;
  final double savedAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final status = _SavingsDetailStatus.fromGoal(goal, savedAmount);
    final transactions = ref
        .watch(
          transactionsQueryProvider((
            categoryId: null,
            fromDate: null,
            limit: null,
            toDate: null,
            type: TransactionType.expense,
          )),
        )
        .where((transaction) => transaction.savingsGoalId == goal.id)
        .toList();
    final categoriesById = {
      for (final category in ref.watch(categoriesProvider))
        category.id: category,
    };

    return AppSheetScaffold(
      title: 'Chi tiết mục tiêu',
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: context.scaled(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SavingsOverviewSection(
              child: _SavingsGoalInfoSection(
                goal: goal,
                savedAmount: savedAmount,
                status: status,
              ),
            ),
            SizedBox(height: context.scaled(40)),
            _SavingsGoalTransactionsSection(
              transactions: transactions,
              categoriesById: categoriesById,
            ),
          ],
        ),
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () => _confirmDelete(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: palette.dangerSoft,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Xóa',
                  style: context.appText.buttonLabel.copyWith(
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: AppBounceBuilder(
              onTap: () {
                Navigator.of(context).pop();
                showSavingsGoalSheet(context, goal: goal, replaceSheet: true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: context.scaled(8),
                      offset: Offset(0, context.scaled(4)),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text('Chỉnh sửa', style: context.appText.buttonLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa mục tiêu',
      message:
          'Mục tiêu này sẽ bị xóa. Các giao dịch đã gắn mục tiêu sẽ trở về mặc định.',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: context.appPalette.dangerSoft,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(savingsGoalsProvider.notifier).deleteGoal(goal.id);
      if (!context.mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Đã xóa mục tiêu',
        type: AppToastType.success,
      );
      Navigator.of(context).pop();
    }
  }
}

class _SavingsOverviewSection extends StatelessWidget {
  const _SavingsOverviewSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.all(context.scaled(10)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(26)),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

class _SavingsGoalInfoSection extends StatelessWidget {
  const _SavingsGoalInfoSection({
    required this.goal,
    required this.savedAmount,
    required this.status,
  });

  final SavingsGoal goal;
  final double savedAmount;
  final _SavingsDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final progress = goal.progressWith(savedAmount);
    final remainingAmount = goal.remainingAmountWith(savedAmount);

    return Padding(
      padding: EdgeInsets.all(context.scaled(4)),
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
                  color: goal.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(context.scaled(17)),
                ),
                child: Icon(
                  status.iconOverride ?? goal.iconData,
                  color: goal.color,
                  size: context.scaled(22),
                ),
              ),
              SizedBox(width: context.scaled(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.fieldValue,
                    ),
                    SizedBox(height: context.scaled(6)),
                    Text(
                      status.label,
                      style: context.appText.captionStrong.copyWith(
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.scaled(10)),
              Text(
                '${(progress * 100).round()}%',
                style: context.appText.bodyStrong.copyWith(color: status.color),
              ),
            ],
          ),
          SizedBox(height: context.scaled(14)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.scaled(9),
              backgroundColor: palette.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(status.color),
            ),
          ),
          SizedBox(height: context.scaled(14)),
          Row(
            children: [
              Expanded(
                child: _SavingsMetric(
                  label: 'Đã tiết kiệm',
                  value: formatCurrency(savedAmount),
                  valueColor: status.color,
                ),
              ),
              SizedBox(width: context.scaled(8)),
              Expanded(
                child: _SavingsMetric(
                  label: 'Còn lại',
                  value: formatCurrency(remainingAmount),
                  alignCenter: true,
                ),
              ),
              SizedBox(width: context.scaled(8)),
              Expanded(
                child: _SavingsMetric(
                  label: 'Mục tiêu',
                  value: formatCurrency(goal.targetAmount),
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
              _SavingsInfoChip(
                icon: Icons.play_circle_rounded,
                label: 'Bắt đầu ${formatShortDate(goal.startDate)}',
              ),
              _SavingsInfoChip(
                icon: Icons.event_rounded,
                label: goal.deadline == null
                    ? 'Không có deadline'
                    : 'Hạn ${formatShortDate(goal.deadline!)}',
              ),
            ],
          ),
          if (goal.hasNote) ...[
            SizedBox(height: context.scaled(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.scaled(12),
                vertical: context.scaled(10),
              ),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(context.scaled(12)),
              ),
              child: Text(
                goal.note!,
                style: context.appText.caption.copyWith(
                  color: palette.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavingsMetric extends StatelessWidget {
  const _SavingsMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignCenter = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
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
        SizedBox(height: context.scaled(4)),
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
            color: valueColor ?? context.appPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SavingsInfoChip extends StatelessWidget {
  const _SavingsInfoChip({required this.icon, required this.label});

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

class _SavingsGoalTransactionsSection extends StatelessWidget {
  const _SavingsGoalTransactionsSection({
    required this.transactions,
    required this.categoriesById,
  });

  final List<Transaction> transactions;
  final Map<String, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scaled(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giao dịch gắn mục tiêu', style: context.appText.bodyStrong),
          SizedBox(height: context.scaled(10)),
          if (transactions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
              child: Center(
                child: Text(
                  'Chưa có giao dịch nào gắn với mục tiêu này',
                  style: context.appText.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            )
          else
            for (var index = 0; index < transactions.length; index++) ...[
              _SavingsGoalTransactionRow(
                transaction: transactions[index],
                category: categoriesById[transactions[index].categoryId],
              ),
              if (index < transactions.length - 1)
                Divider(color: palette.border, height: context.scaled(1)),
            ],
        ],
      ),
    );
  }
}

class _SavingsGoalTransactionRow extends StatelessWidget {
  const _SavingsGoalTransactionRow({
    required this.transaction,
    required this.category,
  });

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? AppColors.danger;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaled(11)),
      child: Row(
        children: [
          Container(
            width: context.scaled(42),
            height: context.scaled(42),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.scaled(15)),
            ),
            child: Icon(
              category?.iconData ?? Icons.savings_rounded,
              color: color,
              size: context.scaled(20),
            ),
          ),
          SizedBox(width: context.scaled(11)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.hasNote
                      ? transaction.note!
                      : category?.name ?? 'Giao dịch tiết kiệm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodyStrong,
                ),
                SizedBox(height: context.scaled(4)),
                Text(
                  [
                    category?.name,
                    formatShortDate(transaction.date),
                  ].whereType<String>().join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaled(10)),
          Text(
            '-${formatCurrency(transaction.amount)}',
            textAlign: TextAlign.right,
            style: context.appText.bodyStrong.copyWith(color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _SavingsDetailStatus {
  const _SavingsDetailStatus({
    required this.label,
    required this.color,
    this.iconOverride,
  });

  final String label;
  final Color color;
  final IconData? iconOverride;

  factory _SavingsDetailStatus.fromGoal(SavingsGoal goal, double savedAmount) {
    if (goal.isCompletedWith(savedAmount)) {
      return const _SavingsDetailStatus(
        label: 'Đã hoàn thành',
        color: AppColors.success,
        iconOverride: Icons.check_circle_rounded,
      );
    }

    if (goal.isWaitingAt(DateTime.now())) {
      return const _SavingsDetailStatus(
        label: 'Đang chờ',
        color: AppColors.warning,
        iconOverride: Icons.schedule_rounded,
      );
    }

    return const _SavingsDetailStatus(
      label: 'Đang tiến hành',
      color: AppColors.primary,
    );
  }
}
