import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _NavItem(Icons.home_rounded, 'Home'),
      const _NavItem(Icons.bar_chart_rounded, 'Stats'),
      const _NavItem(Icons.settings_rounded, 'Settings'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: _NavButton(
                item: items[index],
                selected: currentIndex == index,
                onTap: () => onTap(index),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.lavenderLight : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: selected ? AppColors.lavender : AppColors.textSecondary,
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.lavender,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
