import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';

class ExpenseManagerApp extends ConsumerWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(authProvider);

    return MaterialApp.router(
      title: 'Quản lý chi tiêu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final compactTextScaler = _compactTextScalerForWidth(
          mediaQuery,
        );
        final compactTheme = Theme.of(context).copyWith(
          visualDensity: const VisualDensity(horizontal: -0.6, vertical: -0.6),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: compactTextScaler),
          child: Theme(
            data: compactTheme,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

TextScaler _compactTextScalerForWidth(MediaQueryData mediaQuery) {
  final width = mediaQuery.size.width;
  final systemScale = mediaQuery.textScaler.scale(1);

  final layoutScale = switch (width) {
    >= 430 => 0.98,
    >= 400 => 0.97,
    >= 380 => 0.96,
    _ => 0.95,
  };

  final targetScale = systemScale > 1
      ? systemScale.clamp(layoutScale, 1.0)
      : layoutScale;

  return TextScaler.linear(targetScale);
}
