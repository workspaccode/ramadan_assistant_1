import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
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

abstract class TasbihEvent extends Equatable {
  const TasbihEvent();

  @override
  List<Object?> get props => [];
}

class IncrementCounter extends TasbihEvent {}

class ResetCounter extends TasbihEvent {}

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
    on<IncrementCounter>(_onIncrementCounter);
    on<ResetCounter>(_onResetCounter);
    on<ChangeDhikr>(_onChangeDhikr);
    on<ChangeTarget>(_onChangeTarget);
  }

  Future<void> _saveSession() async {
    if (state.count > 0) {
      await _database
          .into(_database.tasbihSessions)
          .insert(
            TasbihSessionsCompanion.insert(
              dhikrName: state.currentDhikr,
              count: state.count,
              targetCount: state.target,
              createdAt: DateTime.now(),
              completedAt: Value(
                state is TasbihCompleted ? DateTime.now() : null,
              ),
            ),
          );
    }
  }

  Future<void> _onIncrementCounter(
    IncrementCounter event,
    Emitter<TasbihState> emit,
  ) async {
    final currentState = state;
    final newCount = currentState.count + 1;

    // Haptic feedback
    if (newCount % 33 == 0 || newCount == currentState.target) {
      Vibration.vibrate(pattern: [0, 100, 50, 100]);
    } else {
      Vibration.vibrate(duration: 50);
    }

    if (newCount >= currentState.target) {
      emit(
        TasbihCompleted(
          count: newCount,
          target: currentState.target,
          currentDhikr: currentState.currentDhikr,
        ),
      );
      await _saveSession();
    } else {
      if (currentState is TasbihCounting) {
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

  Future<void> _onResetCounter(
    ResetCounter event,
    Emitter<TasbihState> emit,
  ) async {
    await _saveSession();
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
    await _saveSession();
    emit(
      TasbihCounting(
        count: 0,
        target: event.target,
        currentDhikr: event.newDhikr,
      ),
    );
  }

  void _onChangeTarget(ChangeTarget event, Emitter<TasbihState> emit) {
    emit(
      TasbihCounting(
        count: state.count,
        target: event.newTarget,
        currentDhikr: state.currentDhikr,
      ),
    );
  }
}
