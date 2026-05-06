import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      height: 102,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(42),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: isDark ? 18 : 28,
            offset: const Offset(0, 12),
          ),
        ],
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isAction ? 999 : 30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 78,
        padding: EdgeInsets.only(
          top: isAction ? 0 : 10,
          bottom: isAction ? 0 : 9,
        ),
        decoration: BoxDecoration(
          color: selected && !isAction
              ? colors.primary.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAction)
              Transform.translate(
                offset: const Offset(0, -35),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 84,
                  height: 84,
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
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.34),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 34,
                alignment: Alignment.center,
                child: Icon(
                  item.icon,
                  color: foreground,
                  size: selected ? 25 : 29,
                ),
              ),
            SizedBox(height: isAction ? 0 : 7),
            Transform.translate(
              offset: Offset(0, isAction ? -33 : 0),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isAction
                      ? colors.primary
                      : selected
                      ? colors.primary
                      : inactiveColor,
                  fontSize: isAction ? 15 : 13.5,
                  fontWeight: selected || isAction
                      ? FontWeight.w900
                      : FontWeight.w700,
                ),
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
