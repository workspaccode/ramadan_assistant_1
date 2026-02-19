import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/data/models/wird_plan.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';

class WirdBloc extends Bloc<WirdEvent, WirdState> {
  final AppDatabase _database;

  WirdBloc(this._database) : super(WirdInitial()) {
    on<LoadWirdProgress>(_onLoadProgress);
    on<SetWirdPlan>(_onSetPlan);
    on<UpdateWirdProgress>(_onUpdateProgress);
    on<ResetWirdProgress>(_onResetProgress);
  }

  Future<void> _onLoadProgress(
    LoadWirdProgress event,
    Emitter<WirdState> emit,
  ) async {
    emit(WirdLoading());
    try {
      final progress = await (_database.select(
        _database.wirdProgress,
      )..limit(1)).getSingleOrNull();
      if (progress == null) {
        emit(WirdNoPlan());
      } else {
        emit(
          WirdPlanActive(
            plan: WirdPlan(
              type: _parseType(progress.planType),
              value: progress.planValue,
            ),
            completedPages: progress.completedPages,
            lastUpdated: progress.lastUpdated,
          ),
        );
      }
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  Future<void> _onSetPlan(SetWirdPlan event, Emitter<WirdState> emit) async {
    emit(WirdLoading());
    try {
      await _database.delete(_database.wirdProgress).go();
      await _database
          .into(_database.wirdProgress)
          .insert(
            WirdProgressCompanion.insert(
              planType: event.plan.type.name,
              planValue: event.plan.value,
              lastUpdated: DateTime.now(),
            ),
          );
      add(LoadWirdProgress());
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  Future<void> _onUpdateProgress(
    UpdateWirdProgress event,
    Emitter<WirdState> emit,
  ) async {
    if (state is WirdPlanActive) {
      final curr = state as WirdPlanActive;
      try {
        final newPages = curr.completedPages + event.pagesRead;
        await _database
            .update(_database.wirdProgress)
            .write(
              WirdProgressCompanion(
                completedPages: Value(newPages),
                lastUpdated: Value(DateTime.now()),
                isCompleted: Value(newPages >= curr.plan.totalTargetPages),
              ),
            );
        add(LoadWirdProgress());
      } catch (e) {
        emit(WirdError(e.toString()));
      }
    }
  }

  Future<void> _onResetProgress(
    ResetWirdProgress event,
    Emitter<WirdState> emit,
  ) async {
    try {
      await _database.delete(_database.wirdProgress).go();
      emit(WirdNoPlan());
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  WirdType _parseType(String type) {
    return WirdType.values.firstWhere((e) => e.name == type);
  }
}
