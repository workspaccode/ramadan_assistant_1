import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

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

class AdhanScreenDhikr extends AdhanScreenState {
  final String prayerName;
  final String dhikrText;
  final int count;
  final int target;

  const AdhanScreenDhikr({
    required this.prayerName,
    required this.dhikrText,
    required this.count,
    required this.target,
  });

  @override
  List<Object?> get props => [prayerName, dhikrText, count, target];

  AdhanScreenDhikr copyWith({String? dhikrText, int? count, int? target}) {
    return AdhanScreenDhikr(
      prayerName: prayerName,
      dhikrText: dhikrText ?? this.dhikrText,
      count: count ?? this.count,
      target: target ?? this.target,
    );
  }
}

abstract class AdhanScreenEvent extends Equatable {
  const AdhanScreenEvent();

  @override
  List<Object?> get props => [];
}

class StartDhikr extends AdhanScreenEvent {}

class IncrementDhikr extends AdhanScreenEvent {}

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
  final AppDatabase _database;
  final AudioService _audioService = AudioService();
  Timer? _timer;

  AdhanScreenBloc({
    required AppDatabase database,
    required String prayerName,
    int iqamaDelayMinutes = 10,
  }) : _database = database,
       super(AdhanScreenInitial()) {
    on<PlayAdhan>(_onPlayAdhan);
    on<StopAdhan>(_onStopAdhan);
    on<TickIqama>(_onTickIqama);

    on<StartDhikr>(_onStartDhikr);
    on<IncrementDhikr>(_onIncrementDhikr);

    add(PlayAdhan(prayerName, iqamaDelayMinutes: iqamaDelayMinutes));
  }

  Future<void> _saveSession(
    String dhikr,
    int count,
    int target,
    bool isCompleted,
  ) async {
    if (count > 0) {
      await _database
          .into(_database.tasbihSessions)
          .insert(
            TasbihSessionsCompanion.insert(
              dhikrName: dhikr,
              count: count,
              targetCount: target,
              createdAt: DateTime.now(),
              completedAt: Value(isCompleted ? DateTime.now() : null),
            ),
          );
    }
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
    // Do not cancel timer if we want to keep iqama countdown running after stopping adhan sound
    if (state is AdhanScreenPlaying) {
      // Just keep playing state but sound stopped (handled by _audioService.stop())
    }
  }

  Future<void> _onStartDhikr(
    StartDhikr event,
    Emitter<AdhanScreenState> emit,
  ) async {
    String prayerName = '';
    if (state is AdhanScreenPlaying) {
      prayerName = (state as AdhanScreenPlaying).prayerName;
    } else if (state is AdhanScreenCompleted) {
      prayerName = (state as AdhanScreenCompleted).prayerName;
    }

    if (state is AdhanScreenDhikr) {
      final curr = state as AdhanScreenDhikr;
      await _saveSession(curr.dhikrText, curr.count, curr.target, false);
    }

    emit(
      AdhanScreenDhikr(
        prayerName: prayerName,
        dhikrText: 'سبحان الله',
        count: 0,
        target: 33,
      ),
    );
  }

  Future<void> _onIncrementDhikr(
    IncrementDhikr event,
    Emitter<AdhanScreenState> emit,
  ) async {
    if (state is AdhanScreenDhikr) {
      final curr = state as AdhanScreenDhikr;
      int nextCount = curr.count + 1;

      if (nextCount < curr.target) {
        emit(curr.copyWith(count: nextCount));
      } else {
        // Switch to next Dhikr
        if (curr.dhikrText == 'سبحان الله') {
          await _saveSession(curr.dhikrText, 33, 33, true);
          emit(curr.copyWith(dhikrText: 'الحمد لله', count: 0, target: 33));
        } else if (curr.dhikrText == 'الحمد لله') {
          await _saveSession(curr.dhikrText, 33, 33, true);
          emit(curr.copyWith(dhikrText: 'الله أكبر', count: 0, target: 33));
        } else {
          // Completed all basic dhikr
          await _saveSession(curr.dhikrText, 33, 33, true);
          emit(AdhanScreenCompleted(curr.prayerName));
        }
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioService.stop();
    return super.close();
  }
}
