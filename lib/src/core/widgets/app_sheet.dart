import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import 'app_bounce_builder.dart';

double appSheetBottomPadding(BuildContext context, {double extra = 0}) {
  return MediaQuery.of(context).padding.bottom + context.scaled(16) + extra;
}

int _sheetDepth = 0;

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  // Set true khi sheet này mở ra để thay thế sheet hiện tại (sheet kia bị pop).
  // Khi đó dùng depth của sheet bị thay thế để tránh bị lệch vị trí.
  bool replacesCurrentSheet = false,
}) {
  // Nếu thay thế sheet hiện tại, depth bằng depth của sheet bị đóng (sheetDepth - 1),
  // không tăng thêm. _sheetDepth vẫn tăng để cân bằng với whenComplete của sheet cũ.
  final currentDepth = replacesCurrentSheet
      ? (_sheetDepth - 1).clamp(0, 99)
      : _sheetDepth;
  _sheetDepth++;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(top: currentDepth * 30.0),
        child: SizedBox(
          height: double.infinity,
          child: builder(context),
        ),
      );
    },
  ).whenComplete(() {
    _sheetDepth--;
  });
}

class AppSheetContainer extends StatelessWidget {
  const AppSheetContainer({
    super.key,
    required this.child,
    this.radius = 28,
    this.color,
    this.boxShadow,
  });

  final Widget child;
  final double radius;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Standard full-screen sheet layout: fixed [AppSheetHeader] on top,
/// scrollable [body] in the middle, and an optional [AppSheetFooter] with
/// [action] widget pinned at the bottom.
class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.onClose,
    this.showCloseButton = true,
    this.action,
    this.bodyPadding,
    this.radius = 28,
    this.boxShadow,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? action;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final EdgeInsetsGeometry? bodyPadding;
  final double radius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return AppSheetContainer(
      radius: radius,
      boxShadow: boxShadow,
      child: Column(
        children: [
          AppSheetHeader(
            title: title,
            subtitle: subtitle,
            onClose: onClose,
            showCloseButton: showCloseButton,
          ),
          Expanded(
            child: Padding(
              padding: bodyPadding ??
                  EdgeInsets.symmetric(horizontal: context.scaled(16)),
              child: body,
            ),
          ),
          if (action != null) AppSheetFooter(child: action!),
        ],
      ),
    );
  }
}


class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.scaled(40),
      height: context.scaled(4),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFB8BCC8),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
    this.showCloseButton = true,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
    this.titleStyle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHandle(),
          SizedBox(height: context.scaled(16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          titleStyle ??
                          context.appText.sheetTitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: context.scaled(6)),
                      Text(
                        subtitle!,
                        style: context.appText.sheetSubtitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showCloseButton)
                AppBounceBuilder(
                  onTap: onClose ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: context.scaled(38),
                    height: context.scaled(38),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.08),
                          blurRadius: context.scaled(7),
                          offset: Offset(0, context.scaled(3)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFF374151),
                      size: context.scaled(17),
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

class AppSheetFooter extends StatelessWidget {
  const AppSheetFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.scaled(16),
        context.scaled(8),
        context.scaled(16),
        appSheetBottomPadding(context),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: context.scaled(9),
            offset: Offset(0, -context.scaled(5)),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.height = 50,
    this.radius = 14,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: onTap != null ? color : color.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(context.scaled(radius)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.appText.buttonLabel.copyWith(
            color: onTap != null
                ? Colors.white
                : Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}
