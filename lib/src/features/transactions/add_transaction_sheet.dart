import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/local_id.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/transaction_marker_calendar.dart';
import '../categories/category_management_sheet.dart';
import '../settings/money_source_management_sheet.dart';
import '../../models/category.dart';
import '../../models/money_source.dart';
import '../../models/savings_goal.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/money_source_provider.dart';
import '../../providers/savings_goal_provider.dart';
import '../../providers/transaction_provider.dart';

part 'widgets/transaction_sheet_scaffold.dart';
part 'widgets/transaction_sheet_fields.dart';
part 'widgets/transaction_category_picker.dart';
part 'sheets/source_picker_sheet.dart';
part 'sheets/all_categories_sheet.dart';
part 'sheets/transaction_confirmation_sheet.dart';
part 'sheets/transaction_detail_sheet.dart';

void showAddTransactionSheet(
  BuildContext context, {
  Transaction? transaction,
  bool replaceSheet = false,
}) {
  showAppBottomSheet<void>(
    context: context,
    replacesCurrentSheet: replaceSheet,
    builder: (context) => AddTransactionSheet(transaction: transaction),
  );
}

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late final FocusNode _amountFocusNode;
  late final FocusNode _noteFocusNode;
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  String? _sourceId;
  String? _categoryId;
  String? _savingsGoalId;
  String? _promotedCategoryId;
  String? _promotedSourceId;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _noteFocusNode = FocusNode()..addListener(_handleFocusChanged);

    final transaction = widget.transaction;
    if (transaction != null) {
      _amountController.text = formatAmountInput(transaction.amount);
      _noteController.text = transaction.note ?? '';
      _type = transaction.type;
      _date = transaction.date;
      _categoryId = transaction.categoryId;
      _sourceId = transaction.sourceId;
      _savingsGoalId = transaction.savingsGoalId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _noteFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByTypeProvider(_type));
    final moneySources = ref.watch(moneySourcesProvider);
    final savingsGoals = ref.watch(savingsGoalsProvider);
    final savingsGoalSavedAmounts = ref.watch(savingsGoalSavedAmountsProvider);
    final activeSavingsGoals = _activeSavingsGoals(
      savingsGoals,
      savingsGoalSavedAmounts,
    );
    final selectedSavingsGoal = savingsGoals
        .where((goal) => goal.id == _savingsGoalId)
        .firstOrNull;
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }
    if (_sourceId == null && moneySources.isNotEmpty) {
      _sourceId = moneySources.first.id;
    }
    final actionColor = _type == TransactionType.expense
        ? const Color(0xFFFF1493)
        : AppColors.success;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child:
                AppSheetContainer(
                  child: Column(
                    children: [
                      _SheetHeader(
                        title: widget.transaction == null
                            ? 'Ghi chép GD'
                            : 'Cập nhật GD',
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TypeToggle(
                                type: _type,
                                onChanged: (type) {
                                  setState(() {
                                    _type = type;
                                    _categoryId = null;
                                    if (type == TransactionType.income) {
                                      _savingsGoalId = null;
                                    }
                                    _promotedCategoryId = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              _AmountCard(
                                controller: _amountController,
                                actionColor: actionColor,
                                focusNode: _amountFocusNode,
                                isFocused: _amountFocusNode.hasFocus,
                              ),
                              const SizedBox(height: 10),
                              _CategoryPicker(
                                categories: categories,
                                selectedCategoryId: _categoryId,
                                actionColor: actionColor,
                                onSelected: (category) {
                                  setState(() => _categoryId = category.id);
                                },
                                onShowAll: () => _showAllCategories(categories),
                                promotedCategoryId: _promotedCategoryId,
                              ),
                              const SizedBox(height: 10),
                              _DateTrigger(date: _date, onTap: _pickDate),
                              const SizedBox(height: 10),
                              _MoneySourcePicker(
                                moneySources: moneySources,
                                selectedSourceId: _sourceId,
                                actionColor: actionColor,
                                onSelected: (source) {
                                  setState(() => _sourceId = source.id);
                                },
                                onShowAll: () => _showAllMoneySources(moneySources),
                                promotedSourceId: _promotedSourceId,
                              ),
                              if (_type == TransactionType.expense) ...[
                                const SizedBox(height: 10),
                                _SavingsGoalPicker(
                                  activeGoals: activeSavingsGoals,
                                  selectedGoal: selectedSavingsGoal,
                                  actionColor: actionColor,
                                  onTap: () => _showSavingsGoalPicker(
                                    activeSavingsGoals,
                                    savingsGoalSavedAmounts,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              _NoteCard(
                                controller: _noteController,
                                focusNode: _noteFocusNode,
                                isFocused: _noteFocusNode.hasFocus,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSheetFooter(
                        child: AppPrimaryButton(
                          label: widget.transaction == null
                              ? (_type == TransactionType.expense
                                    ? 'Thêm giao dịch chi'
                                    : 'Thêm giao dịch thu')
                              : 'Cập nhật giao dịch',
                          color: actionColor,
                          onTap: _saveTransaction,
                        ),
                      ),
                    ],
                  ),
                )
              .animate()
              .fadeIn(duration: 220.ms)
              .slideY(
                begin: 0.14,
                end: 0,
                duration: 360.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }

  Future<void> _pickDate() async {
    final selectedDate = await showTransactionCalendarSheet(
      context,
      initialDate: _date,
      title: 'Chọn ngày giao dịch',
    );

    if (selectedDate != null) {
      setState(() => _date = selectedDate);
    }
  }

  Future<void> _showAllCategories(List<Category> categories) async {
    final selectedCategory = await showAllCategoriesSheet(
      context,
      categories: categories,
      initialSelectedCategoryId: _categoryId,
      transactionType: _type,
      actionColor: _type == TransactionType.expense
          ? const Color(0xFFFF1493)
          : AppColors.success,
    );

    if (selectedCategory != null && mounted) {
      setState(() {
        _categoryId = selectedCategory.id;
        _promotedCategoryId = selectedCategory.id;
      });
    }
  }

  Future<void> _showAllMoneySources(List<MoneySource> moneySources) async {
    final selectedSource = await showAllMoneySourcesSheet(
      context,
      moneySources: moneySources,
      initialSelectedSourceId: _sourceId,
      actionColor: _type == TransactionType.expense
          ? const Color(0xFFFF1493)
          : AppColors.success,
    );

    if (selectedSource != null && mounted) {
      setState(() {
        _sourceId = selectedSource.id;
        _promotedSourceId = selectedSource.id;
      });
    }
  }

  Future<void> _showSavingsGoalPicker(
    List<SavingsGoal> activeGoals,
    Map<String, double> savedAmounts,
  ) async {
    final result = await _showSavingsGoalPickerSheet(
      context,
      goals: activeGoals,
      savedAmounts: savedAmounts,
      initialSelectedGoalId: _savingsGoalId,
      actionColor: _type == TransactionType.expense
          ? const Color(0xFFFF1493)
          : AppColors.success,
    );

    if (mounted && result != null) {
      setState(() => _savingsGoalId = result.goalId);
    }
  }

  Future<void> _saveTransaction() async {
    final amount = parseAmountInput(_amountController.text);
    if (amount == null ||
        amount <= 0 ||
        _categoryId == null ||
        _sourceId == null) {
      return;
    }

    final transaction = Transaction(
      id:
          widget.transaction?.id ??
          generateLocalEntityId(),
      amount: amount,
      type: _type,
      categoryId: _categoryId!,
      sourceId: _sourceId!,
      savingsGoalId: _type == TransactionType.expense ? _savingsGoalId : null,
      date: _date,
      note: _noteController.text.trim(),
    );

    final categories = ref.read(categoriesByTypeProvider(_type));
    final category = categories.firstWhere(
      (c) => c.id == _categoryId,
      orElse: () => Category(
        id: _categoryId!,
        name: 'Khác',
        iconData: Icons.category_rounded,
        colorHex: AppColors.textSecondary.toARGB32(),
        type: _type,
      ),
    );
    final source = ref.read(moneySourceByIdProvider(_sourceId!)) ??
        defaultMoneySources.first;

    final confirmed = await showTransactionConfirmationSheet(
      context,
      transaction: transaction,
      category: category,
      source: source,
    );

    if (!confirmed) return;

    if (widget.transaction == null) {
      await ref.read(transactionsProvider.notifier).addTransaction(transaction);
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đã thêm giao dịch thành công',
          type: AppToastType.success,
        );
      }
    } else {
      await ref
          .read(transactionsProvider.notifier)
          .updateTransaction(transaction);
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đã cập nhật giao dịch thành công',
          type: AppToastType.success,
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  List<SavingsGoal> _activeSavingsGoals(
    List<SavingsGoal> goals,
    Map<String, double> savedAmounts,
  ) {
    final now = DateTime.now();
    return [
      for (final goal in goals)
        if (!goal.isWaitingAt(now) &&
            !goal.isCompletedWith(
              goal.savedAmount + (savedAmounts[goal.id] ?? 0),
            ))
          goal,
    ];
  }
}
