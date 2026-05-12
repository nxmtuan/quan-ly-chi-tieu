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
import '../../models/savings_goal.dart';
import '../../providers/savings_goal_provider.dart';
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
    final progress = goal.progressWith(savedAmount);
    final remainingAmount = goal.remainingAmountWith(savedAmount);
    final completed = goal.isCompletedWith(savedAmount);
    final color = completed ? AppColors.success : AppColors.primary;

    return AppSheetScaffold(
      title: 'Chi tiết mục tiêu',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: context.scaled(24)),
            Container(
              width: context.scaled(72),
              height: context.scaled(72),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed ? Icons.check_circle_rounded : Icons.flag_rounded,
                color: color,
                size: context.scaled(32),
              ),
            ),
            SizedBox(height: context.scaled(12)),
            Text(
              goal.title,
              textAlign: TextAlign.center,
              style: context.appText.amountLG,
            ),
            SizedBox(height: context.scaled(12)),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: context.scaled(10),
                backgroundColor: palette.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            SizedBox(height: context.scaled(8)),
            Text(
              '${(progress * 100).round()}%',
              style: context.appText.bodyStrong.copyWith(color: color),
            ),
            if (goal.hasNote) ...[
              SizedBox(height: context.scaled(14)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaled(12),
                  vertical: context.scaled(10),
                ),
                decoration: BoxDecoration(
                  color: palette.inputBackground,
                  borderRadius: BorderRadius.circular(context.scaled(12)),
                ),
                child: Text(
                  goal.note!,
                  textAlign: TextAlign.left,
                  style: context.appText.body.copyWith(
                    color: palette.iconMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            SizedBox(height: context.scaled(24)),
            Container(
              padding: EdgeInsets.all(context.scaled(16)),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(context.scaled(16)),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  _buildRow(
                    context,
                    label: 'Đã tiết kiệm',
                    value: formatCurrency(savedAmount),
                    valueColor: color,
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Còn lại',
                    value: formatCurrency(remainingAmount),
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Mục tiêu',
                    value: formatCurrency(goal.targetAmount),
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Ngày bắt đầu',
                    value: formatShortDate(goal.startDate),
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Deadline',
                    value: goal.deadline == null
                        ? 'Không có'
                        : formatShortDate(goal.deadline!),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.scaled(8)),
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
                  color: color,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
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
      message: 'Mục tiêu tiết kiệm này sẽ bị xóa khỏi danh sách.',
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

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.scaled(118),
          child: Text(
            label,
            style: context.appText.body.copyWith(
              color: context.appPalette.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: context.appText.bodyStrong.copyWith(
              color: valueColor ?? context.appPalette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
