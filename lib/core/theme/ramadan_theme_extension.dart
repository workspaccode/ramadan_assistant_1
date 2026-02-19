import 'package:flutter/material.dart';

class RamadanThemeExtension extends ThemeExtension<RamadanThemeExtension> {
  const RamadanThemeExtension({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.background2,
    required this.cardSurface,
    required this.glassSurface,
    required this.borderColor,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDim,
  });

  // Brand
  final Color primary;
  final Color secondary;

  // Surfaces
  final Color background;
  final Color background2;
  final Color cardSurface;
  final Color glassSurface;
  final Color borderColor;

  // Functional
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color accent;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textDim;

  @override
  RamadanThemeExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? background2,
    Color? cardSurface,
    Color? glassSurface,
    Color? borderColor,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDim,
  }) {
    return RamadanThemeExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      background2: background2 ?? this.background2,
      cardSurface: cardSurface ?? this.cardSurface,
      glassSurface: glassSurface ?? this.glassSurface,
      borderColor: borderColor ?? this.borderColor,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDim: textDim ?? this.textDim,
    );
  }

  @override
  RamadanThemeExtension lerp(
    ThemeExtension<RamadanThemeExtension>? other,
    double t,
  ) {
    if (other is! RamadanThemeExtension) return this;
    return RamadanThemeExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      background2: Color.lerp(background2, other.background2, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
    );
  }
}
