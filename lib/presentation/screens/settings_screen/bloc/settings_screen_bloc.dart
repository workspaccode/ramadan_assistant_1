import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsScreenState extends Equatable {
  const SettingsScreenState();

  @override
  List<Object?> get props => [];
}

class SettingsScreenInitial extends SettingsScreenState {}

class SettingsScreenLoading extends SettingsScreenState {}

class SettingsScreenLoaded extends SettingsScreenState {
  final String calculationMethod;
  final String madhab;
  final String iqamaSystem;
  final String iqamaPreset;
  final Map<String, int> iqamaDelays;
  final String fajrAdhanSound;
  final String otherAdhanSound;
  final String fajrIqamaSound;
  final String otherIqamaSound;
  final double fontSizeMultiplier;
  final String? colorPaletteId;
  final String? country;
  final String? city;

  const SettingsScreenLoaded({
    required this.calculationMethod,
    required this.madhab,
    required this.iqamaSystem,
    required this.iqamaPreset,
    required this.iqamaDelays,
    required this.fajrAdhanSound,
    required this.otherAdhanSound,
    required this.fajrIqamaSound,
    required this.otherIqamaSound,
    required this.fontSizeMultiplier,
    this.colorPaletteId,
    this.country,
    this.city,
  });

  SettingsScreenLoaded copyWith({
    String? calculationMethod,
    String? madhab,
    String? iqamaSystem,
    String? iqamaPreset,
    Map<String, int>? iqamaDelays,
    String? fajrAdhanSound,
    String? otherAdhanSound,
    String? fajrIqamaSound,
    String? otherIqamaSound,
    double? fontSizeMultiplier,
    String? colorPaletteId,
    String? country,
    String? city,
  }) {
    return SettingsScreenLoaded(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      iqamaSystem: iqamaSystem ?? this.iqamaSystem,
      iqamaPreset: iqamaPreset ?? this.iqamaPreset,
      iqamaDelays: iqamaDelays ?? this.iqamaDelays,
      fajrAdhanSound: fajrAdhanSound ?? this.fajrAdhanSound,
      otherAdhanSound: otherAdhanSound ?? this.otherAdhanSound,
      fajrIqamaSound: fajrIqamaSound ?? this.fajrIqamaSound,
      otherIqamaSound: otherIqamaSound ?? this.otherIqamaSound,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      colorPaletteId: colorPaletteId ?? this.colorPaletteId,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }

  @override
  List<Object?> get props => [
    calculationMethod,
    madhab,
    iqamaSystem,
    iqamaPreset,
    iqamaDelays,
    fajrAdhanSound,
    otherAdhanSound,
    fajrIqamaSound,
    otherIqamaSound,
    fontSizeMultiplier,
    colorPaletteId,
    country,
    city,
  ];
}

class SettingsScreenError extends SettingsScreenState {
  final String message;
  const SettingsScreenError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class SettingsScreenEvent extends Equatable {
  const SettingsScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsScreenEvent {}

class UpdateCalculationMethod extends SettingsScreenEvent {
  final String method;
  const UpdateCalculationMethod(this.method);
  @override
  List<Object?> get props => [method];
}

class UpdateMadhab extends SettingsScreenEvent {
  final String madhab;
  const UpdateMadhab(this.madhab);
  @override
  List<Object?> get props => [madhab];
}

class UpdateIqamaSystem extends SettingsScreenEvent {
  final String system;
  const UpdateIqamaSystem(this.system);
  @override
  List<Object?> get props => [system];
}

class UpdateIqamaPreset extends SettingsScreenEvent {
  final String preset;
  const UpdateIqamaPreset(this.preset);
  @override
  List<Object?> get props => [preset];
}

class UpdateIqamaDelay extends SettingsScreenEvent {
  final String prayer;
  final int minutes;
  const UpdateIqamaDelay(this.prayer, this.minutes);
  @override
  List<Object?> get props => [prayer, minutes];
}

class UpdateAdhanSound extends SettingsScreenEvent {
  final bool isFajr;
  final String sound;
  const UpdateAdhanSound({required this.isFajr, required this.sound});
  @override
  List<Object?> get props => [isFajr, sound];
}

class UpdateIqamaSound extends SettingsScreenEvent {
  final bool isFajr;
  final String sound;
  const UpdateIqamaSound({required this.isFajr, required this.sound});
  @override
  List<Object?> get props => [isFajr, sound];
}

class UpdateFontSize extends SettingsScreenEvent {
  final double multiplier;
  const UpdateFontSize(this.multiplier);
  @override
  List<Object?> get props => [multiplier];
}

class UpdateSettingsColorPalette extends SettingsScreenEvent {
  final String paletteId;
  const UpdateSettingsColorPalette(this.paletteId);
  @override
  List<Object?> get props => [paletteId];
}

class RefreshLocation extends SettingsScreenEvent {}

class CheckForUpdates extends SettingsScreenEvent {}

class ResetAllData extends SettingsScreenEvent {}

class SettingsScreenBloc
    extends Bloc<SettingsScreenEvent, SettingsScreenState> {
  static const String _keyCalculationMethod = 'calculation_method';
  static const String _keyMadhab = 'madhab';
  static const String _keyIqamaSystem = 'iqama_system';
  static const String _keyIqamaPreset = 'iqama_preset';
  static const String _keyIqamaDelays = 'iqama_delays_map';
  static const String _keyFajrAdhan = 'fajr_adhan_sound';
  static const String _keyOtherAdhan = 'other_adhan_sound';
  static const String _keyFajrIqama = 'fajr_iqama_sound';
  static const String _keyOtherIqama = 'other_iqama_sound';
  static const String _keyFontSize = 'font_size_multiplier';
  static const String _keyColorPalette = 'color_palette_id';

  final LocationService _locationService;
  final UpdateService _updateService = UpdateService();

  SettingsScreenBloc(this._locationService) : super(SettingsScreenInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateMadhab>(_onUpdateMadhab);
    on<UpdateIqamaSystem>(_onUpdateIqamaSystem);
    on<UpdateIqamaPreset>(_onUpdateIqamaPreset);
    on<UpdateIqamaDelay>(_onUpdateIqamaDelay);
    on<UpdateAdhanSound>(_onUpdateAdhanSound);
    on<UpdateIqamaSound>(_onUpdateIqamaSound);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateSettingsColorPalette>(_onUpdateSettingsColorPalette);
    on<RefreshLocation>(_onRefreshLocation);
    on<CheckForUpdates>(_onCheckForUpdates);
    on<ResetAllData>(_onResetAllData);

    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsScreenState> emit,
  ) async {
    emit(SettingsScreenLoading());
    try {
      final prefs = await SharedPreferences.getInstance();

      final delaysJson = prefs.getString(_keyIqamaDelays);
      final Map<String, int> delays = delaysJson != null
          ? Map<String, int>.from(jsonDecode(delaysJson))
          : {'fajr': 20, 'dhuhr': 15, 'asr': 15, 'maghrib': 5, 'isha': 10};

      emit(
        SettingsScreenLoaded(
          calculationMethod:
              prefs.getString(_keyCalculationMethod) ?? 'muslimWorldLeague',
          madhab: prefs.getString(_keyMadhab) ?? 'shafi',
          iqamaSystem: prefs.getString(_keyIqamaSystem) ?? 'manual',
          iqamaPreset: prefs.getString(_keyIqamaPreset) ?? 'saudi',
          iqamaDelays: delays,
          fajrAdhanSound: prefs.getString(_keyFajrAdhan) ?? 'azanfajr.mp3',
          otherAdhanSound: prefs.getString(_keyOtherAdhan) ?? 'azan8.mp3',
          fajrIqamaSound: prefs.getString(_keyFajrIqama) ?? 'MakkahIQamah.mp3',
          otherIqamaSound:
              prefs.getString(_keyOtherIqama) ?? 'MakkahIQamah.mp3',
          fontSizeMultiplier: prefs.getDouble(_keyFontSize) ?? 1.0,
          colorPaletteId: prefs.getString(_keyColorPalette),
          country: prefs.getString('current_country'),
          city: prefs.getString('current_city'),
        ),
      );

      // Auto-refresh location on load if not present
      if (prefs.getString('current_country') == null) {
        add(RefreshLocation());
      }
    } catch (e) {
      emit(SettingsScreenError(e.toString()));
    }
  }

  Future<void> _onUpdateCalculationMethod(
    UpdateCalculationMethod event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCalculationMethod, event.method);
      emit(
        (state as SettingsScreenLoaded).copyWith(
          calculationMethod: event.method,
        ),
      );
    }
  }

  Future<void> _onUpdateMadhab(
    UpdateMadhab event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMadhab, event.madhab);
      emit((state as SettingsScreenLoaded).copyWith(madhab: event.madhab));
    }
  }

  Future<void> _onUpdateIqamaSystem(
    UpdateIqamaSystem event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyIqamaSystem, event.system);
      emit((state as SettingsScreenLoaded).copyWith(iqamaSystem: event.system));
    }
  }

  Future<void> _onUpdateIqamaPreset(
    UpdateIqamaPreset event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyIqamaPreset, event.preset);
      emit((state as SettingsScreenLoaded).copyWith(iqamaPreset: event.preset));
    }
  }

  Future<void> _onUpdateIqamaDelay(
    UpdateIqamaDelay event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final s = state as SettingsScreenLoaded;
      final newDelays = Map<String, int>.from(s.iqamaDelays);
      newDelays[event.prayer] = event.minutes;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyIqamaDelays, jsonEncode(newDelays));
      emit(s.copyWith(iqamaDelays: newDelays));
    }
  }

  Future<void> _onUpdateAdhanSound(
    UpdateAdhanSound event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      if (event.isFajr) {
        await prefs.setString(_keyFajrAdhan, event.sound);
        emit(
          (state as SettingsScreenLoaded).copyWith(fajrAdhanSound: event.sound),
        );
      } else {
        await prefs.setString(_keyOtherAdhan, event.sound);
        emit(
          (state as SettingsScreenLoaded).copyWith(
            otherAdhanSound: event.sound,
          ),
        );
      }
    }
  }

  Future<void> _onUpdateIqamaSound(
    UpdateIqamaSound event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      if (event.isFajr) {
        await prefs.setString(_keyFajrIqama, event.sound);
        emit(
          (state as SettingsScreenLoaded).copyWith(fajrIqamaSound: event.sound),
        );
      } else {
        await prefs.setString(_keyOtherIqama, event.sound);
        emit(
          (state as SettingsScreenLoaded).copyWith(
            otherIqamaSound: event.sound,
          ),
        );
      }
    }
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSize event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, event.multiplier);
      emit(
        (state as SettingsScreenLoaded).copyWith(
          fontSizeMultiplier: event.multiplier,
        ),
      );
    }
  }

  Future<void> _onUpdateSettingsColorPalette(
    UpdateSettingsColorPalette event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyColorPalette, event.paletteId);
      emit(
        (state as SettingsScreenLoaded).copyWith(
          colorPaletteId: event.paletteId,
        ),
      );
    }
  }

  Future<void> _onRefreshLocation(
    RefreshLocation event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      try {
        final position = await _locationService.getCurrentLocation();
        final placemark = await _locationService.getAddressFromCoordinates(
          position,
        );
        if (placemark != null) {
          final country = placemark.country;
          final city = placemark.locality ?? placemark.subAdministrativeArea;

          final prefs = await SharedPreferences.getInstance();
          if (country != null) {
            await prefs.setString('current_country', country);
          }
          if (city != null) await prefs.setString('current_city', city);

          emit(
            (state as SettingsScreenLoaded).copyWith(
              country: country,
              city: city,
            ),
          );
        }
      } catch (e) {
        print("Location refresh error: $e");
      }
    }
  }

  Future<void> _onCheckForUpdates(
    CheckForUpdates event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final available = await _updateService.isUpdateAvailable();
      if (available) {
        await _updateService.downloadUpdate();
        // In a real app, you might show another Snackbar saying update is ready
      }
    }
  }

  Future<void> _onResetAllData(
    ResetAllData event,
    Emitter<SettingsScreenState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    add(LoadSettings());
  }
}
