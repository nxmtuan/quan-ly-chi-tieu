import 'package:flutter/material.dart';

import '../utils/adaptive.dart';

class FlatCard extends StatelessWidget {
  const FlatCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding is EdgeInsets
          ? EdgeInsets.fromLTRB(
              context.scaled((padding as EdgeInsets).left),
              context.scaled((padding as EdgeInsets).top),
              context.scaled((padding as EdgeInsets).right),
              context.scaled((padding as EdgeInsets).bottom),
            )
          : padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(context.scaled(radius)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: context.scaled(isDark ? 8 : 12),
            offset: Offset(0, context.scaled(4)),
          ),
        ],
      ),
      child: child,
    );
  }
}
