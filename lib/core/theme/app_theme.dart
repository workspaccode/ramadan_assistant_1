import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_assistant/core/design_system/app_text_styles.dart';

import 'ramadan_theme_extension.dart';

class AppTheme {
  AppTheme._();

  // ─── iOS System Colors ────────────────────────────────────────
  static const Color iosSystemGreen = Color(0xFF34C759);
  static const Color iosSystemRed = Color(0xFFFF3B30);
  static const Color iosSystemOrange = Color(0xFFFF9500);
  static const Color iosSystemBlue = Color(0xFF007AFF);
  static const Color iosSystemIndigo = Color(0xFF5856D6);

  static Color get primaryColor => _lightEmerald.primary;
  static Color get secondaryColor => _lightEmerald.secondary;

  // ─── DARK Extensions ─────────────────────────────────────────

  static const _darkEmerald = RamadanThemeExtension(
    primary: Color(0xFF9CD5AD),
    secondary: Color(0xFFE0BF78),
    background: Color(0xFF000000),
    background2: Color(0xFF101411),
    cardSurface: Color(0xFF151A17),
    glassSurface: Color(0x1A9CD5AD),
    borderColor: Color(0xFF303C33),
    success: Color(0xFF9CD5AD),
    error: Color(0xFFFF938A),
    warning: Color(0xFFEAB678),
    info: Color(0xFFA2C7D8),
    accent: Color(0xFFFFD85A),
    textPrimary: Color(0xFFF3F5F0),
    textSecondary: Color(0xFFB2BDB4),
    textDim: Color(0xFF8E9D91),
  );

  static const _darkMidnight = RamadanThemeExtension(
    primary: Color(0xFFC0C0C0),
    secondary: Color(0xFF001F3F),
    background: Color(0xFF000000),
    background2: Color(0xFF1C1C1E),
    cardSurface: Color(0xFF1C1C1E),
    glassSurface: Color(0x1AFFFFFF),
    borderColor: Color(0xFF2C2C2E),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    accent: Color(0xFFC0C0C0),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB2BDB4),
    textDim: Color(0xFF969F99),
  );

  static const _darkDesert = RamadanThemeExtension(
    primary: Color(0xFFC2B280),
    secondary: Color(0xFF800000),
    background: Color(0xFF000000),
    background2: Color(0xFF1C1C1E),
    cardSurface: Color(0xFF1C1C1E),
    glassSurface: Color(0x1AFFFFFF),
    borderColor: Color(0xFF2C2C2E),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    accent: Color(0xFFC2B280),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB2BDB4),
    textDim: Color(0xFF969F99),
  );

  static const _darkOcean = RamadanThemeExtension(
    primary: Color(0xFF2EC4B6),
    secondary: Color(0xFF0D4F6B),
    background: Color(0xFF000000),
    background2: Color(0xFF1C1C1E),
    cardSurface: Color(0xFF1C1C1E),
    glassSurface: Color(0x1AFFFFFF),
    borderColor: Color(0xFF2C2C2E),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    accent: Color(0xFF2EC4B6),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB2BDB4),
    textDim: Color(0xFF969F99),
  );

  // ─── LIGHT Extensions ─────────────────────────────────────────

  static const _lightEmerald = RamadanThemeExtension(
    primary: Color(0xFF0B5844),
    secondary: Color(0xFF806016),
    background: Color(0xFFFFFFFF),
    background2: Color(0xFFE1F4E9),
    cardSurface: Color(0xFFFFFFFF),
    glassSurface: Color(0x1426734D),
    borderColor: Color(0xFFDEEDE5),
    success: Color(0xFF0B5844),
    error: Color(0xFFB83B36),
    warning: Color(0xFFAA6226),
    info: Color(0xFF386D86),
    accent: Color(0xFFFFD85A),
    textPrimary: Color(0xFF1C3023),
    textSecondary: Color(0xFF52685A),
    textDim: Color(0xFF596B60),
  );

  static const _lightMidnight = RamadanThemeExtension(
    primary: Color(0xFF001F3F),
    secondary: Color(0xFFC0C0C0),
    background: Color(0xFFF2F2F7),
    background2: Color(0xFFFFFFFF),
    cardSurface: Color(0xFFFFFFFF),
    glassSurface: Color(0x1A000000),
    borderColor: Color(0xFFE5E5EA),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    accent: Color(0xFF001F3F),
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF59645C),
    textDim: Color(0xFF637167),
  );

  static const _lightDesert = RamadanThemeExtension(
    primary: Color(0xFF800000),
    secondary: Color(0xFFC2B280),
    background: Color(0xFFF2F2F7),
    background2: Color(0xFFFFFFFF),
    cardSurface: Color(0xFFFFFFFF),
    glassSurface: Color(0x1A000000),
    borderColor: Color(0xFFE5E5EA),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    accent: Color(0xFF800000),
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF59645C),
    textDim: Color(0xFF637167),
  );

  static const _lightOcean = RamadanThemeExtension(
    primary: Color(0xFF0D4F6B),
    secondary: Color(0xFF2EC4B6),
    background: Color(0xFFF2F2F7),
    background2: Color(0xFFFFFFFF),
    cardSurface: Color(0xFFFFFFFF),
    glassSurface: Color(0x1A000000),
    borderColor: Color(0xFFE5E5EA),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    accent: Color(0xFF0D4F6B),
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF59645C),
    textDim: Color(0xFF637167),
  );

  // ─── Palette Info (for Settings UI) ──────────────────────────

  static List<PaletteInfo> get availablePalettes => [
    PaletteInfo(
      id: 'emerald',
      nameAr: 'زمردي ذهبي',
      nameEn: 'Emerald Gold',
      primary: _lightEmerald.primary,
      secondary: _lightEmerald.secondary,
    ),
    PaletteInfo(
      id: 'midnight',
      nameAr: 'ليلي ملكي',
      nameEn: 'Midnight Royal',
      primary: _lightMidnight.primary,
      secondary: _lightMidnight.secondary,
    ),
    PaletteInfo(
      id: 'desert',
      nameAr: 'وردة صحراوية',
      nameEn: 'Desert Rose',
      primary: _lightDesert.primary,
      secondary: _lightDesert.secondary,
    ),
    PaletteInfo(
      id: 'ocean',
      nameAr: 'هدوء المحيط',
      nameEn: 'Ocean Calm',
      primary: _lightOcean.primary,
      secondary: _lightOcean.secondary,
    ),
  ];

  // ─── Public API ───────────────────────────────────────────────

  static ThemeData getDarkTheme(
    Locale locale, {
    String paletteId = 'emerald',
    double fontSizeMultiplier = 1.0,
  }) {
    return _buildTheme(
      ext: _getDarkExtension(paletteId),
      isDarkMode: true,
      locale: locale,
      fontSizeMultiplier: fontSizeMultiplier,
    );
  }

  static ThemeData getLightTheme(
    Locale locale, {
    String paletteId = 'emerald',
    double fontSizeMultiplier = 1.0,
  }) {
    return _buildTheme(
      ext: _getLightExtension(paletteId),
      isDarkMode: false,
      locale: locale,
      fontSizeMultiplier: fontSizeMultiplier,
    );
  }

  // ─── Extension Resolvers ──────────────────────────────────────

  static RamadanThemeExtension _getDarkExtension(String id) {
    switch (id) {
      case 'midnight':
        return _darkMidnight;
      case 'desert':
        return _darkDesert;
      case 'ocean':
        return _darkOcean;
      default:
        return _darkEmerald;
    }
  }

  static RamadanThemeExtension _getLightExtension(String id) {
    switch (id) {
      case 'midnight':
        return _lightMidnight;
      case 'desert':
        return _lightDesert;
      case 'ocean':
        return _lightOcean;
      default:
        return _lightEmerald;
    }
  }

  // ─── Font Family ──────────────────────────────────────────────

  static String? _getFontFamily(Locale locale) {
    return AppTextStyles.fontCairo;
  }

  // ─── Core Theme Builder ───────────────────────────────────────

  static ThemeData _buildTheme({
    required RamadanThemeExtension ext,
    required bool isDarkMode,
    required Locale locale,
    double fontSizeMultiplier = 1.0,
  }) {
    final fontFamily = _getFontFamily(locale);
    final baseTextTheme = isDarkMode
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final textTheme = _buildTextTheme(
      base: baseTextTheme,
      fontFamily: fontFamily,
      textPrimary: ext.textPrimary,
      textSecondary: ext.textSecondary,
      multiplier: fontSizeMultiplier,
    );

    final colorScheme = ColorScheme(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primary: ext.primary,
      onPrimary: isDarkMode ? const Color(0xFF14231A) : Colors.white,
      primaryContainer: ext.primary.withValues(alpha: 0.15),
      onPrimaryContainer: ext.primary,
      secondary: ext.secondary,
      onSecondary: isDarkMode ? Colors.black : Colors.white,
      secondaryContainer: ext.secondary.withValues(alpha: 0.15),
      onSecondaryContainer: ext.secondary,
      surface: ext.cardSurface,
      onSurface: ext.textPrimary,
      surfaceContainerHighest: isDarkMode
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFE5E5EA),
      error: ext.error,
      onError: Colors.white,
      outline: ext.borderColor,
      outlineVariant: ext.borderColor.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: ext.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ext.background,
      cardColor: ext.cardSurface,
      fontFamily: fontFamily,
      textTheme: textTheme,
      extensions: [ext],
      cupertinoOverrideTheme: getCupertinoTheme(
        isDarkMode: isDarkMode,
        locale: locale,
        fontSizeMultiplier: fontSizeMultiplier,
        paletteId: ext == _darkEmerald || ext == _lightEmerald
            ? 'emerald'
            : ext == _darkMidnight || ext == _lightMidnight
            ? 'midnight'
            : ext == _darkDesert || ext == _lightDesert
            ? 'desert'
            : 'ocean',
      ),

      // ─── Card ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: ext.cardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: ext.borderColor, width: 0.5),
        ),
      ),

      // ─── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: ext.background,
        foregroundColor: ext.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: ext.textPrimary,
        ),
        iconTheme: IconThemeData(color: ext.primary, size: 22),
        systemOverlayStyle: isDarkMode
            ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              )
            : const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
      ),

      // ─── Bottom Navigation ────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ext.background2,
        selectedItemColor: ext.primary,
        unselectedItemColor: ext.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 10 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 10 * fontSizeMultiplier,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ─── Bottom Sheet ─────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.background2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        showDragHandle: true,
        dragHandleColor: ext.textDim,
        dragHandleSize: const Size(36, 5),
      ),

      // ─── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: ext.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
          color: ext.textPrimary,
        ),
      ),

      // ─── Elevated Button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ext.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Text Button ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ext.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 17 * fontSizeMultiplier,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // ─── Outlined Button ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ext.primary,
          side: BorderSide(color: ext.primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ext.primary;
          return isDarkMode
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFFE9E9EB);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: ext.background2,
        selectedColor: ext.primary,
        showCheckmark: false,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13 * fontSizeMultiplier,
          color: ext.primary,
        ),
      ),

      // ─── List Tile ────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          fontWeight: FontWeight.w400,
          color: ext.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13 * fontSizeMultiplier,
          fontWeight: FontWeight.w400,
          color: ext.textSecondary,
        ),
      ),

      // ─── Divider ──────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDarkMode
            ? ext.borderColor
            : ext.borderColor.withValues(alpha: 0.5),
        thickness: 0.5,
        indent: 16,
        endIndent: 0,
      ),

      // ─── Input ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ext.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          fontWeight: FontWeight.w400,
          color: ext.textDim,
        ),
      ),

      // ─── TabBar ───────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: ext.primary,
        unselectedLabelColor: ext.textSecondary,
        indicatorColor: ext.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13 * fontSizeMultiplier,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
      ),

      // ─── Chip ─────────────────────────────────────────────────

      // ─── Slider ───────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: ext.primary,
        inactiveTrackColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.15)
            : const Color(0xFFE5E5EA),
        thumbColor: Colors.white,
        overlayColor: ext.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 14,
          elevation: 3,
        ),
      ),

      // ─── SnackBar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDarkMode
            ? const Color(0xFF2C2C2E)
            : const Color(0xFF1C1C1E),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14 * fontSizeMultiplier,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Progress Indicator ───────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ext.primary,
        linearMinHeight: 4,
        linearTrackColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFE5E5EA),
        circularTrackColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFE5E5EA),
      ),

      // ─── FAB ──────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ext.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ─── Icons ────────────────────────────────────────────────
      iconTheme: IconThemeData(color: ext.textPrimary, size: 22),

      // ─── Checkbox ─────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ext.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: ext.textDim, width: 1.5),
      ),

      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Text Theme Builder ───────────────────────────────────────

  static TextTheme _buildTextTheme({
    required TextTheme base,
    required String? fontFamily,
    required Color textPrimary,
    required Color textSecondary,
    double multiplier = 1.0,
  }) {
    TextStyle make(
      double size,
      FontWeight weight,
      Color color, {
      double? letterSpacing,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size * multiplier,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }

    return base.copyWith(
      displayLarge: make(34, FontWeight.w700, textPrimary, letterSpacing: 0.37),
      displayMedium: make(
        28,
        FontWeight.w700,
        textPrimary,
        letterSpacing: 0.36,
      ),
      displaySmall: make(24, FontWeight.w700, textPrimary, letterSpacing: 0.35),
      headlineLarge: make(
        22,
        FontWeight.w700,
        textPrimary,
        letterSpacing: 0.35,
      ),
      headlineMedium: make(
        20,
        FontWeight.w600,
        textPrimary,
        letterSpacing: 0.38,
      ),
      headlineSmall: make(18, FontWeight.w600, textPrimary),
      titleLarge: make(17, FontWeight.w600, textPrimary, letterSpacing: -0.41),
      titleMedium: make(15, FontWeight.w600, textPrimary),
      titleSmall: make(13, FontWeight.w600, textPrimary),
      bodyLarge: make(17, FontWeight.w400, textPrimary, letterSpacing: -0.41),
      bodyMedium: make(15, FontWeight.w400, textPrimary, letterSpacing: -0.24),
      bodySmall: make(13, FontWeight.w400, textSecondary, letterSpacing: -0.08),
      labelLarge: make(15, FontWeight.w600, textPrimary),
      labelMedium: make(12, FontWeight.w500, textSecondary),
      labelSmall: make(11, FontWeight.w400, textSecondary, letterSpacing: 0.07),
    );
  }

  // ─── Cupertino Theme ──────────────────────────────────────────

  static CupertinoThemeData getCupertinoTheme({
    required bool isDarkMode,
    String paletteId = 'emerald',
    Locale locale = const Locale('ar'),
    double fontSizeMultiplier = 1.0,
  }) {
    final ext = isDarkMode
        ? _getDarkExtension(paletteId)
        : _getLightExtension(paletteId);
    final fontFamily = _getFontFamily(locale);
    final textColor = ext.textPrimary;

    return CupertinoThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: ext.primary,
      scaffoldBackgroundColor: ext.background,
      barBackgroundColor: ext.background2.withValues(alpha: 0.94),
      textTheme: CupertinoTextThemeData(
        primaryColor: ext.primary,
        navLargeTitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 34 * fontSizeMultiplier,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.37,
          color: textColor,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          letterSpacing: -0.41,
          color: textColor,
        ),
        actionTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17 * fontSizeMultiplier,
          color: ext.primary,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 10 * fontSizeMultiplier,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Palette Info ─────────────────────────────────────────────────

class PaletteInfo {
  const PaletteInfo({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.primary,
    required this.secondary,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final Color primary;
  final Color secondary;
}
