import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/worship_data.dart';
import '../domain/worship_models.dart';
import '../domain/worship_ports.dart';

class WorshipState {
  const WorshipState({
    this.snapshot,
    this.busy = false,
    this.errorKey,
    this.noticeKey,
    this.readerApps = const [],
  });
  final WorshipSnapshot? snapshot;
  final bool busy;
  final String? errorKey;
  final String? noticeKey;
  final List<QuranReaderApp> readerApps;
}

class WorshipCubit extends Cubit<WorshipState> {
  WorshipCubit(
    this.repository, {
    this.reminders,
    this.readers,
    DateTime? initialDate,
  }) : _selectedDay = initialDate == null ? null : worshipDay(initialDate),
       super(const WorshipState());
  final WorshipData repository;
  final WorshipReminderPort? reminders;
  final QuranReaderPort? readers;
  String? _selectedDay;
  bool get followsToday => _selectedDay == null;

  Future<void> load({String? day}) async {
    if (state.busy || isClosed) return;
    emit(
      WorshipState(
        snapshot: state.snapshot,
        busy: true,
        readerApps: state.readerApps,
      ),
    );
    try {
      final selectedDay = day ?? _selectedDay;
      if (selectedDay != null) validateWorshipDay(selectedDay);
      if (selectedDay != null &&
          selectedDay.compareTo(worshipDay(repository.clock())) > 0) {
        throw const WorshipValidationException('worship_future_day');
      }
      final snapshot = await repository.load(day: selectedDay);
      _selectedDay = selectedDay == worshipDay(repository.clock())
          ? null
          : selectedDay;
      List<QuranReaderApp> apps = state.readerApps;
      try {
        apps = await readers?.availableApps() ?? [];
      } catch (_) {
        apps = [];
      }
      if (!isClosed) {
        emit(
          WorshipState(snapshot: snapshot, readerApps: List.unmodifiable(apps)),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          WorshipState(
            snapshot: state.snapshot,
            errorKey: error is WorshipValidationException
                ? error.code
                : 'worship_load_failed',
            readerApps: state.readerApps,
          ),
        );
      }
    }
  }

  Future<bool> _change(
    Future<void> Function() action, {
    String? notice,
    bool reload = true,
  }) async {
    if (state.busy || isClosed) return false;
    final previous = state.snapshot;
    final apps = state.readerApps;
    emit(WorshipState(snapshot: previous, busy: true, readerApps: apps));
    var committed = false;
    try {
      await action();
      committed = true;
      final snapshot = reload
          ? await repository.load(day: _selectedDay)
          : previous;
      if (!isClosed) {
        emit(
          WorshipState(
            snapshot: snapshot,
            readerApps: apps,
            noticeKey: state.noticeKey ?? notice,
          ),
        );
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          WorshipState(
            snapshot: previous,
            readerApps: apps,
            errorKey: committed
                ? 'worship_refresh_failed'
                : error is WorshipValidationException
                ? error.code
                : 'worship_save_failed',
          ),
        );
      }
      // A saved action must not be retried as a second payment or voluntary log.
      return committed;
    }
  }

  Future<bool> savePlan(
    WirdPlan plan, {
    required String reminderTitle,
    required String reminderBody,
  }) async {
    return _change(() async {
      await repository.savePlan(plan);
      try {
        if (plan.reminderMinute == null) {
          await reminders?.cancelDailyWird();
        } else {
          if (reminders == null ||
              !await reminders!.scheduleDailyWird(
                minuteOfDay: plan.reminderMinute!,
                title: reminderTitle,
                body: reminderBody,
              )) {
            throw const WorshipValidationException('worship_reminder_failed');
          }
        }
      } catch (_) {
        // The plan is durable even if the device denies notifications.
        if (!isClosed) {
          emit(
            WorshipState(
              snapshot: state.snapshot,
              busy: true,
              readerApps: state.readerApps,
              noticeKey: 'worship_reminder_failed',
            ),
          );
        }
      }
    }, notice: 'worship_saved');
  }

  Future<bool> completeWird() => _change(() async {
    await repository.completeWird(day: state.snapshot?.day);
  }, notice: 'worship_completed');
  Future<bool> recordPrayer(ObligatoryPrayer prayer, PrayerStatus status) =>
      _change(
        () => repository.recordPrayer(prayer, status, day: state.snapshot?.day),
      );
  Future<bool> addVoluntary(
    VoluntaryWorship kind,
    int units, {
    String note = '',
  }) => _change(
    () => repository.addVoluntary(
      kind,
      units,
      note: note,
      day: state.snapshot?.day,
    ),
    notice: 'worship_saved',
  );
  Future<bool> initializeLedger(Map<ObligatoryPrayer, int> opening) => _change(
    () => repository.initializeLedger(opening),
    notice: 'worship_saved',
  );
  Future<bool> payQada(
    ObligatoryPrayer prayer,
    int count, {
    String note = '',
  }) => _change(
    () => repository.payQada(prayer, count, note: note),
    notice: 'worship_saved',
  );
  Future<bool> adjustLedger(
    ObligatoryPrayer prayer,
    int delta, {
    required String note,
  }) => _change(
    () => repository.adjustLedger(prayer, delta, note: note),
    notice: 'worship_saved',
  );

  Future<bool> openReader() async {
    final snapshot = state.snapshot;
    final plan = snapshot?.plan;
    if (state.busy || plan == null || isClosed) return false;
    return _change(() async {
      final app = plan.readerAppId;
      final page = snapshot!.completion?.startPage ?? plan.nextPage;
      if (readers == null ||
          app == null ||
          !await readers!.open(appId: app, page: page)) {
        throw const WorshipValidationException('worship_reader_unavailable');
      }
    }, reload: false);
  }
}
