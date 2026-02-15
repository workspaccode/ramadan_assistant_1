import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Emerald Gold (Default)
  static const Color primaryEmerald = Color(0xFF06402B);
  static const Color secondaryGold = Color(0xFFD4AF37);

  // Midnight Royal
  static const Color primaryNavy = Color(0xFF001F3F);
  static const Color secondarySilver = Color(0xFFC0C0C0);

  // Desert Rose
  static const Color primarySand = Color(0xFFC2B280);
  static const Color secondaryMaroon = Color(0xFF800000);

  // Backward compatibility
  static Color get primaryColor => primaryEmerald;
  static Color get secondaryColor => secondaryGold;

  static ThemeData get lightTheme => getTheme(isDarkMode: false);
  static ThemeData get darkTheme => getTheme(isDarkMode: true);

  static ThemeData getTheme({
    required bool isDarkMode,
    double fontSizeMultiplier = 1.0,
    String? colorPaletteId,
  }) {
    Color primary = isDarkMode ? secondaryGold : primaryEmerald;
    Color secondary = isDarkMode ? primaryEmerald : secondaryGold;
    Color background = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFFDFCF0);
    Color surface = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    if (colorPaletteId == 'midnight') {
      primary = isDarkMode ? secondarySilver : primaryNavy;
      secondary = isDarkMode ? primaryNavy : secondarySilver;
    } else if (colorPaletteId == 'desert') {
      primary = isDarkMode ? secondaryMaroon : primarySand;
      secondary = isDarkMode ? primarySand : secondaryMaroon;
    }

    final TextTheme baseTextTheme = isDarkMode
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    TextTheme textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    // Scale all fonts
    textTheme = _scaleTextTheme(textTheme, fontSizeMultiplier);

    // Apply Amiri for headlines
    textTheme = textTheme.copyWith(
      displayLarge: GoogleFonts.amiri(
        fontSize: (textTheme.displayLarge?.fontSize ?? 32),
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: (textTheme.headlineMedium?.fontSize ?? 24),
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(color: surface, surfaceTintColor: surface),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? surface : primary,
        foregroundColor: secondary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static TextTheme _scaleTextTheme(TextTheme base, double multiplier) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: (base.displayLarge?.fontSize ?? 32) * multiplier,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: (base.displayMedium?.fontSize ?? 28) * multiplier,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: (base.displaySmall?.fontSize ?? 24) * multiplier,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: (base.headlineLarge?.fontSize ?? 32) * multiplier,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: (base.headlineMedium?.fontSize ?? 28) * multiplier,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: (base.headlineSmall?.fontSize ?? 24) * multiplier,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: (base.titleLarge?.fontSize ?? 22) * multiplier,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: (base.titleMedium?.fontSize ?? 16) * multiplier,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: (base.titleSmall?.fontSize ?? 14) * multiplier,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: (base.bodyLarge?.fontSize ?? 16) * multiplier,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: (base.bodyMedium?.fontSize ?? 14) * multiplier,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: (base.bodySmall?.fontSize ?? 12) * multiplier,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: (base.labelLarge?.fontSize ?? 14) * multiplier,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: (base.labelMedium?.fontSize ?? 12) * multiplier,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: (base.labelSmall?.fontSize ?? 11) * multiplier,
      ),
    );
  }
}
