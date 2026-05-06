part of '../add_transaction_sheet.dart';

String formatAmountInput(num amount) {
  return _formatThousands(amount.round().toString());
}

double? parseAmountInput(String input) {
  final rawDigits = input.replaceAll('.', '').trim();
  if (rawDigits.isEmpty) {
    return null;
  }

  return double.tryParse(rawDigits);
}

String _formatThousands(String digits) {
  if (digits.isEmpty) {
    return '';
  }

  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    buffer.write(digits[index]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

class _AmountInputFormatter extends TextInputFormatter {
  const _AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = _formatThousands(digitsOnly);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Chi tiêu',
              selected: type == TransactionType.expense,
              color: const Color(0xFFFF1493),
              icon: Icons.trending_up_rounded,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Thu nhập',
              selected: type == TransactionType.income,
              color: AppColors.success,
              icon: Icons.trending_down_rounded,
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
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.24))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                color: selected ? color : const Color(0xFF4B5563),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? color : const Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          TextSpan(
            text: '*',
            style: TextStyle(color: color),
          ),
        ],
      ),
      style: const TextStyle(
        color: Color(0xFF4B5563),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.controller, required this.actionColor});

  final TextEditingController controller;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: 'Số tiền', color: actionColor),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [_AmountInputFormatter()],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'đ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _LeadingIcon(
            icon: Icons.edit_note_rounded,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ghi chú',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nhập mô tả giao dịch',
                    hintStyle: TextStyle(
                      color: Color(0xFFB3BAC8),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTrigger extends StatelessWidget {
  const _SourceTrigger({required this.source, required this.onTap});

  final String source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: _FormCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _LeadingIcon(
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RequiredStaticLabel('Nguồn tiền'),
                  const SizedBox(height: 6),
                  Text(
                    source,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF4B5563),
              size: 18,
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(14),
      child: _FormCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _LeadingIcon(
              icon: Icons.calendar_month_rounded,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RequiredStaticLabel('Ngày giao dịch'),
                  const SizedBox(height: 6),
                  Text(
                    _dateLabel(date),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF4B5563),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    if (DateUtils.isSameDay(date, DateTime.now())) {
      return 'Hôm nay, ${formatShortDate(date)}';
    }

    return 'Đã chọn, ${formatShortDate(date)}';
  }
}

class _RequiredStaticLabel extends StatelessWidget {
  const _RequiredStaticLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: const [
          TextSpan(
            text: '*',
            style: TextStyle(color: Color(0xFFFF1493)),
          ),
        ],
      ),
      style: const TextStyle(
        color: Color(0xFF4B5563),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
