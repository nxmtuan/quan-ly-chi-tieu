import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return switch (getPlatform(context)) {
      TargetPlatform.android || TargetPlatform.fuchsia =>
        StretchingOverscrollIndicator(
          axisDirection: details.direction,
          clipBehavior: Clip.none,
          child: child,
        ),
      _ => child,
    };
  }
}
