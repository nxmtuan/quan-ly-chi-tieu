part of '../widgets/summary_card.dart';

Future<HomeSummaryScope?> showMonthPickerSheet(
  BuildContext context, {
  required HomeSummaryScope initialScope,
  required DateTime lastMonth,
}) {
  return showAppBottomSheet<HomeSummaryScope>(
    context: context,
    builder: (context) {
      return _MonthPickerSheet(
        initialScope: initialScope,
        lastMonth: lastMonth,
      );
    },
  );
}

class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({
    required this.initialScope,
    required this.lastMonth,
  });

  final HomeSummaryScope initialScope;
  final DateTime lastMonth;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  static const _yearRangeCount = 40;

  late HomeSummaryScopeType _selectedTab;
  late int _displayedYear;
  late DateTime _selectedMonth;
  late int _selectedYear;
  late final ScrollController _yearScrollController;
  bool _canScrollYearsUp = false;
  bool _canScrollYearsDown = false;

  @override
  void initState() {
    super.initState();
    _yearScrollController = ScrollController()
      ..addListener(_updateYearScrollHints);
    _selectedTab = widget.initialScope.type;
    _selectedMonth = switch (widget.initialScope.type) {
      HomeSummaryScopeType.month => DateTime(
        widget.initialScope.anchor!.year,
        widget.initialScope.anchor!.month,
      ),
      HomeSummaryScopeType.year => DateTime(widget.initialScope.anchor!.year, 1),
      HomeSummaryScopeType.all => DateTime(widget.lastMonth.year, widget.lastMonth.month),
    };
    _selectedYear = widget.initialScope.anchor?.year ?? widget.lastMonth.year;
    _displayedYear = _selectedYear;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToSelectedYear();
      _updateYearScrollHints();
    });
  }

  @override
  void dispose() {
    _yearScrollController
      ..removeListener(_updateYearScrollHints)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoNextYear = _displayedYear < widget.lastMonth.year;

    return AppSheetScaffold(
      title: 'Chọn bộ lọc',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: context.scaled(8)),
          _PickerScopeTabs(
            selectedTab: _selectedTab,
            onSelected: (tab) {
              setState(() => _selectedTab = tab);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (tab == HomeSummaryScopeType.year) {
                  _jumpToSelectedYear();
                }
                _updateYearScrollHints();
              });
            },
          ),
          SizedBox(height: context.scaled(20)),
          if (_selectedTab == HomeSummaryScopeType.month) ...[
            Row(
              children: [
                AppBounceBuilder(
                  onTap: () => setState(() {
                    _displayedYear -= 1;
                  }),
                  child: Padding(
                    padding: EdgeInsets.all(context.scaled(8)),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: context.scaled(26),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$_displayedYear',
                    textAlign: TextAlign.center,
                    style: context.appText.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: context.scaledFont(18, min: 16),
                    ),
                  ),
                ),
                AppBounceBuilder(
                  onTap: canGoNextYear
                      ? () => setState(() {
                          final nextYear = _displayedYear + 1;
                          _displayedYear = nextYear > widget.lastMonth.year
                              ? widget.lastMonth.year
                              : nextYear;
                        })
                      : null,
                  child: Padding(
                    padding: EdgeInsets.all(context.scaled(8)),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: context.scaled(26),
                      color: canGoNextYear
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scaled(16)),
          ],
          Expanded(
            child: switch (_selectedTab) {
              HomeSummaryScopeType.month => Align(
                alignment: Alignment.topCenter,
                child: _buildMonthGrid(context),
              ),
              HomeSummaryScopeType.year => _buildYearGrid(context),
              HomeSummaryScopeType.all => Align(
                alignment: Alignment.topCenter,
                child: _buildAllTab(context),
              ),
            },
          ),
        ],
      ),
      action: AppPrimaryButton(
        label: switch (_selectedTab) {
          HomeSummaryScopeType.month => 'Chọn tháng',
          HomeSummaryScopeType.year => 'Chọn năm',
          HomeSummaryScopeType.all => 'Áp dụng tất cả',
        },
        color: AppColors.primary,
        onTap: () => Navigator.of(context).pop(_selectedScope()),
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.scaled(12),
        mainAxisSpacing: context.scaled(12),
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;
        final candidateMonth = DateTime(_displayedYear, month);
        final isSelected =
            _selectedMonth.year == _displayedYear &&
            _selectedMonth.month == month;
        final isDisabled = candidateMonth.isAfter(widget.lastMonth);

        return _PickerGridOption(
          label: 'Tháng $month',
          isSelected: isSelected,
          isDisabled: isDisabled,
          onTap: isDisabled
              ? null
              : () => setState(() => _selectedMonth = candidateMonth),
        );
      },
    );
  }

  Widget _buildYearGrid(BuildContext context) {
    final currentYear = widget.lastMonth.year;
    final years = [
      for (var year = currentYear; year > currentYear - _yearRangeCount; year--)
        year,
    ];

    return Stack(
      children: [
        GridView.builder(
          controller: _yearScrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: context.scaled(46),
            bottom: context.scaled(46),
          ),
          itemCount: years.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.scaled(12),
            mainAxisSpacing: context.scaled(12),
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            final year = years[index];
            return _PickerGridOption(
              label: 'Năm $year',
              isSelected: _selectedYear == year,
              onTap: () => setState(() => _selectedYear = year),
            );
          },
        ),
        if (_canScrollYearsUp)
          Positioned(
            top: context.scaled(8),
            left: 0,
            right: 0,
            child: _ScrollHintButton(
              icon: Icons.keyboard_arrow_up_rounded,
              onTap: () => _scrollYearsBy(-context.scaled(180)),
            ),
          ),
        if (_canScrollYearsDown)
          Positioned(
            bottom: context.scaled(8),
            left: 0,
            right: 0,
            child: _ScrollHintButton(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: () => _scrollYearsBy(context.scaled(180)),
            ),
          ),
      ],
    );
  }

  Widget _buildAllTab(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scaled(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Hiển thị giao dịch từ trước đến nay đã được lưu trên ứng dụng',
        style: context.appText.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  HomeSummaryScope _selectedScope() {
    return switch (_selectedTab) {
      HomeSummaryScopeType.month => HomeSummaryScope.month(_selectedMonth),
      HomeSummaryScopeType.year => HomeSummaryScope.year(_selectedYear),
      HomeSummaryScopeType.all => HomeSummaryScope.all(),
    };
  }

  void _updateYearScrollHints() {
    if (!mounted || !_yearScrollController.hasClients) {
      return;
    }

    final position = _yearScrollController.position;
    final canScrollUp = position.pixels > position.minScrollExtent + 4;
    final canScrollDown = position.pixels < position.maxScrollExtent - 4;

    if (canScrollUp != _canScrollYearsUp ||
        canScrollDown != _canScrollYearsDown) {
      setState(() {
        _canScrollYearsUp = canScrollUp;
        _canScrollYearsDown = canScrollDown;
      });
    }
  }

  void _scrollYearsBy(double delta) {
    if (!_yearScrollController.hasClients) {
      return;
    }

    final position = _yearScrollController.position;
    final targetOffset = (_yearScrollController.offset + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    _yearScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpToSelectedYear() {
    if (!_yearScrollController.hasClients) {
      return;
    }

    final currentYear = widget.lastMonth.year;
    final selectedIndex =
        (currentYear - _selectedYear).clamp(0, _yearRangeCount - 1);
    final row = selectedIndex ~/ 2;
    final rowExtent = context.scaled(90);
    final targetOffset = (row * rowExtent) - context.scaled(12);
    final position = _yearScrollController.position;
    final clampedOffset = targetOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    _yearScrollController.jumpTo(clampedOffset);
  }
}

class _PickerScopeTabs extends StatelessWidget {
  const _PickerScopeTabs({
    required this.selectedTab,
    required this.onSelected,
  });

  final HomeSummaryScopeType selectedTab;
  final ValueChanged<HomeSummaryScopeType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.scaled(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final tab in HomeSummaryScopeType.values)
            Expanded(
              child: _PickerScopeTab(
                label: switch (tab) {
                  HomeSummaryScopeType.month => 'Chọn tháng',
                  HomeSummaryScopeType.year => 'Chọn năm',
                  HomeSummaryScopeType.all => 'Tất cả',
                },
                isSelected: selectedTab == tab,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _PickerScopeTab extends StatelessWidget {
  const _PickerScopeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.24))
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.appText.captionStrong.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PickerGridOption extends StatelessWidget {
  const _PickerGridOption({
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isDisabled
              ? const Color(0xFFF8FAFC)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(16)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDisabled
                ? AppColors.border.withValues(alpha: 0.6)
                : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.appText.bodyStrong.copyWith(
            color: isSelected
                ? Colors.white
                : isDisabled
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.textPrimary,
            fontSize: context.scaledFont(12, min: 12),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ScrollHintButton extends StatelessWidget {
  const _ScrollHintButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      scaleDown: 0.92,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: context.scaled(36),
          height: context.scaled(36),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.1),
                blurRadius: context.scaled(10),
                offset: Offset(0, context.scaled(4)),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: context.scaled(22),
          ),
        ),
      ),
    );
  }
}
