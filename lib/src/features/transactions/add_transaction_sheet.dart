import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

void showAddTransactionSheet(BuildContext context, {Transaction? transaction}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
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
  String? _categoryId;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;
    if (transaction != null) {
      _amountController.text = transaction.amount.toStringAsFixed(0);
      _noteController.text = transaction.note;
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

    return Padding(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      child:
          Container(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.transaction == null
                                ? 'Ghi chép GD'
                                : 'Cập nhật GD',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _TypeToggle(
                        type: _type,
                        onChanged: (type) {
                          setState(() {
                            _type = type;
                            _categoryId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Số tiền *'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0đ',
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle('Danh mục *'),
                      const SizedBox(height: 10),
                      _CategoryTrigger(
                        category: categories
                            .where((category) => category.id == _categoryId)
                            .firstOrNull,
                        onTap: () => _pickCategory(categories),
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle('Ngày giao dịch *'),
                      const SizedBox(height: 10),
                      _DateTrigger(date: _date, onTap: _pickDate),
                      const SizedBox(height: 20),
                      const _SectionTitle('Nguồn tiền *'),
                      const SizedBox(height: 10),
                      const _SourceTrigger(),
                      const SizedBox(height: 20),
                      const _SectionTitle('Ghi chú'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteController,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'Nhập ghi chú',
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: widget.transaction == null
                            ? (_type == TransactionType.expense
                                  ? 'Thêm giao dịch chi'
                                  : 'Thêm giao dịch thu')
                            : 'Cập nhật giao dịch',
                        icon: Icons.check_rounded,
                        onTap: _saveTransaction,
                      ),
                    ],
                  ),
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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate != null) {
      setState(() => _date = selectedDate);
    }
  }

  Future<void> _pickCategory(List<Category> categories) async {
    final selectedCategory = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: _SectionTitle('Chọn danh mục'),
              ),
              const SizedBox(height: 14),
              for (final category in categories)
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(category.iconData, color: category.color),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: _categoryId == category.id
                      ? Icon(Icons.check_rounded, color: category.color)
                      : null,
                  onTap: () => Navigator.of(context).pop(category),
                ),
            ],
          ),
        );
      },
    );

    if (selectedCategory != null) {
      setState(() => _categoryId = selectedCategory.id);
    }
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _categoryId == null) {
      return;
    }

    final transaction = Transaction(
      id:
          widget.transaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      type: _type,
      categoryId: _categoryId!,
      date: _date,
      note: _noteController.text.trim(),
    );

    if (widget.transaction == null) {
      await ref.read(transactionsProvider.notifier).addTransaction(transaction);
    } else {
      await ref
          .read(transactionsProvider.notifier)
          .updateTransaction(transaction);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Chi tiêu',
              selected: type == TransactionType.expense,
              color: AppColors.danger,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Thu nhập',
              selected: type == TransactionType.income,
              color: AppColors.success,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CategoryTrigger extends StatelessWidget {
  const _CategoryTrigger({required this.category, required this.onTap});

  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = category;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (item?.color ?? AppColors.primary).withValues(
                  alpha: 0.13,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                item?.iconData ?? Icons.category_rounded,
                color: item?.color ?? AppColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item?.name ?? 'Chọn danh mục',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _SourceTrigger extends StatelessWidget {
  const _SourceTrigger();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ngoài ứng dụng',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }
}

class _DateTrigger extends StatelessWidget {
  const _DateTrigger({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatShortDate(date),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}
