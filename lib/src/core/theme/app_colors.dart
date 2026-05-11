import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF0D9488);
  static const primaryLight = Color(0xFFCCFBF1);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const inputBackground = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const shadow = Color(0xFF0F172A);

  static const darkPrimary = Color(0xFF2DD4BF);
  static const darkPrimaryLight = Color(0xFF134E4A);
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkInputBackground = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);
  static const darkShadow = Colors.black;
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.inputBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.shadow,
    required this.handle,
    required this.iconMuted,
    required this.iconStrong,
    required this.primarySoft,
    required this.successSoft,
    required this.dangerSoft,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color inputBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color shadow;
  final Color handle;
  final Color iconMuted;
  final Color iconStrong;
  final Color primarySoft;
  final Color successSoft;
  final Color dangerSoft;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceMuted,
    Color? inputBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? shadow,
    Color? handle,
    Color? iconMuted,
    Color? iconStrong,
    Color? primarySoft,
    Color? successSoft,
    Color? dangerSoft,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      inputBackground: inputBackground ?? this.inputBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      handle: handle ?? this.handle,
      iconMuted: iconMuted ?? this.iconMuted,
      iconStrong: iconStrong ?? this.iconStrong,
      primarySoft: primarySoft ?? this.primarySoft,
      successSoft: successSoft ?? this.successSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
          surfaceElevated,
      surfaceMuted:
          Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      inputBackground:
          Color.lerp(inputBackground, other.inputBackground, t) ??
          inputBackground,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      border: Color.lerp(border, other.border, t) ?? border,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
      handle: Color.lerp(handle, other.handle, t) ?? handle,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t) ?? iconMuted,
      iconStrong: Color.lerp(iconStrong, other.iconStrong, t) ?? iconStrong,
      primarySoft:
          Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
      successSoft:
          Color.lerp(successSoft, other.successSoft, t) ?? successSoft,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t) ?? dangerSoft,
    );
  }
}

extension AppPaletteContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get appColorScheme => appTheme.colorScheme;
  AppPalette get appPalette => appTheme.extension<AppPalette>()!;
  bool get isDarkMode => appTheme.brightness == Brightness.dark;
}
