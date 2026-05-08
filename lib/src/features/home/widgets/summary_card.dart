import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_bounce_builder.dart';
import '../models/home_summary_scope.dart';
import '../../../providers/transaction_provider.dart';

part 'summary/summary_components.dart';
part '../sheets/month_picker_sheet.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.summary,
    required this.scope,
    required this.onPickScope,
    this.onPreviousScope,
    this.onNextScope,
  });

  final TransactionSummary summary;
  final HomeSummaryScope scope;
  final VoidCallback onPickScope;
  final VoidCallback? onPreviousScope;
  final VoidCallback? onNextScope;

  @override
  Widget build(BuildContext context) {
    final verticalSpacing = context.scaled(14);
    final cardSpacing = context.scaled(10);

    return Column(
      children: [
        _MonthSelectorBar(
          scope: scope,
          onPreviousScope: onPreviousScope,
          onPickScope: onPickScope,
          onNextScope: onNextScope,
        ),
        SizedBox(height: verticalSpacing),
        Row(
          children: [
            Expanded(
              child: _SummaryMetricCard(
                label: 'Chi tiêu',
                amount: summary.expense,
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFFFF2F72),
                backgroundColor: const Color(0xFFFFF2F6),
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: _SummaryMetricCard(
                label: 'Thu nhập',
                amount: summary.income,
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF00D69B),
                backgroundColor: const Color(0xFFF0FFF9),
              ),
            ),
          ],
        ),
        SizedBox(height: context.scaled(14)),
        _BalanceBanner(balance: summary.balance),
      ],
    );
  }
}
