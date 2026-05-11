import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/local_id.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/flat_card.dart';
import '../../core/widgets/transaction_marker_calendar.dart';
import '../../models/category.dart';
import '../../models/money_source.dart';
import '../../models/recurring_item.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/money_source_provider.dart';
import '../../providers/recurring_provider.dart';
import '../transactions/add_transaction_sheet.dart';

part 'widgets/recurring_add_sheet.dart';

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  RecurringItemKind _selectedTab = RecurringItemKind.transaction;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(recurringTransactionsProvider);
    final reminders = ref.watch(recurringRemindersProvider);
    final items = _selectedTab == RecurringItemKind.transaction
        ? transactions
        : reminders;

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
                subtitle: 'Định kỳ',
                title: 'Tự động & nhắc nhở',
              ),
              SizedBox(height: context.scaled(22)),
              _RecurringTabBar(
                selectedTab: _selectedTab,
                onSelected: (tab) => setState(() => _selectedTab = tab),
              ),
              SizedBox(height: context.scaled(18)),
              _RecurringListHeader(
                kind: _selectedTab,
                onAdd: () => showRecurringAddSheet(context, kind: _selectedTab),
              ),
              SizedBox(height: context.scaled(12)),
              if (items.isEmpty)
                _EmptyRecurringCard(kind: _selectedTab)
              else
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.scaled(12)),
                    child: _RecurringItemCard(item: item),
                  ),
            ],
          ).animate().fadeIn(duration: 260.ms),
        ],
      ),
    );
  }
}

class _RecurringTabBar extends StatelessWidget {
  const _RecurringTabBar({required this.selectedTab, required this.onSelected});

  final RecurringItemKind selectedTab;
  final ValueChanged<RecurringItemKind> onSelected;

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
          Expanded(
            child: _RecurringTabButton(
              label: 'Giao dịch định kỳ',
              selected: selectedTab == RecurringItemKind.transaction,
              onTap: () => onSelected(RecurringItemKind.transaction),
            ),
          ),
          Expanded(
            child: _RecurringTabButton(
              label: 'Nhắc nhở định kỳ',
              selected: selectedTab == RecurringItemKind.reminder,
              onTap: () => onSelected(RecurringItemKind.reminder),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringTabButton extends StatelessWidget {
  const _RecurringTabButton({
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
          ),
        ),
      ),
    );
  }
}

class _RecurringListHeader extends StatelessWidget {
  const _RecurringListHeader({required this.kind, required this.onAdd});

  final RecurringItemKind kind;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final title = kind == RecurringItemKind.transaction
        ? 'Giao dịch định kỳ'
        : 'Nhắc nhở định kỳ';

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

class _RecurringItemCard extends ConsumerWidget {
  const _RecurringItemCard({required this.item});

  final RecurringItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(item.categoryId));
    final source = ref.watch(moneySourceByIdProvider(item.sourceId));
    final color = item.type == TransactionType.expense
        ? AppColors.danger
        : AppColors.success;

    return FlatCard(
      showShadow: false,
      radius: context.scaled(22),
      padding: EdgeInsets.all(context.scaled(14)),
      child: Row(
        children: [
          Container(
            width: context.scaled(50),
            height: context.scaled(50),
            decoration: BoxDecoration(
              color: (category?.color ?? color).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(context.scaled(18)),
            ),
            child: Icon(
              category?.iconData ?? Icons.repeat_rounded,
              color: category?.color ?? color,
              size: context.scaled(23),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.fieldValue,
                ),
                SizedBox(height: context.scaled(5)),
                Text(
                  '${category?.name ?? 'Khác'} • ${source?.name ?? 'Tiền mặt'} • ${item.frequency.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
                SizedBox(height: context.scaled(4)),
                Text(
                  'Kỳ tiếp theo: ${formatShortDate(item.nextRunAt)}',
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaled(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(item.amount),
                style: context.appText.bodyStrong.copyWith(color: color),
              ),
              if (item.kind == RecurringItemKind.reminder) ...[
                SizedBox(height: context.scaled(8)),
                AppBounceBuilder(
                  onTap: () => _completeReminder(context, ref),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scaled(9),
                      vertical: context.scaled(5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Hoàn thành',
                      style: context.appText.captionStrong.copyWith(
                        color: AppColors.primary,
                        fontSize: context.scaledFont(11, min: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeReminder(BuildContext context, WidgetRef ref) async {
    final key = recurringOccurrenceKey(item.nextRunAt);
    var nextRunAt = item.nextRunAt;
    while (!nextRunAt.isAfter(DateTime.now())) {
      nextRunAt = nextRecurringDate(nextRunAt, item.frequency);
    }

    await ref
        .read(recurringItemsProvider.notifier)
        .updateItem(
          item.copyWith(
            nextRunAt: nextRunAt,
            completedOccurrenceKeys: [...item.completedOccurrenceKeys, key],
          ),
        );
    if (context.mounted) {
      AppToast.show(
        context,
        message: 'Đã hoàn thành lời nhắc',
        type: AppToastType.success,
      );
    }
  }
}

class _EmptyRecurringCard extends StatelessWidget {
  const _EmptyRecurringCard({required this.kind});

  final RecurringItemKind kind;

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      showShadow: false,
      radius: context.scaled(24),
      child: Column(
        children: [
          Icon(
            kind == RecurringItemKind.transaction
                ? Icons.repeat_rounded
                : Icons.notifications_active_rounded,
            color: AppColors.primary,
            size: context.scaled(34),
          ),
          SizedBox(height: context.scaled(10)),
          Text(
            kind == RecurringItemKind.transaction
                ? 'Chưa có giao dịch định kỳ'
                : 'Chưa có nhắc nhở định kỳ',
            style: context.appText.bodyStrong,
          ),
          SizedBox(height: context.scaled(6)),
          Text(
            'Bấm nút + để tạo mới',
            style: context.appText.caption.copyWith(
              color: context.appPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
