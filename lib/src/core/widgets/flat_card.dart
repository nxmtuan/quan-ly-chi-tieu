import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../utils/adaptive.dart';

class FlatCard extends StatelessWidget {
  const FlatCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.color,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        boxShadow: showShadow ? appSurfaceShadow(context) : null,
      ),
      child: child,
    );
  }
}
