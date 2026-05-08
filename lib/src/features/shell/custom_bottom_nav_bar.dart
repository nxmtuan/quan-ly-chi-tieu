import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_bounce_builder.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTransaction,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? colors.surface : Colors.white;
    final items = [
      const _NavItem(Icons.grid_view_rounded, 'Tổng quan'),
      const _NavItem(Icons.calendar_month_rounded, 'Lịch'),
      const _NavItem(Icons.add_rounded, 'Nhập', isAction: true),
      const _NavItem(Icons.repeat_rounded, 'Định kỳ'),
      const _NavItem(Icons.settings_rounded, 'Cài đặt'),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(
        context.scaled(10),
        0,
        context.scaled(10),
        context.scaled(8) + MediaQuery.paddingOf(context).bottom,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.scaled(27)),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: isDark ? 0.4 : 0.12),
                    blurRadius: context.scaled(isDark ? 16 : 24),
                    offset: Offset(0, context.scaled(8)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.scaled(27)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: isDark ? 0.1 : 0.15),
                      borderRadius: BorderRadius.circular(context.scaled(27)),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.5),
                        width: context.scaled(1.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: context.scaled(68),
            padding: EdgeInsets.symmetric(
              horizontal: context.scaled(6),
              vertical: context.scaled(6),
            ),
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child:
                        _NavButton(
                              item: items[index],
                              selected: currentIndex == index,
                              onTap: items[index].isAction
                                  ? onAddTransaction
                                  : () => onTap(index),
                            )
                            .animate(delay: Duration(milliseconds: 50 * index))
                            .fadeIn(duration: 220.ms)
                            .slideY(
                              begin: 0.16,
                              end: 0,
                              duration: 280.ms,
                              curve: Curves.easeOutCubic,
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAction = item.isAction;
    final inactiveColor = colors.onSurface.withValues(alpha: 0.54);
    final foreground = selected
        ? colors.primary
        : colors.onSurface.withValues(alpha: isAction ? 0.92 : 0.54);
    final scale = context.adaptiveScale;

    if (isAction) {
      return AppBounceBuilder(
        onTap: onTap,
        child: SizedBox(
          height: context.scaled(54),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -context.scaled(21),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: context.scaled(54),
                  height: context.scaled(54),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.72),
                        colors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.2 * scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.34),
                        blurRadius: context.scaled(14),
                        offset: Offset(0, context.scaled(7)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: context.scaled(29),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.navLabel.copyWith(
                    color: colors.primary,
                    fontSize: context.scaledFont(11.5, min: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: context.scaled(54),
        padding: EdgeInsets.only(
          top: context.scaled(5),
          bottom: context.scaled(5),
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: context.scaled(22),
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: foreground,
                size: context.scaled(selected ? 18 : 20),
              ),
            ),
            SizedBox(height: context.scaled(2)),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appText.navLabel.copyWith(
                color: selected ? colors.primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, {this.isAction = false});

  final IconData icon;
  final String label;
  final bool isAction;
}
