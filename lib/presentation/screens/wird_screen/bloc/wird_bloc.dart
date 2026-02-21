import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/data/models/wird_plan.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WirdBloc extends Bloc<WirdEvent, WirdState> {
  final AppDatabase _database;

  WirdBloc(this._database) : super(WirdInitial()) {
    on<LoadWirdProgress>(_onLoadProgress);
    on<SetWirdPlan>(_onSetPlan);
    on<UpdateWirdProgress>(_onUpdateProgress);
    on<UpdatePrayerProgress>(_onUpdatePrayerProgress);
    on<SetLastReadPage>(_onSetLastReadPage);
    on<ResetWirdProgress>(_onResetProgress);
    on<LoadWirdHistory>(_onLoadHistory);
    on<ChangeSelectedDate>(_onChangeSelectedDate);
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
        return;
      }

      // Fetch today's log
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyLog = await (_database.select(
        _database.wirdDailyLogs,
      )..where((t) => t.date.equals(today))).getSingleOrNull();

      final prayerPages = <String, int>{};
      if (dailyLog != null) {
        prayerPages['fajr'] = dailyLog.fajrPages;
        prayerPages['dhuhr'] = dailyLog.dhuhrPages;
        prayerPages['asr'] = dailyLog.asrPages;
        prayerPages['maghrib'] = dailyLog.maghribPages;
        prayerPages['isha'] = dailyLog.ishaPages;
        prayerPages['other'] = dailyLog.otherPages;
      }

      emit(
        WirdPlanActive(
          plan: WirdPlan(
            type: _parseType(progress.planType),
            value: progress.planValue,
          ),
          completedPages: progress.completedPages,
          lastReadPage: progress.lastReadPage,
          lastUpdated: progress.lastUpdated,
          todayPrayerPages: prayerPages,
          selectedDate: now,
          selectedDayPrayerPages: prayerPages,
        ),
      );
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  Future<void> _onSetPlan(SetWirdPlan event, Emitter<WirdState> emit) async {
    emit(WirdLoading());
    try {
      await _database.delete(_database.wirdProgress).go();
      await _database.delete(_database.wirdDailyLogs).go();
      await _database
          .into(_database.wirdProgress)
          .insert(
            WirdProgressCompanion.insert(
              planType: event.plan.type.name,
              planValue: event.plan.value,
              lastUpdated: DateTime.now(),
            ),
          );

      // Save plan to SharedPreferences for Background Task
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wird_plan_type', event.plan.type.name);
      await prefs.setInt('wird_plan_value', event.plan.value);

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

  Future<void> _onUpdatePrayerProgress(
    UpdatePrayerProgress event,
    Emitter<WirdState> emit,
  ) async {
    if (state is WirdPlanActive) {
      try {
        final now = DateTime.now();
        final targetDate = event.date ?? now;
        final normalizedDate = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );

        // Update or Insert Daily Log
        final dailyLog = await (_database.select(
          _database.wirdDailyLogs,
        )..where((t) => t.date.equals(normalizedDate))).getSingleOrNull();

        int delta = 0;

        if (dailyLog == null) {
          // New entry, delta is the full value
          delta = event.pagesRead;
          await _database
              .into(_database.wirdDailyLogs)
              .insert(
                WirdDailyLogsCompanion.insert(
                  date: normalizedDate,
                  fajrPages: Value(
                    event.prayerName == 'fajr' ? event.pagesRead : 0,
                  ),
                  dhuhrPages: Value(
                    event.prayerName == 'dhuhr' ? event.pagesRead : 0,
                  ),
                  asrPages: Value(
                    event.prayerName == 'asr' ? event.pagesRead : 0,
                  ),
                  maghribPages: Value(
                    event.prayerName == 'maghrib' ? event.pagesRead : 0,
                  ),
                  ishaPages: Value(
                    event.prayerName == 'isha' ? event.pagesRead : 0,
                  ),
                  otherPages: Value(
                    event.prayerName == 'other' ? event.pagesRead : 0,
                  ),
                ),
              );
        } else {
          // Existing entry, calculate delta and update with NEW absolute value
          int oldPages = 0;
          switch (event.prayerName) {
            case 'fajr':
              oldPages = dailyLog.fajrPages;
              break;
            case 'dhuhr':
              oldPages = dailyLog.dhuhrPages;
              break;
            case 'asr':
              oldPages = dailyLog.asrPages;
              break;
            case 'maghrib':
              oldPages = dailyLog.maghribPages;
              break;
            case 'isha':
              oldPages = dailyLog.ishaPages;
              break;
            default:
              oldPages = dailyLog.otherPages;
          }

          delta = event.pagesRead - oldPages;

          WirdDailyLogsCompanion companion;
          switch (event.prayerName) {
            case 'fajr':
              companion = WirdDailyLogsCompanion(
                fajrPages: Value(event.pagesRead),
              );
              break;
            case 'dhuhr':
              companion = WirdDailyLogsCompanion(
                dhuhrPages: Value(event.pagesRead),
              );
              break;
            case 'asr':
              companion = WirdDailyLogsCompanion(
                asrPages: Value(event.pagesRead),
              );
              break;
            case 'maghrib':
              companion = WirdDailyLogsCompanion(
                maghribPages: Value(event.pagesRead),
              );
              break;
            case 'isha':
              companion = WirdDailyLogsCompanion(
                ishaPages: Value(event.pagesRead),
              );
              break;
            default:
              companion = WirdDailyLogsCompanion(
                otherPages: Value(event.pagesRead),
              );
          }

          await (_database.update(
            _database.wirdDailyLogs,
          )..where((t) => t.id.equals(dailyLog.id))).write(companion);
        }

        // Update total progress with delta
        if (delta != 0) {
          add(UpdateWirdProgress(delta));
        } else {
          // Even if no delta to total, we reload to refresh UI with new daily breakdown if needed
          add(LoadWirdProgress());
        }
      } catch (e) {
        emit(WirdError(e.toString()));
      }
    }
  }

  Future<void> _onSetLastReadPage(
    SetLastReadPage event,
    Emitter<WirdState> emit,
  ) async {
    try {
      await _database
          .update(_database.wirdProgress)
          .write(
            WirdProgressCompanion(
              lastReadPage: Value(event.page),
              lastUpdated: Value(DateTime.now()),
            ),
          );
      add(LoadWirdProgress());
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  Future<void> _onResetProgress(
    ResetWirdProgress event,
    Emitter<WirdState> emit,
  ) async {
    try {
      await _database.delete(_database.wirdProgress).go();
      await _database.delete(_database.wirdDailyLogs).go();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wird_plan_type');
      await prefs.remove('wird_plan_value');

      emit(WirdNoPlan());
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadWirdHistory event,
    Emitter<WirdState> emit,
  ) async {
    // Preserve current plan data
    WirdPlanActive? currentPlanState;
    if (state is WirdPlanActive) {
      currentPlanState = state as WirdPlanActive;
    }

    // Do NOT emit WirdLoading() to avoid resetting TabController in UI

    try {
      final logs =
          await (_database.select(_database.wirdDailyLogs)..orderBy([
                (t) =>
                    OrderingTerm(expression: t.date, mode: OrderingMode.desc),
              ]))
              .get();

      int totalPages = 0;
      int streak = 0;
      DateTime? lastDate;

      final readingDays = <DateTime, int>{};

      for (var log in logs) {
        final totalDaily =
            log.fajrPages +
            log.dhuhrPages +
            log.asrPages +
            log.maghribPages +
            log.ishaPages +
            log.otherPages;

        if (totalDaily > 0) {
          totalPages += totalDaily;
          readingDays[log.date] = totalDaily;

          // Streak Logic (simplified)
          if (lastDate == null) {
            streak = 1;
            lastDate = log.date;
          } else {
            final difference = lastDate.difference(log.date).inDays;
            if (difference == 1) {
              streak++;
              lastDate = log.date;
            } else if (difference > 1) {
              // Streak broken
            }
          }
        }
      }

      double avg = logs.isNotEmpty ? totalPages / logs.length : 0;

      if (currentPlanState != null) {
        emit(
          WirdHistoryLoaded(
            plan: currentPlanState.plan,
            completedPages: currentPlanState.completedPages,
            lastReadPage: currentPlanState.lastReadPage,
            lastUpdated: currentPlanState.lastUpdated,
            todayPrayerPages: currentPlanState.todayPrayerPages,
            selectedDate: currentPlanState.selectedDate,
            selectedDayPrayerPages: currentPlanState.selectedDayPrayerPages,
            historyLogs: logs,
            currentStreak: streak,
            totalPagesRead: totalPages,
            averagePagesPerDay: avg,
            readingDays: readingDays,
          ),
        );
      } else {
        // Fallback: If we somehow don't have plan state, try to load it or just load progress again
        add(LoadWirdProgress());
      }
    } catch (e) {
      emit(WirdError(e.toString()));
    }
  }

  Future<void> _onChangeSelectedDate(
    ChangeSelectedDate event,
    Emitter<WirdState> emit,
  ) async {
    if (state is WirdPlanActive) {
      final curr = state as WirdPlanActive;
      try {
        final normalizedDate = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );

        final dailyLog = await (_database.select(
          _database.wirdDailyLogs,
        )..where((t) => t.date.equals(normalizedDate))).getSingleOrNull();

        final prayerPages = <String, int>{};
        if (dailyLog != null) {
          prayerPages['fajr'] = dailyLog.fajrPages;
          prayerPages['dhuhr'] = dailyLog.dhuhrPages;
          prayerPages['asr'] = dailyLog.asrPages;
          prayerPages['maghrib'] = dailyLog.maghribPages;
          prayerPages['isha'] = dailyLog.ishaPages;
          prayerPages['other'] = dailyLog.otherPages;
        }

        if (state is WirdHistoryLoaded) {
          final history = state as WirdHistoryLoaded;
          emit(
            WirdHistoryLoaded(
              plan: curr.plan,
              completedPages: curr.completedPages,
              lastReadPage: curr.lastReadPage,
              lastUpdated: curr.lastUpdated,
              todayPrayerPages: curr.todayPrayerPages,
              selectedDate: normalizedDate,
              selectedDayPrayerPages: prayerPages,
              historyLogs: history.historyLogs,
              currentStreak: history.currentStreak,
              totalPagesRead: history.totalPagesRead,
              averagePagesPerDay: history.averagePagesPerDay,
              readingDays: history.readingDays,
            ),
          );
        } else {
          emit(
            WirdPlanActive(
              plan: curr.plan,
              completedPages: curr.completedPages,
              lastReadPage: curr.lastReadPage,
              lastUpdated: curr.lastUpdated,
              todayPrayerPages: curr.todayPrayerPages,
              selectedDate: normalizedDate,
              selectedDayPrayerPages: prayerPages,
            ),
          );
        }
      } catch (e) {
        emit(WirdError(e.toString()));
      }
    }
  }

  WirdType _parseType(String type) {
    return WirdType.values.firstWhere((e) => e.name == type);
  }
}
