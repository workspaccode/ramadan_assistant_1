import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';

class UmrahGuideBloc extends Bloc<UmrahGuideEvent, UmrahGuideState> {
  final AppDatabase _database;
  final Future<bool> Function(String) _writeSnapshot;

  // SharedPreferences keys for trip counters. Tawaf/Sa'i progress must
  // survive an app restart mid-Umrah — losing it would force the pilgrim to
  // re-count circuits from zero.
  static const String _tawafCircuitsKey = 'umrah_tawaf_circuits';
  static const String _saiLapsKey = 'umrah_sai_laps';
  static const String _maqamPrayedKey = 'umrah_maqam_prayed';
  static const String _zamzamDrunkKey = 'umrah_zamzam_drunk';
  static const String _autoTrackingKey = 'umrah_auto_tracking';
  static const String _snapshotKey = 'umrah_counter_snapshot_v1';

  /// Clears persisted trip counters — called when starting a brand-new
  /// Umrah trip so the wizard doesn't restore stale progress.
  static Future<void> clearPersistedCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tawafCircuitsKey);
    await prefs.remove(_saiLapsKey);
    await prefs.remove(_maqamPrayedKey);
    await prefs.remove(_zamzamDrunkKey);
    await prefs.remove(_autoTrackingKey);
    await prefs.remove(_snapshotKey);
  }

  UmrahGuideBloc(
    this._database, {
    Future<bool> Function(String)? persistCounterSnapshot,
  }) : _writeSnapshot = persistCounterSnapshot ?? _defaultWriteSnapshot,
       super(UmrahGuideInitial()) {
    // All event types share one queue: reset/load must not race pending writes.
    on<UmrahGuideEvent>((event, emit) async {
      switch (event) {
        case LoadUmrahProgress():
          await _onLoadUmrahProgress(event, emit);
        case CompleteUmrahStep():
          await _onCompleteUmrahStep(event, emit);
        case ResetUmrahProgress():
          await _onResetUmrahProgress(event, emit);
        case UpdateTawafCircuits():
          await _onUpdateTawafCircuits(event, emit);
        case UpdateSaiLaps():
          await _onUpdateSaiLaps(event, emit);
        case UpdateMaqamToggle():
          await _onUpdateMaqamToggle(event, emit);
        case UpdateZamzamToggle():
          await _onUpdateZamzamToggle(event, emit);
        case UpdateAutoTracking():
          await _onUpdateAutoTracking(event, emit);
        case RetryUmrahCounterSave():
          if (state case final UmrahGuideLoaded current) {
            await _persist(current, emit);
          }
      }
    }, transformer: (events, mapper) => events.asyncExpand(mapper));
  }

  static Future<bool> _defaultWriteSnapshot(String encoded) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_snapshotKey, encoded);
  }

  Future<void> _onLoadUmrahProgress(
    LoadUmrahProgress event,
    Emitter<UmrahGuideState> emit,
  ) async {
    // Only show the full-screen spinner on the very first load — every step
    // / lap completion re-uses this loader and must not flash a spinner.
    if (state is! UmrahGuideLoaded) {
      emit(UmrahGuideLoading());
    }
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

      // Restore persisted trip counters (tawaf/sa'i/maqam/zamzam/auto-track)
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_snapshotKey);
      final snapshot = encoded == null
          ? <String, dynamic>{}
          : (jsonDecode(encoded) as Map).cast<String, dynamic>();
      emit(
        UmrahGuideLoaded(
          progress: progress,
          tawafCircuits:
              ((snapshot['tawaf'] as int?) ??
                      prefs.getInt(_tawafCircuitsKey) ??
                      0)
                  .clamp(0, 7),
          saiLaps: ((snapshot['sai'] as int?) ?? prefs.getInt(_saiLapsKey) ?? 0)
              .clamp(0, 7),
          isPrayedAtMaqam:
              (snapshot['maqam'] as bool?) ??
              prefs.getBool(_maqamPrayedKey) ??
              false,
          isDrunkZamzam:
              (snapshot['zamzam'] as bool?) ??
              prefs.getBool(_zamzamDrunkKey) ??
              false,
          isAutoTracking:
              (snapshot['tracking'] as bool?) ??
              prefs.getBool(_autoTrackingKey) ??
              false,
        ),
      );
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  Future<void> _onCompleteUmrahStep(
    CompleteUmrahStep event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final current = state;
    if (current is! UmrahGuideLoaded) return;
    final matching = current.progress.where((step) => step.id == event.id);
    if (matching.isEmpty || !current.canComplete(matching.first.step)) return;
    try {
      await (_database.update(
        _database.umrahProgress,
      )..where((t) => t.id.equals(event.id))).write(
        UmrahProgressCompanion(
          completed: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );
      await _onLoadUmrahProgress(LoadUmrahProgress(), emit);
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
      // Reset must also wipe the persisted counters, otherwise the wizard
      // would restore tawaf/sa'i progress right after resetting.
      await clearPersistedCounters();
      await _onLoadUmrahProgress(LoadUmrahProgress(), emit);
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  /// One snapshot prevents a restart between separate writes restoring mixed counters.
  Future<void> _persist(
    UmrahGuideLoaded updated,
    Emitter<UmrahGuideState> emit,
  ) async {
    emit(updated.copyWith(persistenceFailed: false));
    try {
      final saved = await _writeSnapshot(
        jsonEncode({
          'tawaf': updated.tawafCircuits,
          'sai': updated.saiLaps,
          'maqam': updated.isPrayedAtMaqam,
          'zamzam': updated.isDrunkZamzam,
          'tracking': updated.isAutoTracking,
        }),
      );
      if (!saved) throw StateError('Counter save rejected');
    } catch (_) {
      emit(updated.copyWith(persistenceFailed: true));
    }
  }

  Future<void> _onUpdateTawafCircuits(
    UpdateTawafCircuits event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      await _persist(
        currentState.copyWith(tawafCircuits: event.circuits.clamp(0, 7)),
        emit,
      );
    }
  }

  Future<void> _onUpdateSaiLaps(
    UpdateSaiLaps event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      await _persist(
        currentState.copyWith(saiLaps: event.laps.clamp(0, 7)),
        emit,
      );
    }
  }

  Future<void> _onUpdateMaqamToggle(
    UpdateMaqamToggle event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      await _persist(
        currentState.copyWith(isPrayedAtMaqam: event.isPrayed),
        emit,
      );
    }
  }

  Future<void> _onUpdateZamzamToggle(
    UpdateZamzamToggle event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      await _persist(currentState.copyWith(isDrunkZamzam: event.isDrunk), emit);
    }
  }

  Future<void> _onUpdateAutoTracking(
    UpdateAutoTracking event,
    Emitter<UmrahGuideState> emit,
  ) async {
    final currentState = state;
    if (currentState is UmrahGuideLoaded) {
      await _persist(
        currentState.copyWith(isAutoTracking: event.enabled),
        emit,
      );
    }
  }
}
