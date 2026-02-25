import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';

class UmrahGuideBloc extends Bloc<UmrahGuideEvent, UmrahGuideState> {
  final AppDatabase _database;

  UmrahGuideBloc(this._database) : super(UmrahGuideInitial()) {
    on<LoadUmrahProgress>(_onLoadUmrahProgress);
    on<CompleteUmrahStep>(_onCompleteUmrahStep);
    on<ResetUmrahProgress>(_onResetUmrahProgress);
    on<UpdateTawafCircuits>(_onUpdateTawafCircuits);
    on<UpdateSaiLaps>(_onUpdateSaiLaps);
    on<UpdateMaqamToggle>(_onUpdateMaqamToggle);
    on<UpdateZamzamToggle>(_onUpdateZamzamToggle);
    on<UpdateAutoTracking>(_onUpdateAutoTracking);
  }

  Future<void> _onLoadUmrahProgress(
    LoadUmrahProgress event,
    Emitter<UmrahGuideState> emit,
  ) async {
    emit(UmrahGuideLoading());
    try {
      final query = _database.select(_database.umrahProgress)
        ..orderBy([(t) => OrderingTerm.asc(t.id)]);

      var progress = await query.get();

      // Migration: Update existing Arabic step names to English IDs
      final migrationMap = {
        'الإحرام': 'step_ihram',
        'دخول المسجد الحرام': 'step_entrance',
        'الطواف': 'step_tawaf',
        'السعي': 'step_sai',
        'التقصير أو الحلق والتحلل': 'step_tahlul',
      };

      bool needsReload = false;
      for (final item in progress) {
        if (migrationMap.containsKey(item.step)) {
          await (_database.update(
            _database.umrahProgress,
          )..where((t) => t.id.equals(item.id))).write(
            UmrahProgressCompanion(step: Value(migrationMap[item.step]!)),
          );
          needsReload = true;
        }
      }

      if (needsReload) {
        progress = await query.get();
      }

      if (progress.isEmpty) {
        final steps = [
          'step_ihram',
          'step_entrance',
          'step_tawaf',
          'step_sai',
          'step_tahlul',
        ];

        await _database.transaction(() async {
          // Re-check inside transaction to prevent race conditions
          final check = await _database.select(_database.umrahProgress).get();
          if (check.isEmpty) {
            for (final step in steps) {
              await _database
                  .into(_database.umrahProgress)
                  .insert(
                    UmrahProgressCompanion.insert(
                      step: step,
                      completed: const Value(false),
                    ),
                  );
            }
          }
        });

        progress = await query.get();
      }

      emit(UmrahGuideLoaded(progress: progress));
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  Future<void> _onCompleteUmrahStep(
    CompleteUmrahStep event,
    Emitter<UmrahGuideState> emit,
  ) async {
    try {
      await (_database.update(
        _database.umrahProgress,
      )..where((t) => t.id.equals(event.id))).write(
        UmrahProgressCompanion(
          completed: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );
      add(LoadUmrahProgress());
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  Future<void> _onResetUmrahProgress(
    ResetUmrahProgress event,
    Emitter<UmrahGuideState> emit,
  ) async {
    try {
      await _database.delete(_database.umrahProgress).go();
      add(LoadUmrahProgress());
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  Future<void> _onUpdateTawafCircuits(
    UpdateTawafCircuits event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      emit(currentState.copyWith(tawafCircuits: event.circuits));
    }
  }

  Future<void> _onUpdateSaiLaps(
    UpdateSaiLaps event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      emit(currentState.copyWith(saiLaps: event.laps));
    }
  }

  Future<void> _onUpdateMaqamToggle(
    UpdateMaqamToggle event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      emit(currentState.copyWith(isPrayedAtMaqam: event.isPrayed));
    }
  }

  Future<void> _onUpdateZamzamToggle(
    UpdateZamzamToggle event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      emit(currentState.copyWith(isDrunkZamzam: event.isDrunk));
    }
  }

  Future<void> _onUpdateAutoTracking(
    UpdateAutoTracking event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      emit(currentState.copyWith(isAutoTracking: event.enabled));
    }
  }
}
