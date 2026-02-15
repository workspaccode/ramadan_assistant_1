import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  final LocationService _locationService;
  final PrayerService _prayerService;
  Timer? _timer;

  PrayerTimesBloc(this._locationService, this._prayerService)
    : super(PrayerTimesInitial()) {
    on<LoadPrayerTimes>(_onLoadPrayerTimes);
    on<RefreshPrayerTimes>(_onRefreshPrayerTimes);
    on<UpdateCurrentTime>(_onUpdateCurrentTime);
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(PrayerTimesLoading());
    try {
      final position = await _locationService.getCurrentLocation();
      final prefs = await SharedPreferences.getInstance();

      String? methodId = prefs.getString('calculation_method');
      String? madhabId = prefs.getString('madhab');

      String locationName = "Unknown Location";
      String? country;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          locationName = "${p.locality}, ${p.country}";
          country = p.country;
        }
      } catch (_) {}

      // Auto-detect calculation method if not set
      if (methodId == null && country != null) {
        methodId = _getAutoMethodId(country);
        if (methodId != null) {
          await prefs.setString('calculation_method', methodId);
        }
      }

      final prayerTimes = _prayerService.getPrayerTimes(
        position,
        methodId: methodId,
        madhabId: madhabId,
      );

      emit(
        PrayerTimesLoaded(
          prayerTimes: prayerTimes,
          locationName: locationName,
          currentTime: DateTime.now(),
        ),
      );

      emit(
        PrayerTimesLoaded(
          prayerTimes: prayerTimes,
          locationName: locationName,
          currentTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(PrayerTimesError(e.toString()));
    }
  }

  void _onUpdateCurrentTime(
    UpdateCurrentTime event,
    Emitter<PrayerTimesState> emit,
  ) {
    if (state is PrayerTimesLoaded) {
      final currentState = state as PrayerTimesLoaded;
      emit(currentState.copyWith(currentTime: event.currentTime));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  String? _getAutoMethodId(String country) {
    country = country.toLowerCase();
    if (country.contains('egypt')) return 'egyptian';
    if (country.contains('saudi') || country.contains('makkah')) {
      return 'ummAlQura';
    }
    if (country.contains('dubai') || country.contains('emirates')) {
      return 'dubai';
    }
    if (country.contains('qatar')) return 'qatar';
    if (country.contains('kuwait')) return 'kuwait';
    if (country.contains('pakistan')) return 'karachi';
    if (country.contains('singapore')) return 'singapore';
    if (country.contains('usa') ||
        country.contains('canada') ||
        country.contains('america')) {
      return 'northAmerica';
    }
    return 'muslimWorldLeague';
  }

  Future<void> _onRefreshPrayerTimes(
    RefreshPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    add(LoadPrayerTimes());
  }
}
