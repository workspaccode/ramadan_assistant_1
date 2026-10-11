import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import '../domain/planner_event.dart';
import '../domain/planner_ports.dart';

enum PlannerIssue {
  load,
  save,
  delete,
  reminderPermission,
  reminderExpired,
  reminderSchedule,
  calendarPermission,
  calendarUnavailable,
  calendarOperation,
  calendarReadOnly,
  link,
  title,
  dates,
  meetingLink,
}

enum PlannerNotice { saved, deleted, calendarSaved }

class PlannerState {
  const PlannerState({
    this.events = const [],
    this.loading = true,
    this.busy = false,
    this.issue,
    this.notice,
    this.reminderRetryId,
    this.calendars = const [],
    this.deviceEvents = const [],
    this.selectedCalendar,
    this.calendarConnected = false,
  });
  final List<PlannerEvent> events;
  final bool loading;
  final bool busy;
  final PlannerIssue? issue;
  final PlannerNotice? notice;
  final String? reminderRetryId;
  final List<DeviceCalendar> calendars;
  final List<DeviceCalendarEvent> deviceEvents;
  final DeviceCalendar? selectedCalendar;
  final bool calendarConnected;

  PlannerState copyWith({
    List<PlannerEvent>? events,
    bool? loading,
    bool? busy,
    PlannerIssue? issue,
    PlannerNotice? notice,
    String? reminderRetryId,
    List<DeviceCalendar>? calendars,
    List<DeviceCalendarEvent>? deviceEvents,
    DeviceCalendar? selectedCalendar,
    bool? calendarConnected,
    bool clearMessage = false,
  }) => PlannerState(
    events: events ?? this.events,
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    issue: clearMessage ? null : issue ?? this.issue,
    notice: clearMessage ? null : notice ?? this.notice,
    reminderRetryId: clearMessage
        ? null
        : reminderRetryId ?? this.reminderRetryId,
    calendars: calendars ?? this.calendars,
    deviceEvents: deviceEvents ?? this.deviceEvents,
    selectedCalendar: selectedCalendar ?? this.selectedCalendar,
    calendarConnected: calendarConnected ?? this.calendarConnected,
  );
}

class PlannerCubit extends Cubit<PlannerState> {
  PlannerCubit({
    required this.repository,
    required this.reminders,
    required this.calendar,
    required this.links,
    AppClock? clock,
    RecordIdGenerator? idGenerator,
  }) : clock = clock ?? DateTime.now,
       idGenerator = idGenerator ?? newRecordId,
       super(const PlannerState());
  final PlannerRepository repository;
  final PlannerReminderPort reminders;
  final DeviceCalendarPort calendar;
  final MeetingLinkPort links;
  final AppClock clock;
  final RecordIdGenerator idGenerator;
  StreamSubscription<List<PlannerEvent>>? _subscription;
  final Map<String, PlannerEvent> _pendingReminders = {};
  final Map<String, PlannerEvent> _pendingCalendarLinks = {};

  void _emit(PlannerState value) {
    if (!isClosed) emit(value);
  }

  Future<void> load() async {
    _emit(state.copyWith(loading: true, clearMessage: true));
    try {
      final events = await repository.list();
      _emit(state.copyWith(events: events, loading: false));
      if (!isClosed && _subscription == null) {
        _subscription = repository.watch().listen(
          (events) {
            _emit(state.copyWith(events: events, loading: false));
          },
          onError: (Object error) {
            _emit(state.copyWith(loading: false, issue: PlannerIssue.load));
          },
        );
      }
    } catch (_) {
      _emit(state.copyWith(loading: false, issue: PlannerIssue.load));
    }
  }

  PlannerIssue _issue(Object error) => switch (error) {
    PlannerValidationException(:final issue) => switch (issue) {
      PlannerValidation.title => PlannerIssue.title,
      PlannerValidation.dates => PlannerIssue.dates,
      PlannerValidation.meetingLink => PlannerIssue.meetingLink,
      PlannerValidation.reminder => PlannerIssue.reminderSchedule,
    },
    ReminderException(:final problem) => switch (problem) {
      ReminderProblem.permission => PlannerIssue.reminderPermission,
      ReminderProblem.expired => PlannerIssue.reminderExpired,
      ReminderProblem.scheduling => PlannerIssue.reminderSchedule,
    },
    CalendarException(:final problem) => switch (problem) {
      CalendarProblem.permission => PlannerIssue.calendarPermission,
      CalendarProblem.unavailable => PlannerIssue.calendarUnavailable,
      CalendarProblem.readOnly => PlannerIssue.calendarReadOnly,
      CalendarProblem.operation => PlannerIssue.calendarOperation,
    },
    _ => PlannerIssue.save,
  };

  /// Persist first. A scheduler failure must never erase the appointment/form.
  Future<bool> save(PlannerEvent event) async {
    if (state.busy || isClosed) return false;
    _emit(state.copyWith(busy: true, clearMessage: true));
    PlannerEvent saved;
    try {
      saved = await repository.save(event);
      await _refresh();
    } catch (error) {
      _emit(state.copyWith(busy: false, issue: _issue(error)));
      return false;
    }
    try {
      await _scheduleReminder(saved);
      _pendingReminders.remove(saved.id);
      _emit(state.copyWith(busy: false, notice: PlannerNotice.saved));
    } catch (error) {
      _pendingReminders[saved.id] = saved;
      _emit(
        state.copyWith(
          busy: false,
          issue: error is ReminderException
              ? _issue(error)
              : PlannerIssue.reminderSchedule,
          reminderRetryId: saved.id,
        ),
      );
    }
    return true;
  }

  Future<void> _refresh() async {
    final events = await repository.list();
    _emit(state.copyWith(events: events, loading: false));
  }

  Future<void> _scheduleReminder(PlannerEvent event) async {
    // Replace rather than accumulate schedules. Do not prompt for permission
    // when the requested reminder is already impossible to deliver.
    await reminders.cancel(event.notificationId);
    if (event.reminderAt != null &&
        !event.reminderAt!.isAfter(clock().toUtc())) {
      throw const ReminderException(ReminderProblem.expired);
    }
    if (event.reminderMinutes != null) await reminders.requestPermission();
    await reminders.schedule(event);
  }

  Future<void> retryReminder(String id) async {
    if (state.busy || isClosed) return;
    final matches = state.events.where((event) => event.id == id);
    final event =
        _pendingReminders[id] ?? (matches.isEmpty ? null : matches.first);
    if (event == null) return;
    _emit(state.copyWith(busy: true, clearMessage: true));
    try {
      await _scheduleReminder(event);
      _pendingReminders.remove(id);
      _emit(state.copyWith(busy: false, notice: PlannerNotice.saved));
    } catch (error) {
      _emit(
        state.copyWith(
          busy: false,
          issue: error is ReminderException
              ? _issue(error)
              : PlannerIssue.reminderSchedule,
          reminderRetryId: id,
        ),
      );
    }
  }

  Future<bool> delete(PlannerEvent event) async {
    if (state.busy || isClosed) return false;
    _emit(state.copyWith(busy: true, clearMessage: true));
    try {
      // Cancel first; failure leaves the record present with a retry path.
      await reminders.cancel(event.notificationId);
      await repository.delete(event.id);
      _pendingReminders.remove(event.id);
      await _refresh();
      _emit(state.copyWith(busy: false, notice: PlannerNotice.deleted));
      return true;
    } catch (_) {
      _emit(state.copyWith(busy: false, issue: PlannerIssue.delete));
      return false;
    }
  }

  Future<void> connectCalendar() async {
    if (state.busy || isClosed) return;
    _emit(state.copyWith(busy: true, clearMessage: true));
    try {
      final calendars = await calendar.connect();
      _emit(
        state.copyWith(
          busy: false,
          calendars: calendars,
          calendarConnected: true,
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          busy: false,
          issue: error is CalendarException
              ? _issue(error)
              : PlannerIssue.calendarOperation,
        ),
      );
    }
  }

  Future<void> selectCalendar(DeviceCalendar selected, DateTime month) async {
    if (state.busy || isClosed) return;
    _emit(
      state.copyWith(
        busy: true,
        clearMessage: true,
        selectedCalendar: selected,
        deviceEvents: [],
      ),
    );
    try {
      final from = DateTime(month.year, month.month).toUtc();
      final to = DateTime(month.year, month.month + 1).toUtc();
      final events = await calendar.events(selected.id, from, to);
      _emit(state.copyWith(busy: false, deviceEvents: events));
    } catch (error) {
      _emit(
        state.copyWith(
          busy: false,
          issue: error is CalendarException
              ? _issue(error)
              : PlannerIssue.calendarOperation,
        ),
      );
    }
  }

  Future<void> exportEvent(PlannerEvent event, DeviceCalendar selected) async {
    if (state.busy || isClosed) return;
    if (!selected.writable) {
      _emit(state.copyWith(issue: PlannerIssue.calendarReadOnly));
      return;
    }
    _emit(state.copyWith(busy: true, clearMessage: true));
    try {
      var linked = _pendingCalendarLinks[event.id] ?? event;
      if (linked.deviceEventId != null &&
          linked.deviceCalendarId == selected.id) {
        await calendar.update(linked.deviceEventId!, selected.id, linked);
      } else {
        final nativeId = await calendar.create(selected.id, event);
        linked = event.withDeviceLink(selected.id, nativeId);
      }
      // Retain successful native IDs if local storage temporarily fails so
      // retrying export in this session updates rather than duplicates it.
      _pendingCalendarLinks[event.id] = linked;
      await repository.save(linked);
      _pendingCalendarLinks.remove(event.id);
      await _refresh();
      _emit(state.copyWith(busy: false, notice: PlannerNotice.calendarSaved));
    } catch (error) {
      _emit(
        state.copyWith(
          busy: false,
          issue: error is CalendarException
              ? _issue(error)
              : PlannerIssue.calendarOperation,
        ),
      );
    }
  }

  Future<bool> importEvent(DeviceCalendarEvent event) async {
    final id =
        'calendar-${event.calendarId}-${event.id}-${event.startUtc.millisecondsSinceEpoch}';
    final existing = state.events.where((item) => item.id == id);
    return save(
      PlannerEvent(
        id: id,
        title: event.title,
        startUtc: event.startUtc,
        endUtc: event.endUtc,
        notes: event.notes,
        meetUrl: event.meetUrl,
        revision: existing.isEmpty ? 0 : existing.first.revision,
      ),
    );
  }

  Future<void> openMeet(String? url) async {
    try {
      if (url == null) {
        await links.createInBrowser();
      } else {
        await links.open(url);
      }
    } catch (_) {
      _emit(state.copyWith(issue: PlannerIssue.link));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
