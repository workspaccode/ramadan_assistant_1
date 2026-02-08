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
  }

  Future<void> _onLoadUmrahProgress(
    LoadUmrahProgress event,
    Emitter<UmrahGuideState> emit,
  ) async {
    emit(UmrahGuideLoading());
    try {
      final progress = await _database.select(_database.umrahProgress).get();

      if (progress.isEmpty) {
        final steps = [
          'الإحرام',
          'دخول المسجد الحرام',
          'الطواف',
          'السعي',
          'التقصير أو الحلق والتحلل',
        ];
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
        final freshProgress = await _database
            .select(_database.umrahProgress)
            .get();
        emit(UmrahGuideLoaded(freshProgress));
      } else {
        emit(UmrahGuideLoaded(progress));
      }
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
}
