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
      height: 74,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: isDark ? 12 : 18,
            offset: const Offset(0, 7),
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

    if (isAction) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 58,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -23,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 58,
                  height: 58,
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
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.34),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 58,
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 24,
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                color: foreground,
                size: selected ? 20 : 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? colors.primary : inactiveColor,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w700,
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
