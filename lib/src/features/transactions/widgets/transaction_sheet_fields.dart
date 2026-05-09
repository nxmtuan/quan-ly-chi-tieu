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
    final palette = context.appPalette;

    return Container(
      height: context.scaled(48),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: context.isDarkMode ? 0.22 : 0.06),
            blurRadius: context.scaled(9),
            offset: Offset(0, context.scaled(3)),
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
    final palette = context.appPalette;

    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: context.scaled(8)),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.24))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.scaled(26),
              height: context.scaled(26),
              decoration: BoxDecoration(
                color: palette.surfaceElevated,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                color: selected ? color : palette.iconMuted,
                size: context.scaled(16),
              ),
            ),
            SizedBox(width: context.scaled(8)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.captionStrong.copyWith(
                  color: selected ? color : palette.iconMuted,
                  fontSize: context.scaledFont(12, min: 12),
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
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.all(context.scaled(14)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: context.isDarkMode ? 0.18 : 0.025),
            blurRadius: context.scaled(6),
            offset: Offset(0, context.scaled(2)),
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
            style: context.appText.fieldLabel.copyWith(color: color),
          ),
        ],
      ),
      style: context.appText.fieldLabel.copyWith(
        color: context.appPalette.iconMuted,
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
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: 'Số tiền', color: actionColor),
          SizedBox(height: context.scaled(6)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [_AmountInputFormatter()],
                  style: context.appText.amountXL.copyWith(
                    fontSize: context.scaledFont(28, min: 24),
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: context.appText.amountXL.copyWith(
                      color: context.appPalette.textSecondary.withValues(alpha: 0.55),
                      fontSize: context.scaledFont(28, min: 24),
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
              SizedBox(width: context.scaled(8)),
              Padding(
                padding: EdgeInsets.only(bottom: context.scaled(3)),
                child: Text(
                  'đ',
                  style: context.appText.amountXL.copyWith(
                    fontSize: context.scaledFont(28, min: 24),
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
      width: context.scaled(38),
      height: context.scaled(38),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(context.scaled(15)),
      ),
      child: Icon(icon, color: color, size: context.scaled(20)),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(14),
        vertical: context.scaled(10),
      ),
      child: Row(
        children: [
          _LeadingIcon(
            icon: Icons.edit_note_rounded,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          SizedBox(width: context.scaled(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ghi chú',
                  style: context.appText.fieldLabel.copyWith(
                    color: context.appPalette.iconMuted,
                  ),
                ),
                SizedBox(height: context.scaled(4)),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.appText.fieldValue,
                  decoration: InputDecoration(
                    hintText: 'Nhập mô tả giao dịch',
                    hintStyle: context.appText.fieldValue.copyWith(
                      color: context.appPalette.textSecondary.withValues(alpha: 0.65),
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

class _MoneySourcePicker extends StatelessWidget {
  const _MoneySourcePicker({
    required this.moneySources,
    required this.selectedSourceId,
    required this.actionColor,
    required this.onSelected,
    required this.onShowAll,
    required this.promotedSourceId,
  });

  final List<MoneySource> moneySources;
  final String? selectedSourceId;
  final Color actionColor;
  final ValueChanged<MoneySource> onSelected;
  final VoidCallback onShowAll;
  final String? promotedSourceId;

  @override
  Widget build(BuildContext context) {
    final orderedSources = _orderedSources();
    final visibleSources = orderedSources.take(2).toList();
    final shouldShowMoreButton = orderedSources.length > 2;

    return _FormCard(
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: 'Nguồn tiền', color: actionColor),
          SizedBox(height: context.scaled(10)),
          if (moneySources.isEmpty)
            Text(
              'Chưa có nguồn tiền',
              style: context.appText.bodyStrong.copyWith(
                color: context.appPalette.textSecondary,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    (constraints.maxWidth - context.scaled(16)) / 3;

                return Wrap(
                  spacing: context.scaled(8),
                  runSpacing: context.scaled(8),
                  children: [
                    for (final source in visibleSources)
                      SizedBox(
                        width: itemWidth,
                        child: _MoneySourceTile(
                          source: source,
                          selected: source.id == selectedSourceId,
                          actionColor: actionColor,
                          onTap: () => onSelected(source),
                        ),
                      ),
                    if (shouldShowMoreButton)
                      SizedBox(
                        width: itemWidth,
                        child: _MoreMoneySourcesTile(onTap: onShowAll),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  List<MoneySource> _orderedSources() {
    if (promotedSourceId == null) {
      return moneySources;
    }

    final promotedSource = moneySources
        .where((source) => source.id == promotedSourceId)
        .firstOrNull;
    if (promotedSource == null) {
      return moneySources;
    }

    return [
      promotedSource,
      for (final source in moneySources)
        if (source.id != promotedSource.id) source,
    ];
  }
}

class _MoneySourceTile extends StatelessWidget {
  const _MoneySourceTile({
    required this.source,
    required this.selected,
    required this.actionColor,
    required this.onTap,
  });

  final MoneySource source;
  final bool selected;
  final Color actionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: SizedBox(
        height: context.scaled(120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: context.scaled(8),
            vertical: context.scaled(10),
          ),
          decoration: BoxDecoration(
            color: selected
                ? actionColor.withValues(alpha: 0.045)
                : context.appPalette.surface,
            borderRadius: BorderRadius.circular(context.scaled(14)),
            border: Border.all(
              color: selected ? actionColor : context.appPalette.border,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: context.scaled(36),
                height: context.scaled(36),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  source.iconData,
                  color: AppColors.primary,
                  size: context.scaled(19),
                ),
              ),
              SizedBox(height: context.scaled(8)),
              SizedBox(
                height: context.scaled(34),
                child: Center(
                  child: Text(
                    source.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: context.appText.captionStrong.copyWith(
                      color: selected ? actionColor : context.appPalette.textPrimary,
                      fontSize: context.scaledFont(11.5, min: 11),
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreMoneySourcesTile extends StatelessWidget {
  const _MoreMoneySourcesTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        height: context.scaled(120),
        padding: EdgeInsets.fromLTRB(
          context.scaled(6),
          context.scaled(10),
          context.scaled(6),
          context.scaled(8),
        ),
        decoration: BoxDecoration(
          color: context.appPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(color: context.appPalette.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoreCategoriesIcon(),
            SizedBox(height: context.scaled(10)),
            Text(
              'Khác',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.appText.captionStrong.copyWith(
                color: context.appPalette.textPrimary,
                fontSize: context.scaledFont(12, min: 12),
              ),
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
    return AppBounceBuilder(
      onTap: onTap,
      child: _FormCard(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(14),
          vertical: context.scaled(10),
        ),
        child: Row(
          children: [
            _LeadingIcon(
              icon: Icons.calendar_month_rounded,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            SizedBox(width: context.scaled(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RequiredStaticLabel('Ngày giao dịch'),
                  SizedBox(height: context.scaled(6)),
                  Text(
                    _dateLabel(date),
                    style: context.appText.fieldValue,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appPalette.iconMuted,
              size: context.scaled(18),
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
        children: [
          TextSpan(
            text: '*',
            style: context.appText.fieldLabel.copyWith(
              color: const Color(0xFFFF1493),
            ),
          ),
        ],
      ),
      style: context.appText.fieldLabel.copyWith(
        color: context.appPalette.iconMuted,
      ),
    );
  }
}
