import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  static const List<String> defaultDhikrs = [
    'SubhanAllah',
    'Alhamdulillah',
    'Allahu Akbar',
    'La ilaha illallah',
    'Astaghfirullah',
  ];

  TasbihBloc()
    : super(
        const TasbihCounting(count: 0, target: 33, currentDhikr: 'SubhanAllah'),
      ) {
    on<IncrementCounter>(_onIncrementCounter);
    on<ResetCounter>(_onResetCounter);
    on<ChangeDhikr>(_onChangeDhikr);
    on<ChangeTarget>(_onChangeTarget);
  }

  void _onIncrementCounter(IncrementCounter event, Emitter<TasbihState> emit) {
    if (state is TasbihCounting) {
      final currentState = state as TasbihCounting;
      final newCount = currentState.count + 1;

      // Haptic feedback
      Vibration.vibrate(duration: 50);

      if (newCount >= currentState.target) {
        // Special vibration on target reached
        Vibration.vibrate(pattern: [0, 100, 50, 100]);

        emit(
          TasbihCompleted(
            count: newCount,
            target: currentState.target,
            currentDhikr: currentState.currentDhikr,
          ),
        );
      } else {
        emit(currentState.copyWith(count: newCount));
      }
    }
  }

  void _onResetCounter(ResetCounter event, Emitter<TasbihState> emit) {
    if (state is TasbihCounting) {
      final currentState = state as TasbihCounting;
      emit(currentState.copyWith(count: 0));
    } else if (state is TasbihCompleted) {
      emit(
        TasbihCounting(
          count: 0,
          target: state.target,
          currentDhikr: state.currentDhikr,
        ),
      );
    }
  }

  void _onChangeDhikr(ChangeDhikr event, Emitter<TasbihState> emit) {
    emit(
      TasbihCounting(
        count: 0,
        target: event.target,
        currentDhikr: event.newDhikr,
      ),
    );
  }

  void _onChangeTarget(ChangeTarget event, Emitter<TasbihState> emit) {
    if (state is TasbihCounting) {
      final currentState = state as TasbihCounting;
      emit(currentState.copyWith(target: event.newTarget));
    }
  }
}
