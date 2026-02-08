import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _keyDarkMode = 'is_dark_mode';

  ThemeBloc() : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleDarkMode>(_onToggleDarkMode);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
    emit(ThemeLoaded(isDarkMode));
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, event.isDarkMode);
    emit(ThemeLoaded(event.isDarkMode));
  }
}
