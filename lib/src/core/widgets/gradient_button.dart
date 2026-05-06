import 'package:flutter/material.dart';

import '../utils/adaptive.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scaled(22)),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(context.scaled(22)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: context.scaled(isDark ? 12 : 20),
                offset: Offset(0, context.scaled(7)),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: context.scaled(20)),
                SizedBox(width: context.scaled(10)),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.scaled(15),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
