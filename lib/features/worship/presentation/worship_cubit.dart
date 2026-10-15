import 'dart:async';
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
    this.overlays,
    DateTime? initialDate,
  }) : _selectedDay = initialDate == null ? null : worshipDay(initialDate),
       super(const WorshipState());
  final WorshipData repository;
  final WorshipReminderPort? reminders;
  final QuranReaderPort? readers;
  final ReaderOverlayPort? overlays;
  final _confirm = StreamController<void>.broadcast();

  /// Fires when the floating helper's Done button asked the user to confirm today's wird.
  Stream<void> get confirmRequests => _confirm.stream;
  String? _selectedDay;
  bool get followsToday => _selectedDay == null;

  Future<void> _checkPendingDone() async {
    try {
      if (!isClosed && await overlays?.takePendingDone() == true) {
        _confirm.add(null);
      }
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _confirm.close();
    return super.close();
  }

  Future<OverlayStatus> overlayStatus() async {
    try {
      return await overlays?.status() ?? const OverlayStatus();
    } catch (_) {
      return const OverlayStatus();
    }
  }

  Future<void> openOverlaySettings() async {
    try {
      await overlays?.openOverlaySettings();
    } catch (_) {}
  }

  Future<void> openUsageSettings() async {
    try {
      await overlays?.openUsageSettings();
    } catch (_) {}
  }

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
      // After the snapshot exists, so the screen can build the confirmation.
      unawaited(_checkPendingDone());
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

  Future<bool> completeWird() async {
    final saved = await _change(() async {
      await repository.completeWird(day: state.snapshot?.day);
    }, notice: 'worship_completed');
    if (saved) {
      try {
        await overlays?.hide();
      } catch (_) {}
    }
    return saved;
  }

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

  /// Opens the chosen reader. When the user enabled the helper and permission is
  /// granted, a floating bubble is shown first; otherwise the reader opens exactly
  /// as before (with a notice). Opening never records reading.
  Future<bool> openReader({ReaderOverlayCopy? overlayCopy}) async {
    final snapshot = state.snapshot;
    final plan = snapshot?.plan;
    if (state.busy || plan == null || isClosed) return false;
    String? notice;
    var overlayShown = false;
    final appId = plan.readerAppId;
    if (plan.overlayEnabled &&
        overlays != null &&
        overlayCopy != null &&
        appId != null) {
      try {
        final status = await overlays!.status();
        if (status.canDraw) {
          overlayShown = await overlays!.show(
            ReaderOverlayRequest(
              packageName: appId,
              title: overlayCopy.title,
              body: overlayCopy.body,
              doneLabel: overlayCopy.doneLabel,
              closeLabel: overlayCopy.closeLabel,
              autoHide: plan.overlayAutoHide && status.usageAccess,
            ),
          );
        }
      } catch (_) {
        overlayShown = false;
      }
      if (!overlayShown) notice = 'worship_overlay_unavailable';
    }
    final opened = await _change(
      () async {
        final app = plan.readerAppId;
        final page = snapshot!.completion?.startPage ?? plan.nextPage;
        if (readers == null ||
            app == null ||
            !await readers!.open(appId: app, page: page)) {
          throw const WorshipValidationException('worship_reader_unavailable');
        }
      },
      reload: false,
      notice: notice,
    );
    if (!opened && overlayShown) {
      try {
        await overlays!.hide();
      } catch (_) {}
    }
    return opened;
  }
}
