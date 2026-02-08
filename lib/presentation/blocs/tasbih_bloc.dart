import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/tasbih_event.dart';
import 'package:ramadan_assistant/presentation/blocs/tasbih_state.dart';
import 'package:vibration/vibration.dart';

class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  TasbihBloc() : super(const TasbihState()) {
    on<IncrementCounter>(_onIncrementCounter);
    on<ResetCounter>(_onResetCounter);
    on<ChangeDhikr>(_onChangeDhikr);
  }

  void _onIncrementCounter(IncrementCounter event, Emitter<TasbihState> emit) {
    final newCount = state.count + 1;

    // Haptic feedback
    Vibration.vibrate(duration: 50);

    if (newCount == state.target) {
      Vibration.vibrate(
        pattern: [0, 100, 50, 100],
      ); // Special vibration on target reached
    }

    emit(state.copyWith(count: newCount));
  }

  void _onResetCounter(ResetCounter event, Emitter<TasbihState> emit) {
    emit(state.copyWith(count: 0));
  }

  void _onChangeDhikr(ChangeDhikr event, Emitter<TasbihState> emit) {
    emit(
      state.copyWith(currentDhikr: event.dhikr, target: event.target, count: 0),
    );
  }
}
