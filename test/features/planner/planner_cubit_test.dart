import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_event.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_ports.dart';
import 'package:ramadan_assistant/features/planner/presentation/planner_cubit.dart';

class MemoryPlanner implements PlannerRepository {
  final List<PlannerEvent> events = [];
  bool failSave = false;
  bool failDelete = false;
  @override
  Future<List<PlannerEvent>> list() async => List.of(events);
  @override
  Stream<List<PlannerEvent>> watch() => const Stream.empty();
  @override
  Future<PlannerEvent> save(PlannerEvent event) async {
    if (failSave) throw StateError('Storage unavailable');
    event.validate();
    final saved = event.withPersistence(
      notificationId: 1000000010,
      revision: event.revision + 1,
    );
    events.removeWhere((item) => item.id == event.id);
    events.add(saved);
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    if (failDelete) throw StateError('Storage unavailable');
    events.removeWhere((item) => item.id == id);
  }
}

class FakeReminders implements PlannerReminderPort {
  bool denied = false;
  bool failCancel = false;
  int scheduled = 0;
  int permissionRequests = 0;
  @override
  Future<void> requestPermission() async {
    permissionRequests++;
    if (denied) throw const ReminderException(ReminderProblem.permission);
  }

  @override
  Future<void> schedule(PlannerEvent event) async {
    scheduled++;
  }

  @override
  Future<void> cancel(int notificationId) async {
    if (failCancel) throw StateError('Platform unavailable');
  }
}

class FakeCalendar implements DeviceCalendarPort {
  int created = 0;
  int updated = 0;
  bool denied = false;
  @override
  Future<List<DeviceCalendar>> connect() async {
    if (denied) throw const CalendarException(CalendarProblem.permission);
    return [
      const DeviceCalendar(
        id: 1,
        name: 'Local',
        account: 'On device',
        writable: true,
      ),
    ];
  }

  @override
  Future<List<DeviceCalendarEvent>> events(
    int calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async => [];
  @override
  Future<int> create(int calendarId, PlannerEvent event) async {
    created++;
    return 10;
  }

  @override
  Future<void> update(int nativeId, int calendarId, PlannerEvent event) async {
    updated++;
  }

  @override
  Future<void> delete(int nativeId) async {}
}

class FakeLinks implements MeetingLinkPort {
  bool fail = false;
  @override
  Future<void> open(String url) async {
    if (fail) throw StateError('Missing browser');
  }

  @override
  Future<void> createInBrowser() async {
    if (fail) throw StateError('Missing browser');
  }
}

PlannerEvent appointment() => PlannerEvent(
  id: 'appointment',
  title: 'Appointment',
  startUtc: DateTime.utc(2030, 1, 1, 10),
  endUtc: DateTime.utc(2030, 1, 1, 11),
  reminderMinutes: 5,
);

void main() {
  late MemoryPlanner repository;
  late FakeReminders reminders;
  late FakeCalendar calendar;
  late FakeLinks links;
  late PlannerCubit cubit;
  setUp(() {
    repository = MemoryPlanner();
    reminders = FakeReminders();
    calendar = FakeCalendar();
    links = FakeLinks();
    cubit = PlannerCubit(
      repository: repository,
      reminders: reminders,
      calendar: calendar,
      links: links,
    );
  });
  tearDown(() => cubit.close());

  test(
    'Denied notification permission preserves event and explicit retry recovers',
    () async {
      reminders.denied = true;
      expect(await cubit.save(appointment()), isTrue);
      expect(repository.events, hasLength(1));
      expect(cubit.state.issue, PlannerIssue.reminderPermission);
      expect(cubit.state.reminderRetryId, 'appointment');
      reminders.denied = false;
      await cubit.retryReminder('appointment');
      expect(reminders.scheduled, 1);
      expect(cubit.state.issue, isNull);
      expect(cubit.state.notice, PlannerNotice.saved);
    },
  );

  test(
    'Storage failure preserves form and does not schedule a nonexistent event',
    () async {
      repository.failSave = true;
      expect(await cubit.save(appointment()), isFalse);
      expect(reminders.scheduled, 0);
      expect(repository.events, isEmpty);
      expect(cubit.state.issue, PlannerIssue.save);
      expect(cubit.state.busy, isFalse);
    },
  );

  test(
    'Cancel failure blocks deletion until retry, without dropping record',
    () async {
      await cubit.save(appointment());
      reminders.failCancel = true;
      expect(await cubit.delete(repository.events.single), isFalse);
      expect(repository.events, hasLength(1));
      expect(cubit.state.issue, PlannerIssue.delete);
      reminders.failCancel = false;
      expect(await cubit.delete(repository.events.single), isTrue);
      expect(repository.events, isEmpty);
    },
  );

  test(
    'Calendar export persists native link and repeat export updates rather than duplicates',
    () async {
      await cubit.save(appointment());
      const selected = DeviceCalendar(
        id: 1,
        name: 'Local',
        account: 'On device',
        writable: true,
      );
      await cubit.exportEvent(repository.events.single, selected);
      expect(repository.events.single.deviceEventId, 10);
      await cubit.exportEvent(repository.events.single, selected);
      expect(calendar.created, 1);
      expect(calendar.updated, 1);
    },
  );

  test(
    'Calendar denial and missing browser expose recovery without losing local event',
    () async {
      await cubit.save(appointment());
      calendar.denied = true;
      await cubit.connectCalendar();
      expect(cubit.state.issue, PlannerIssue.calendarPermission);
      expect(repository.events, hasLength(1));
      links.fail = true;
      await cubit.openMeet(null);
      expect(cubit.state.issue, PlannerIssue.link);
    },
  );

  test('Disposed screen does not receive late load emissions', () async {
    final pending = Completer<List<PlannerEvent>>();
    final lateCubit = PlannerCubit(
      repository: _PendingRepository(pending.future),
      reminders: reminders,
      calendar: calendar,
      links: links,
    );
    final loading = lateCubit.load();
    await lateCubit.close();
    pending.complete([appointment()]);
    await loading;
  });

  test(
    'Expired reminder saves locally without asking for notification permission',
    () async {
      reminders.denied = true;
      final expired = PlannerEvent(
        id: 'old',
        title: 'Past appointment',
        startUtc: DateTime.utc(2000, 1, 1, 10),
        endUtc: DateTime.utc(2000, 1, 1, 11),
        reminderMinutes: 10,
      );
      expect(await cubit.save(expired), isTrue);
      expect(repository.events, hasLength(1));
      expect(cubit.state.issue, PlannerIssue.reminderExpired);
      expect(reminders.permissionRequests, 0);
      expect(reminders.scheduled, 0);
    },
  );

  test(
    'Calendar link storage failure retries existing native event instead of creating twice',
    () async {
      await cubit.save(appointment());
      const selected = DeviceCalendar(
        id: 1,
        name: 'Local',
        account: 'On device',
        writable: true,
      );
      repository.failSave = true;
      await cubit.exportEvent(repository.events.single, selected);
      expect(cubit.state.issue, PlannerIssue.calendarOperation);
      expect(repository.events.single.deviceEventId, isNull);
      repository.failSave = false;
      await cubit.exportEvent(repository.events.single, selected);
      expect(calendar.created, 1);
      expect(calendar.updated, 1);
      expect(repository.events.single.deviceEventId, 10);
    },
  );
}

class _PendingRepository extends MemoryPlanner {
  _PendingRepository(this.pending);
  final Future<List<PlannerEvent>> pending;
  @override
  Future<List<PlannerEvent>> list() => pending;
}
