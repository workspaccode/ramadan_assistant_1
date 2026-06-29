import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontCairo = 'Cairo';
  static const String fontAmiriQuran = 'AmiriQuran';

  // Base TextStyle for Cairo font
  static TextStyle cairo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: fontCairo,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
    );
  }

  // Base TextStyle for Quran text using AmiriQuran
  static TextStyle amiriQuran({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontAmiriQuran,
      fontSize: fontSize,
      color: color,
      height: height ?? 2.2,
    );
  }
}
