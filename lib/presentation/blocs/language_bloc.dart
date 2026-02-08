import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _keyLanguage = 'language_code';

  LanguageBloc() : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_keyLanguage) ?? 'ar';
    emit(LanguageLoaded(languageCode));
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, event.languageCode);
    emit(LanguageLoaded(event.languageCode));
  }
}
