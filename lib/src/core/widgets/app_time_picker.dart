import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import 'app_bounce_builder.dart';
import 'app_sheet.dart';

Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return Dialog(
        alignment: Alignment.bottomCenter,
        insetPadding: EdgeInsets.fromLTRB(
          context.scaled(16),
          context.scaled(16),
          context.scaled(16),
          context.scaled(16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _AppTimePickerSheet(initialTime: initialTime),
      );
    },
  );
}

class _AppTimePickerSheet extends StatefulWidget {
  const _AppTimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_AppTimePickerSheet> createState() => _AppTimePickerSheetState();
}

class _AppTimePickerSheetState extends State<_AppTimePickerSheet> {
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scaled(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.scaled(20),
              context.scaled(22),
              context.scaled(20),
              context.scaled(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn thời gian',
                  style: context.appText.sheetTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: context.scaled(18)),
                _SelectedTimePreview(
                  hour: _selectedHour,
                  minute: _selectedMinute,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.scaled(16),
              0,
              context.scaled(16),
              context.scaled(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PickerColumn(
                    controller: _hourController,
                    values: List.generate(24, (index) => index),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedHour = index);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.scaled(10)),
                  child: Text(
                    ':',
                    style: context.appText.amountXL.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: context.scaledFont(28, min: 24),
                    ),
                  ),
                ),
                Expanded(
                  child: _PickerColumn(
                    controller: _minuteController,
                    values: List.generate(60, (index) => index),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedMinute = index);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.scaled(20),
              context.scaled(8),
              context.scaled(20),
              appSheetBottomPadding(context),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppBounceBuilder(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaled(16),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(
                          context.scaled(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Hủy',
                        style: context.appText.buttonLabel.copyWith(
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scaled(12)),
                Expanded(
                  child: AppBounceBuilder(
                    onTap: () => Navigator.of(context).pop(
                      TimeOfDay(
                        hour: _selectedHour,
                        minute: _selectedMinute,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaled(16),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          context.scaled(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Chọn',
                        style: context.appText.buttonLabel.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
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

class _SelectedTimePreview extends StatelessWidget {
  const _SelectedTimePreview({
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _TimeSegment(value: hour)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scaled(10)),
          child: Text(
            ':',
            style: context.appText.amountXL.copyWith(
              color: AppColors.textPrimary,
              fontSize: context.scaledFont(30, min: 26),
            ),
          ),
        ),
        Expanded(child: _TimeSegment(value: minute)),
      ],
    );
  }
}

class _TimeSegment extends StatelessWidget {
  const _TimeSegment({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.scaled(92),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(context.scaled(22)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString().padLeft(2, '0'),
        style: context.appText.amountXL.copyWith(
          color: AppColors.textPrimary,
          fontSize: context.scaledFont(34, min: 30),
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  const _PickerColumn({
    required this.controller,
    required this.values,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final List<int> values;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.scaled(228),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(context.scaled(22)),
      ),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: context.appText.amountLG.copyWith(
              color: AppColors.textPrimary,
              fontSize: context.scaledFont(26, min: 22),
            ),
          ),
        ),
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: context.scaled(56),
          diameterRatio: 1.3,
          useMagnifier: true,
          magnification: 1.08,
          selectionOverlay: Container(
            margin: EdgeInsets.symmetric(horizontal: context.scaled(10)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.scaled(16)),
            ),
          ),
          onSelectedItemChanged: onSelectedItemChanged,
          children: [
            for (final value in values)
              Center(
                child: Text(value.toString().padLeft(2, '0')),
              ),
          ],
        ),
      ),
    );
  }
}
