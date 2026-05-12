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
import '../../models/savings_goal.dart';
import '../../providers/savings_goal_provider.dart';
import 'savings_goal_detail_sheet.dart';
import 'savings_goal_sheet.dart';

enum _SavingsTab { waiting, active, completed }

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  _SavingsTab _selectedTab = _SavingsTab.active;
  _SavingsTab _previousTab = _SavingsTab.active;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(savingsGoalsProvider);
    final savedAmounts = ref.watch(savingsGoalSavedAmountsProvider);
    final now = DateTime.now();
    final groupedGoals = _groupGoals(goals, savedAmounts, now);
    final visibleGoals = groupedGoals[_selectedTab] ?? const <SavingsGoal>[];

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          ListView(
                padding: EdgeInsets.fromLTRB(
                  context.scaled(24),
                  context.scaled(22),
                  context.scaled(24),
                  context.scaled(176) + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  const AppPageHeader(
                    subtitle: 'Tiết kiệm',
                    title: 'Mục tiêu tiết kiệm',
                  ),
                  SizedBox(height: context.scaled(22)),
                  _SavingsTabBar(
                    selectedTab: _selectedTab,
                    counts: {
                      for (final tab in _SavingsTab.values)
                        tab: groupedGoals[tab]?.length ?? 0,
                    },
                    onSelected: (tab) {
                      if (tab == _selectedTab) {
                        return;
                      }
                      setState(() {
                        _previousTab = _selectedTab;
                        _selectedTab = tab;
                      });
                    },
                  ),
                  SizedBox(height: context.scaled(18)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    reverseDuration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [...previousChildren, ?currentChild],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isIncoming =
                          child.key == ValueKey<_SavingsTab>(_selectedTab);
                      final direction = _selectedTab.index >= _previousTab.index
                          ? 1.0
                          : -1.0;
                      final beginOffset = Offset(
                        isIncoming ? 0.08 * direction : -0.04 * direction,
                        0,
                      );

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: beginOffset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _SavingsTabContent(
                      key: ValueKey(_selectedTab),
                      tab: _selectedTab,
                      goals: visibleGoals,
                      savedAmounts: savedAmounts,
                      onAdd: () => showSavingsGoalSheet(context),
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
        ],
      ),
    );
  }

  Map<_SavingsTab, List<SavingsGoal>> _groupGoals(
    List<SavingsGoal> goals,
    Map<String, double> savedAmounts,
    DateTime now,
  ) {
    final grouped = {
      for (final tab in _SavingsTab.values) tab: <SavingsGoal>[],
    };

    for (final goal in goals) {
      final savedAmount = _savedAmountFor(goal, savedAmounts);
      if (goal.isCompletedWith(savedAmount)) {
        grouped[_SavingsTab.completed]!.add(goal);
      } else if (goal.isWaitingAt(now)) {
        grouped[_SavingsTab.waiting]!.add(goal);
      } else {
        grouped[_SavingsTab.active]!.add(goal);
      }
    }

    return grouped;
  }
}

class _SavingsTabContent extends StatelessWidget {
  const _SavingsTabContent({
    super.key,
    required this.tab,
    required this.goals,
    required this.savedAmounts,
    required this.onAdd,
  });

  final _SavingsTab tab;
  final List<SavingsGoal> goals;
  final Map<String, double> savedAmounts;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SavingsListHeader(title: tab.label, onAdd: onAdd),
        SizedBox(height: context.scaled(12)),
        if (goals.isEmpty)
          _EmptySavingsCard(tab: tab, onAdd: onAdd)
        else
          for (final goal in goals)
            Padding(
              padding: EdgeInsets.only(bottom: context.scaled(12)),
              child: _SavingsGoalCard(
                goal: goal,
                savedAmount: _savedAmountFor(goal, savedAmounts),
              ),
            ),
      ],
    );
  }
}

class _SavingsTabBar extends StatelessWidget {
  const _SavingsTabBar({
    required this.selectedTab,
    required this.counts,
    required this.onSelected,
  });

  final _SavingsTab selectedTab;
  final Map<_SavingsTab, int> counts;
  final ValueChanged<_SavingsTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.all(context.scaled(5)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          for (final tab in _SavingsTab.values)
            Expanded(
              child: _SavingsTabButton(
                label: '${tab.label} ${counts[tab] ?? 0}',
                selected: selectedTab == tab,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _SavingsTabButton extends StatelessWidget {
  const _SavingsTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: context.scaled(11)),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(14)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appText.captionStrong.copyWith(
            color: selected
                ? AppColors.primary
                : context.appPalette.textSecondary,
            fontSize: context.scaledFont(11.5, min: 10.5),
          ),
        ),
      ),
    );
  }
}

class _SavingsListHeader extends StatelessWidget {
  const _SavingsListHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.appText.bodyStrong)),
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

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({required this.goal, required this.savedAmount});

  final SavingsGoal goal;
  final double savedAmount;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final status = _statusFor(goal, savedAmount, DateTime.now());
    final progress = goal.progressWith(savedAmount);
    final remainingAmount = goal.remainingAmountWith(savedAmount);

    return AppBounceBuilder(
      onTap: () => showSavingsGoalDetailSheet(
        context,
        goal: goal,
        savedAmount: savedAmount,
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
                    color: goal.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.scaled(17)),
                  ),
                  child: Icon(
                    goal.iconData,
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
                  '${(progress * 100).round()}%',
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
                  child: _GoalAmountLabel(
                    label: 'Đã tiết kiệm',
                    value: formatCurrency(savedAmount),
                  ),
                ),
                SizedBox(width: context.scaled(8)),
                Expanded(
                  child: _GoalAmountLabel(
                    label: 'Còn lại',
                    value: formatCurrency(remainingAmount),
                    alignCenter: true,
                  ),
                ),
                SizedBox(width: context.scaled(8)),
                Expanded(
                  child: _GoalAmountLabel(
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
                _InfoChip(
                  icon: Icons.play_circle_rounded,
                  label: 'Bắt đầu ${formatShortDate(goal.startDate)}',
                ),
                if (goal.deadline != null)
                  _InfoChip(
                    icon: Icons.event_rounded,
                    label: 'Hạn ${formatShortDate(goal.deadline!)}',
                  ),
              ],
            ),
            if (goal.hasNote) ...[
              SizedBox(height: context.scaled(10)),
              Text(
                goal.note!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.appText.caption.copyWith(
                  color: palette.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalAmountLabel extends StatelessWidget {
  const _GoalAmountLabel({
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _SavingsGoalStatus status;

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

class _EmptySavingsCard extends StatelessWidget {
  const _EmptySavingsCard({required this.tab, required this.onAdd});

  final _SavingsTab tab;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onAdd,
      child: FlatCard(
        showShadow: false,
        radius: context.scaled(24),
        child: Column(
          children: [
            Icon(tab.icon, color: AppColors.primary, size: context.scaled(36)),
            SizedBox(height: context.scaled(10)),
            Text(tab.emptyTitle, style: context.appText.bodyStrong),
            SizedBox(height: context.scaled(6)),
            Text(
              'Bấm nút + để tạo mục tiêu',
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

double _savedAmountFor(SavingsGoal goal, Map<String, double> savedAmounts) {
  return goal.savedAmount + (savedAmounts[goal.id] ?? 0);
}

_SavingsGoalStatus _statusFor(
  SavingsGoal goal,
  double savedAmount,
  DateTime now,
) {
  if (goal.isCompletedWith(savedAmount)) {
    return const _SavingsGoalStatus(
      label: 'Đã hoàn thành',
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    );
  }

  if (goal.isWaitingAt(now)) {
    return const _SavingsGoalStatus(
      label: 'Đang chờ',
      icon: Icons.schedule_rounded,
      color: AppColors.warning,
    );
  }

  return const _SavingsGoalStatus(
    label: 'Đang tiến hành',
    icon: Icons.flag_rounded,
    color: AppColors.primary,
  );
}

class _SavingsGoalStatus {
  const _SavingsGoalStatus({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

extension _SavingsTabX on _SavingsTab {
  String get label {
    return switch (this) {
      _SavingsTab.waiting => 'Đang chờ',
      _SavingsTab.active => 'Đang tiến hành',
      _SavingsTab.completed => 'Hoàn thành',
    };
  }

  String get emptyTitle {
    return switch (this) {
      _SavingsTab.waiting => 'Không có mục tiêu đang chờ',
      _SavingsTab.active => 'Chưa có mục tiêu đang tiến hành',
      _SavingsTab.completed => 'Chưa có mục tiêu hoàn thành',
    };
  }

  IconData get icon => Icons.flag_rounded;
}
