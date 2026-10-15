import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _logger = Logger();

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
  final double fontSizeMultiplier;
  final String? colorPaletteId;
  final String? country;
  final String? city;
  final String appIcon;
  final bool notificationsEnabled;
  final int hijriAdjustment;

  const SettingsScreenLoaded({
    required this.calculationMethod,
    required this.madhab,
    required this.fontSizeMultiplier,
    this.colorPaletteId,
    this.country,
    this.city,
    required this.appIcon,
    required this.notificationsEnabled,
    required this.hijriAdjustment,
  });

  SettingsScreenLoaded copyWith({
    String? calculationMethod,
    String? madhab,
    double? fontSizeMultiplier,
    String? colorPaletteId,
    String? country,
    String? city,
    String? appIcon,
    bool? notificationsEnabled,
    int? hijriAdjustment,
  }) {
    return SettingsScreenLoaded(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      colorPaletteId: colorPaletteId ?? this.colorPaletteId,
      country: country ?? this.country,
      city: city ?? this.city,
      appIcon: appIcon ?? this.appIcon,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
    );
  }

  @override
  List<Object?> get props => [
    calculationMethod,
    madhab,
    fontSizeMultiplier,
    colorPaletteId,
    country,
    city,
    appIcon,
    notificationsEnabled,
    hijriAdjustment,
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

class RefreshLocation extends SettingsScreenEvent {
  const RefreshLocation({this.requestPermission = true});
  final bool requestPermission;
  @override
  List<Object?> get props => [requestPermission];
}

class UpdateAppIcon extends SettingsScreenEvent {
  final String iconName;
  const UpdateAppIcon(this.iconName);
  @override
  List<Object?> get props => [iconName];
}

class ToggleNotifications extends SettingsScreenEvent {
  final bool enabled;
  const ToggleNotifications(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateHijriAdjustment extends SettingsScreenEvent {
  final int adjustment;
  const UpdateHijriAdjustment(this.adjustment);
  @override
  List<Object?> get props => [adjustment];
}

class CheckForUpdates extends SettingsScreenEvent {}

class ResetAllData extends SettingsScreenEvent {}

class SettingsScreenBloc
    extends Bloc<SettingsScreenEvent, SettingsScreenState> {
  static const String _keyCalculationMethod = 'calculation_method';
  static const String _keyMadhab = 'madhab';
  static const String _keyFontSize = 'font_size_multiplier';
  static const String _keyColorPalette = 'color_palette_id';
  static const String _keyAppIcon = 'app_icon_name';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyHijriAdjustment = 'hijri_adjustment';

  final LocationService _locationService;
  final SmartUpdateManager _updateManager = sl<SmartUpdateManager>();

  SettingsScreenBloc(this._locationService) : super(SettingsScreenInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateMadhab>(_onUpdateMadhab);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateSettingsColorPalette>(_onUpdateSettingsColorPalette);
    on<RefreshLocation>(_onRefreshLocation);
    on<UpdateAppIcon>(_onUpdateAppIcon);
    on<ToggleNotifications>(_onToggleNotifications);
    on<UpdateHijriAdjustment>(_onUpdateHijriAdjustment);
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

      emit(
        SettingsScreenLoaded(
          calculationMethod:
              prefs.getString(_keyCalculationMethod) ?? 'muslimWorldLeague',
          madhab: prefs.getString(_keyMadhab) ?? 'shafi',
          fontSizeMultiplier: prefs.getDouble(_keyFontSize) ?? 1.0,
          colorPaletteId: prefs.getString(_keyColorPalette),
          country: prefs.getString('current_country'),
          city: prefs.getString('current_city'),
          appIcon: prefs.getString(_keyAppIcon) ?? 'default',
          notificationsEnabled: prefs.getBool(_keyNotificationsEnabled) ?? true,
          hijriAdjustment: prefs.getInt(_keyHijriAdjustment) ?? 0,
        ),
      );

      // Auto-refresh location on load if not present
      if (prefs.getString('current_country') == null) {
        add(const RefreshLocation(requestPermission: false));
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
        final position = await _locationService.getCurrentLocation(
          requestPermission: event.requestPermission,
        );
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
        _logger.e('Location refresh error', error: e);
      }
    }
  }

  Future<void> _onUpdateAppIcon(
    UpdateAppIcon event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      try {
        final currentIcon = (state as SettingsScreenLoaded).appIcon;
        if (currentIcon == event.iconName) return;

        // Perform icon switch
        if (await FlutterDynamicIconPlus.supportsAlternateIcons) {
          await FlutterDynamicIconPlus.setAlternateIconName(
            iconName: event.iconName == 'default' ? null : event.iconName,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyAppIcon, event.iconName);
          emit(
            (state as SettingsScreenLoaded).copyWith(appIcon: event.iconName),
          );
        }
      } catch (e) {
        _logger.e('Dynamic icon error', error: e);
      }
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotificationsEnabled, event.enabled);

      if (event.enabled) {
        // Maybe re-initialize notifications or schedule them
      } else {
        await NotificationService.cancelAllNotifications();
      }

      emit(
        (state as SettingsScreenLoaded).copyWith(
          notificationsEnabled: event.enabled,
        ),
      );
    }
  }

  Future<void> _onUpdateHijriAdjustment(
    UpdateHijriAdjustment event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyHijriAdjustment, event.adjustment);
      emit(
        (state as SettingsScreenLoaded).copyWith(
          hijriAdjustment: event.adjustment,
        ),
      );
    }
  }

  Future<void> _onCheckForUpdates(
    CheckForUpdates event,
    Emitter<SettingsScreenState> emit,
  ) async {
    if (state is SettingsScreenLoaded) {
      await _updateManager.checkAutoUpdates();
    }
  }

  Future<void> _onResetAllData(
    ResetAllData event,
    Emitter<SettingsScreenState> emit,
  ) async {
    // This action restores settings. Clearing all preferences also erased
    // unrelated notification history.
    emit(SettingsScreenLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in [
        _keyCalculationMethod,
        _keyMadhab,
        _keyFontSize,
        _keyColorPalette,
        _keyAppIcon,
        _keyNotificationsEnabled,
        _keyHijriAdjustment,
      ]) {
        if (!await prefs.remove(key)) throw StateError('Settings reset failed');
      }
      add(LoadSettings());
    } catch (error) {
      emit(SettingsScreenError(error.toString()));
    }
  }
}
