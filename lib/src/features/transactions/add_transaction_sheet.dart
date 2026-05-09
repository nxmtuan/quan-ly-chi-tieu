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
import '../../core/widgets/app_table_calendar.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
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
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  String _source = 'Tiền mặt';
  String? _categoryId;
  String? _promotedCategoryId;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;
    if (transaction != null) {
      _amountController.text = formatAmountInput(transaction.amount);
      _noteController.text = transaction.note ?? '';
      _type = transaction.type;
      _date = transaction.date;
      _categoryId = transaction.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByTypeProvider(_type));
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
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
                                    _promotedCategoryId = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              _AmountCard(
                                controller: _amountController,
                                actionColor: actionColor,
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
                              _SourceTrigger(
                                source: _source,
                                onTap: _pickSource,
                              ),
                              const SizedBox(height: 10),
                              _NoteCard(controller: _noteController),
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
    final transactionDates = ref.read(allTransactionDatesProvider);
    final eventsByDay = buildCalendarEventIndex(
      transactionDates,
      (date) => date,
    );

    final selectedDate = await showAppCalendarSheet(
      context,
      initialDate: _date,
      title: 'Chọn ngày giao dịch',
      eventLoader: (day) => eventsByDay[normalizeCalendarDay(day)] ?? const [],
    );

    if (selectedDate != null) {
      setState(() => _date = selectedDate);
    }
  }

  Future<void> _pickSource() async {
    final selectedSource = await showTransactionSourceSheet(
      context,
      selectedSource: _source,
    );

    if (selectedSource != null) {
      setState(() => _source = selectedSource);
    }
  }

  Future<void> _showAllCategories(List<Category> categories) async {
    final selectedCategory = await showAllCategoriesSheet(
      context,
      categories: categories,
      initialSelectedCategoryId: _categoryId,
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

  Future<void> _saveTransaction() async {
    final amount = parseAmountInput(_amountController.text);
    if (amount == null || amount <= 0 || _categoryId == null) {
      return;
    }

    final transaction = Transaction(
      id:
          widget.transaction?.id ??
          generateLocalEntityId(),
      amount: amount,
      type: _type,
      categoryId: _categoryId!,
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

    final confirmed = await showTransactionConfirmationSheet(
      context,
      transaction: transaction,
      category: category,
      source: _source,
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
}
