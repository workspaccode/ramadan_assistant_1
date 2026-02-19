import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  // Brand / Palettes
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;

  // Surfaces
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color groupedBackground;

  // Borders & Accents
  final Color borderColor;
  final Color dividerColor;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // iOS Semantic Colors
  final Color iosGreen;
  final Color iosRed;
  final Color iosOrange;
  final Color iosBlue;
  final Color iosIndigo;

  const AppThemeExtension({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.groupedBackground,
    required this.borderColor,
    required this.dividerColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.iosGreen,
    required this.iosRed,
    required this.iosOrange,
    required this.iosBlue,
    required this.iosIndigo,
  });

  @override
  AppThemeExtension copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? groupedBackground,
    Color? borderColor,
    Color? dividerColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? iosGreen,
    Color? iosRed,
    Color? iosOrange,
    Color? iosBlue,
    Color? iosIndigo,
  }) {
    return AppThemeExtension(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBackground: cardBackground ?? this.cardBackground,
      groupedBackground: groupedBackground ?? this.groupedBackground,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      iosGreen: iosGreen ?? this.iosGreen,
      iosRed: iosRed ?? this.iosRed,
      iosOrange: iosOrange ?? this.iosOrange,
      iosBlue: iosBlue ?? this.iosBlue,
      iosIndigo: iosIndigo ?? this.iosIndigo,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      groupedBackground: Color.lerp(
        groupedBackground,
        other.groupedBackground,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      iosGreen: Color.lerp(iosGreen, other.iosGreen, t)!,
      iosRed: Color.lerp(iosRed, other.iosRed, t)!,
      iosOrange: Color.lerp(iosOrange, other.iosOrange, t)!,
      iosBlue: Color.lerp(iosBlue, other.iosBlue, t)!,
      iosIndigo: Color.lerp(iosIndigo, other.iosIndigo, t)!,
    );
  }
}
