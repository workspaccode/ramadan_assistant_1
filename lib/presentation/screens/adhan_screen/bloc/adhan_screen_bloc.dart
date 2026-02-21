import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

// ── States ──────────────────────────────────────────────────────────────────

abstract class AdhanScreenState extends Equatable {
  const AdhanScreenState();

  @override
  List<Object?> get props => [];
}

class AdhanScreenInitial extends AdhanScreenState {}

class AdhanScreenActive extends AdhanScreenState {
  final String prayerName;
  final int elapsedSeconds;

  const AdhanScreenActive({required this.prayerName, this.elapsedSeconds = 0});

  @override
  List<Object?> get props => [prayerName, elapsedSeconds];

  AdhanScreenActive copyWith({int? elapsedSeconds}) {
    return AdhanScreenActive(
      prayerName: prayerName,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class AdhanScreenDhikr extends AdhanScreenState {
  final String prayerName;
  final String dhikrText;
  final int count;
  final int target;
  final int dhikrIndex; // 0=سبحان الله, 1=الحمد لله, 2=الله أكبر

  const AdhanScreenDhikr({
    required this.prayerName,
    required this.dhikrText,
    required this.count,
    required this.target,
    this.dhikrIndex = 0,
  });

  @override
  List<Object?> get props => [prayerName, dhikrText, count, target, dhikrIndex];

  AdhanScreenDhikr copyWith({
    String? dhikrText,
    int? count,
    int? target,
    int? dhikrIndex,
  }) {
    return AdhanScreenDhikr(
      prayerName: prayerName,
      dhikrText: dhikrText ?? this.dhikrText,
      count: count ?? this.count,
      target: target ?? this.target,
      dhikrIndex: dhikrIndex ?? this.dhikrIndex,
    );
  }
}

class AdhanScreenDhikrCompleted extends AdhanScreenState {
  final String prayerName;

  const AdhanScreenDhikrCompleted(this.prayerName);

  @override
  List<Object?> get props => [prayerName];
}

// ── Events ──────────────────────────────────────────────────────────────────

abstract class AdhanScreenEvent extends Equatable {
  const AdhanScreenEvent();

  @override
  List<Object?> get props => [];
}

class StartAdhanScreen extends AdhanScreenEvent {
  final String prayerName;
  const StartAdhanScreen(this.prayerName);

  @override
  List<Object?> get props => [prayerName];
}

class TickElapsed extends AdhanScreenEvent {}

class StartDhikr extends AdhanScreenEvent {}

class IncrementDhikr extends AdhanScreenEvent {}

class DismissScreen extends AdhanScreenEvent {}

// ── BLoC ────────────────────────────────────────────────────────────────────

class AdhanScreenBloc extends Bloc<AdhanScreenEvent, AdhanScreenState> {
  final AppDatabase _database;
  final AudioService _audioService = AudioService();
  Timer? _timer;

  AdhanScreenBloc({required AppDatabase database, required String prayerName})
    : _database = database,
      super(AdhanScreenInitial()) {
    on<StartAdhanScreen>(_onStart);
    on<TickElapsed>(_onTick);
    on<StartDhikr>(_onStartDhikr);
    on<IncrementDhikr>(_onIncrementDhikr);
    on<DismissScreen>(_onDismiss);

    // Auto-start
    add(StartAdhanScreen(prayerName));
  }

  void _onStart(StartAdhanScreen event, Emitter<AdhanScreenState> emit) {
    emit(AdhanScreenActive(prayerName: event.prayerName));

    // Simple elapsed timer for visual effect (optional pulsing etc)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TickElapsed());
    });
  }

  void _onTick(TickElapsed event, Emitter<AdhanScreenState> emit) {
    if (state is AdhanScreenActive) {
      final s = state as AdhanScreenActive;
      emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
    }
  }

  void _onDismiss(DismissScreen event, Emitter<AdhanScreenState> emit) {
    _timer?.cancel();
  }

  Future<void> _onStartDhikr(
    StartDhikr event,
    Emitter<AdhanScreenState> emit,
  ) async {
    _timer?.cancel();

    String prayerName = '';
    if (state is AdhanScreenActive) {
      prayerName = (state as AdhanScreenActive).prayerName;
    } else if (state is AdhanScreenDhikr) {
      // Already in dhikr — save current then advance
      final curr = state as AdhanScreenDhikr;
      prayerName = curr.prayerName;
      await _saveSession(curr.dhikrText, curr.count, curr.target, false);
    } else if (state is AdhanScreenDhikrCompleted) {
      return; // Already done
    }

    emit(
      AdhanScreenDhikr(
        prayerName: prayerName,
        dhikrText: 'سبحان الله',
        count: 0,
        target: 33,
        dhikrIndex: 0,
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
        // Play click sound on each tap
        unawaited(_audioService.playTasbihClick());
      } else {
        // Complete current dhikr
        unawaited(_audioService.playTasbihComplete());
        await _saveSession(curr.dhikrText, curr.target, curr.target, true);

        if (curr.dhikrIndex == 0) {
          // سبحان الله done → الحمد لله
          emit(
            curr.copyWith(
              dhikrText: 'الحمد لله',
              count: 0,
              target: 33,
              dhikrIndex: 1,
            ),
          );
        } else if (curr.dhikrIndex == 1) {
          // الحمد لله done → الله أكبر
          emit(
            curr.copyWith(
              dhikrText: 'الله أكبر',
              count: 0,
              target: 34,
              dhikrIndex: 2,
            ),
          );
        } else {
          // All completed
          emit(AdhanScreenDhikrCompleted(curr.prayerName));
        }
      }
    }
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

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
