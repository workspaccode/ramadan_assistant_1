import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:vibration/vibration.dart';

abstract class TasbihState extends Equatable {
  final int count;
  final int target;
  final String currentDhikr;

  const TasbihState({
    required this.count,
    required this.target,
    required this.currentDhikr,
  });

  @override
  List<Object?> get props => [count, target, currentDhikr];
}

class TasbihCounting extends TasbihState {
  const TasbihCounting({
    required super.count,
    required super.target,
    required super.currentDhikr,
  });

  TasbihCounting copyWith({int? count, int? target, String? currentDhikr}) {
    return TasbihCounting(
      count: count ?? this.count,
      target: target ?? this.target,
      currentDhikr: currentDhikr ?? this.currentDhikr,
    );
  }
}

class TasbihCompleted extends TasbihState {
  const TasbihCompleted({
    required super.count,
    required super.target,
    required super.currentDhikr,
  });
}

class TasbihSaveFailed extends TasbihState {
  final bool isCompleted;

  const TasbihSaveFailed({
    required super.count,
    required super.target,
    required super.currentDhikr,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [...super.props, isCompleted];
}

abstract class TasbihEvent extends Equatable {
  const TasbihEvent();

  @override
  List<Object?> get props => [];
}

class IncrementCounter extends TasbihEvent {}

class ResetCounter extends TasbihEvent {}

class RetryTasbihSave extends TasbihEvent {}

class ChangeDhikr extends TasbihEvent {
  final String newDhikr;
  final int target;

  const ChangeDhikr(this.newDhikr, this.target);

  @override
  List<Object?> get props => [newDhikr, target];
}

class ChangeTarget extends TasbihEvent {
  final int newTarget;

  const ChangeTarget(this.newTarget);

  @override
  List<Object?> get props => [newTarget];
}

class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final AppDatabase _database;
  int? _sessionRowId;
  DateTime _sessionStartedAt = DateTime.now();

  static const List<String> defaultDhikrs = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
  ];

  TasbihBloc(this._database)
    : super(
        const TasbihCounting(count: 0, target: 33, currentDhikr: 'SubhanAllah'),
      ) {
    // Serialize actions so fast taps cannot create duplicate saved sessions.
    on<TasbihEvent>((event, emit) async {
      switch (event) {
        case IncrementCounter():
          await _onIncrementCounter(event, emit);
        case ResetCounter():
          await _onResetCounter(event, emit);
        case ChangeDhikr():
          await _onChangeDhikr(event, emit);
        case ChangeTarget():
          _onChangeTarget(event, emit);
        case RetryTasbihSave():
          if (await _trySaveSession(emit)) {
            emit(
              state.count >= state.target
                  ? TasbihCompleted(
                      count: state.count,
                      target: state.target,
                      currentDhikr: state.currentDhikr,
                    )
                  : TasbihCounting(
                      count: state.count,
                      target: state.target,
                      currentDhikr: state.currentDhikr,
                    ),
            );
          }
      }
    }, transformer: (events, mapper) => events.asyncExpand(mapper));
  }

  Future<void> _saveSession() async {
    if (state.count > 0) {
      final entry = TasbihSessionsCompanion.insert(
        dhikrName: state.currentDhikr,
        count: state.count,
        targetCount: state.target,
        createdAt: _sessionStartedAt,
        completedAt: Value(state.count >= state.target ? DateTime.now() : null),
      );
      if (_sessionRowId == null) {
        _sessionRowId = await _database
            .into(_database.tasbihSessions)
            .insert(entry);
      } else {
        await (_database.update(
          _database.tasbihSessions,
        )..where((row) => row.id.equals(_sessionRowId!))).write(entry);
      }
    }
  }

  Future<bool> _trySaveSession(Emitter<TasbihState> emit) async {
    try {
      await _saveSession();
      return true;
    } catch (error, stackTrace) {
      debugPrint('Tasbih session save failed: $error\n$stackTrace');
      emit(
        TasbihSaveFailed(
          count: state.count,
          target: state.target,
          currentDhikr: state.currentDhikr,
          isCompleted: state.count >= state.target,
        ),
      );
      return false;
    }
  }

  Future<void> _onIncrementCounter(
    IncrementCounter event,
    Emitter<TasbihState> emit,
  ) async {
    final currentState = state;
    final newCount = currentState.count + 1;

    // Haptic feedback
    unawaited(_vibrate(newCount, currentState.target));

    if (newCount >= currentState.target) {
      emit(
        TasbihCompleted(
          count: newCount,
          target: currentState.target,
          currentDhikr: currentState.currentDhikr,
        ),
      );
      await _trySaveSession(emit);
    } else {
      if (currentState is TasbihSaveFailed) {
        emit(
          TasbihSaveFailed(
            count: newCount,
            target: currentState.target,
            currentDhikr: currentState.currentDhikr,
            isCompleted: false,
          ),
        );
      } else if (currentState is TasbihCounting) {
        emit(currentState.copyWith(count: newCount));
      } else {
        emit(
          TasbihCounting(
            count: newCount,
            target: currentState.target,
            currentDhikr: currentState.currentDhikr,
          ),
        );
      }
    }
  }

  Future<void> _vibrate(int count, int target) async {
    try {
      if (count % 33 == 0 || count == target) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      } else {
        await Vibration.vibrate(duration: 50);
      }
    } on PlatformException catch (error) {
      debugPrint('Tasbih haptic feedback unavailable: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Tasbih haptic feedback unavailable: $error');
    }
  }

  Future<void> _onResetCounter(
    ResetCounter event,
    Emitter<TasbihState> emit,
  ) async {
    if (!await _trySaveSession(emit)) return;
    _sessionRowId = null;
    _sessionStartedAt = DateTime.now();
    emit(
      TasbihCounting(
        count: 0,
        target: state.target,
        currentDhikr: state.currentDhikr,
      ),
    );
  }

  Future<void> _onChangeDhikr(
    ChangeDhikr event,
    Emitter<TasbihState> emit,
  ) async {
    if (event.target <= 0) return;
    if (!await _trySaveSession(emit)) return;
    _sessionRowId = null;
    _sessionStartedAt = DateTime.now();
    emit(
      TasbihCounting(
        count: 0,
        target: event.target,
        currentDhikr: event.newDhikr,
      ),
    );
  }

  void _onChangeTarget(ChangeTarget event, Emitter<TasbihState> emit) {
    if (event.newTarget <= 0) return;
    if (state is TasbihSaveFailed) {
      emit(
        TasbihSaveFailed(
          count: state.count,
          target: event.newTarget,
          currentDhikr: state.currentDhikr,
          isCompleted: state.count >= event.newTarget,
        ),
      );
      return;
    }
    emit(
      TasbihCounting(
        count: state.count,
        target: event.newTarget,
        currentDhikr: state.currentDhikr,
      ),
    );
  }
}
