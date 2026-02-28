import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';

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

      final prayerData = await _prayerService.getCurrentPrayerData(
        position,
        localeLanguageCode: event.locale,
      );

      emit(
        PrayerTimesLoaded(
          prayerTimes: prayerData.prayerTimes,
          locationName: prayerData.locationName,
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

  Future<void> _onRefreshPrayerTimes(
    RefreshPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    add(LoadPrayerTimes());
  }
}
