import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // Typography
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  // Colors
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get secondaryColor => colorScheme.secondary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get backgroundColor => colorScheme.surface;
  Color get onBackgroundColor => colorScheme.onSurface;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get cardColor => theme.cardColor;
  Color get errorColor => colorScheme.error;

  // Localization
  String tr(
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  }) {
    return key.tr(args: args, namedArgs: namedArgs, gender: gender);
  }

  bool get isRtl => Directionality.of(this) == TextDirection.RTL;

  // Dimensions
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // Navigation
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T extends Object?>(Route<T> route) =>
      Navigator.of(this).push(route);

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) => Navigator.of(this).pushNamed(routeName, arguments: arguments);
}
