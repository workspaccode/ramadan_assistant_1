import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyFontSize = 'font_size_multiplier';
  static const String _keyColorPalette = 'color_palette_id';

  ThemeBloc() : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<UpdateFontSizeMultiplier>(_onUpdateFontSizeMultiplier);
    on<UpdateColorPalette>(_onUpdateColorPalette);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
    final fontSize = prefs.getDouble(_keyFontSize) ?? 1.0;
    final palette = prefs.getString(_keyColorPalette);
    emit(
      ThemeLoaded(
        isDarkMode: isDarkMode,
        fontSizeMultiplier: fontSize,
        colorPaletteId: palette,
      ),
    );
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final s = state as ThemeLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, event.isDarkMode);
      emit(
        ThemeLoaded(
          isDarkMode: event.isDarkMode,
          fontSizeMultiplier: s.fontSizeMultiplier,
          colorPaletteId: s.colorPaletteId,
        ),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, event.isDarkMode);
      add(LoadTheme());
    }
  }

  Future<void> _onUpdateFontSizeMultiplier(
    UpdateFontSizeMultiplier event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final s = state as ThemeLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, event.multiplier);
      emit(
        ThemeLoaded(
          isDarkMode: s.isDarkMode,
          fontSizeMultiplier: event.multiplier,
          colorPaletteId: s.colorPaletteId,
        ),
      );
    }
  }

  Future<void> _onUpdateColorPalette(
    UpdateColorPalette event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final s = state as ThemeLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyColorPalette, event.paletteId);
      emit(
        ThemeLoaded(
          isDarkMode: s.isDarkMode,
          fontSizeMultiplier: s.fontSizeMultiplier,
          colorPaletteId: event.paletteId,
        ),
      );
    }
  }
}
