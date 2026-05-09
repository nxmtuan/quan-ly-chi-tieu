import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      primary: AppColors.primary,
      palette: const AppPalette(
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceElevated: Colors.white,
        surfaceMuted: Color(0xFFF8FAFC),
        inputBackground: AppColors.inputBackground,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        border: AppColors.border,
        shadow: AppColors.shadow,
        handle: Color(0xFFB8BCC8),
        iconMuted: Color(0xFF4B5563),
        iconStrong: Color(0xFF374151),
        primarySoft: AppColors.primaryLight,
        successSoft: Color(0xFFF0FFF9),
        dangerSoft: Color(0xFFFEE2E2),
      ),
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      palette: const AppPalette(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceElevated: Color(0xFF334155),
        surfaceMuted: Color(0xFF162131),
        inputBackground: AppColors.darkInputBackground,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        border: AppColors.darkBorder,
        shadow: AppColors.darkShadow,
        handle: Color(0xFF64748B),
        iconMuted: Color(0xFFCBD5E1),
        iconStrong: Color(0xFFE2E8F0),
        primarySoft: AppColors.darkPrimaryLight,
        successSoft: Color(0xFF052E26),
        dangerSoft: Color(0xFF3F1D24),
      ),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required AppPalette palette,
  }) {
    final baseTextTheme = ThemeData(brightness: brightness).textTheme.apply(
      fontFamily: 'BeVietnamPro',
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
    );
    final textTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      fontFamily: 'BeVietnamPro',
      visualDensity: const VisualDensity(horizontal: -0.6, vertical: -0.6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      primaryColor: primary,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.surface,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: AppColors.success,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        tertiary: palette.primarySoft,
        onTertiary: palette.textPrimary,
        outline: palette.border,
        shadow: palette.shadow,
        inverseSurface: palette.textPrimary,
        onInverseSurface: palette.surface,
        inversePrimary: primary,
      ),
      extensions: [palette],
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.04),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerColor: palette.border,
      disabledColor: palette.textSecondary.withValues(alpha: 0.48),
      iconTheme: IconThemeData(color: palette.iconMuted),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
