import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';

abstract class AdhanScreenState extends Equatable {
  const AdhanScreenState();

  @override
  List<Object?> get props => [];
}

class AdhanScreenInitial extends AdhanScreenState {}

class AdhanScreenPlaying extends AdhanScreenState {
  final String prayerName;
  final Duration duration;
  final int iqamaCountdown;
  final bool showIqamaReminder;

  const AdhanScreenPlaying({
    required this.prayerName,
    required this.duration,
    required this.iqamaCountdown,
    this.showIqamaReminder = false,
  });

  @override
  List<Object?> get props => [
    prayerName,
    duration,
    iqamaCountdown,
    showIqamaReminder,
  ];

  AdhanScreenPlaying copyWith({
    String? prayerName,
    Duration? duration,
    int? iqamaCountdown,
    bool? showIqamaReminder,
  }) {
    return AdhanScreenPlaying(
      prayerName: prayerName ?? this.prayerName,
      duration: duration ?? this.duration,
      iqamaCountdown: iqamaCountdown ?? this.iqamaCountdown,
      showIqamaReminder: showIqamaReminder ?? this.showIqamaReminder,
    );
  }
}

class AdhanScreenCompleted extends AdhanScreenState {
  final String prayerName;

  const AdhanScreenCompleted(this.prayerName);

  @override
  List<Object?> get props => [prayerName];
}

abstract class AdhanScreenEvent extends Equatable {
  const AdhanScreenEvent();

  @override
  List<Object?> get props => [];
}

class PlayAdhan extends AdhanScreenEvent {
  final String prayerName;
  final int iqamaDelayMinutes;

  const PlayAdhan(this.prayerName, {this.iqamaDelayMinutes = 10});

  @override
  List<Object?> get props => [prayerName, iqamaDelayMinutes];
}

class StopAdhan extends AdhanScreenEvent {}

class TickIqama extends AdhanScreenEvent {}

class AdhanScreenBloc extends Bloc<AdhanScreenEvent, AdhanScreenState> {
  final AudioService _audioService = AudioService();
  Timer? _timer;

  AdhanScreenBloc({required String prayerName, int iqamaDelayMinutes = 10})
    : super(AdhanScreenInitial()) {
    on<PlayAdhan>(_onPlayAdhan);
    on<StopAdhan>(_onStopAdhan);
    on<TickIqama>(_onTickIqama);

    add(PlayAdhan(prayerName, iqamaDelayMinutes: iqamaDelayMinutes));
  }

  Future<void> _onPlayAdhan(
    PlayAdhan event,
    Emitter<AdhanScreenState> emit,
  ) async {
    final isFajr = event.prayerName.toLowerCase() == 'fajr';
    await _audioService.playAdhan(isFajr: isFajr);

    emit(
      AdhanScreenPlaying(
        prayerName: event.prayerName,
        duration: const Duration(seconds: 30),
        iqamaCountdown: event.iqamaDelayMinutes * 60,
      ),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickIqama());
    });
  }

  void _onTickIqama(TickIqama event, Emitter<AdhanScreenState> emit) {
    if (state is AdhanScreenPlaying) {
      final currentState = state as AdhanScreenPlaying;
      if (currentState.iqamaCountdown > 0) {
        emit(
          currentState.copyWith(
            iqamaCountdown: currentState.iqamaCountdown - 1,
          ),
        );
      } else if (!currentState.showIqamaReminder) {
        _timer?.cancel();
        emit(currentState.copyWith(showIqamaReminder: true));
        _audioService.playIqamaReminder();
      }
    }
  }

  void _onStopAdhan(StopAdhan event, Emitter<AdhanScreenState> emit) {
    _audioService.stop();
    _timer?.cancel();
    if (state is AdhanScreenPlaying) {
      emit(AdhanScreenCompleted((state as AdhanScreenPlaying).prayerName));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioService.stop();
    return super.close();
  }
}
