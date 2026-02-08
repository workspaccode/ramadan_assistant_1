import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_event.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _keyCalculationMethod = 'calculation_method';
  static const String _keyMadhab = 'madhab';
  static const String _keyIqamaDelay = 'iqama_delay';
  static const String _keyIqamaSystem = 'iqama_system';
  static const String _keyIqamaPreset = 'iqama_preset';

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateMadhab>(_onUpdateMadhab);
    on<UpdateIqamaDelay>(_onUpdateIqamaDelay);
    on<UpdateIqamaSystem>(_onUpdateIqamaSystem);
    on<UpdateIqamaPreset>(_onUpdateIqamaPreset);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(
        SettingsLoaded(
          calculationMethod:
              prefs.getString(_keyCalculationMethod) ?? 'muslimWorldLeague',
          madhab: prefs.getString(_keyMadhab) ?? 'shafi',
          iqamaDelayMinutes: prefs.getInt(_keyIqamaDelay) ?? 10,
          iqamaSystem: prefs.getString(_keyIqamaSystem) ?? 'manual',
          iqamaPreset: prefs.getString(_keyIqamaPreset) ?? 'saudi',
        ),
      );
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onUpdateCalculationMethod(
    UpdateCalculationMethod event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCalculationMethod, event.method);
      emit(currentState.copyWith(calculationMethod: event.method));
    }
  }

  Future<void> _onUpdateMadhab(
    UpdateMadhab event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMadhab, event.madhab);
      emit(currentState.copyWith(madhab: event.madhab));
    }
  }

  Future<void> _onUpdateIqamaDelay(
    UpdateIqamaDelay event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyIqamaDelay, event.delayMinutes);
      emit(currentState.copyWith(iqamaDelayMinutes: event.delayMinutes));
    }
  }

  Future<void> _onUpdateIqamaSystem(
    UpdateIqamaSystem event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyIqamaSystem, event.system);
      emit(currentState.copyWith(iqamaSystem: event.system));
    }
  }

  Future<void> _onUpdateIqamaPreset(
    UpdateIqamaPreset event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyIqamaPreset, event.preset);
      emit(currentState.copyWith(iqamaPreset: event.preset));
    }
  }
}
