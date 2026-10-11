import 'planner_event.dart';

abstract interface class PlannerRepository {
  Future<List<PlannerEvent>> list();
  Stream<List<PlannerEvent>> watch();
  Future<PlannerEvent> save(PlannerEvent event);
  Future<void> delete(String id);
}

enum ReminderProblem { permission, expired, scheduling }

class ReminderException implements Exception {
  const ReminderException(this.problem);
  final ReminderProblem problem;
}

abstract interface class PlannerReminderPort {
  /// Must only prompt for permission after an explicit user action.
  Future<void> requestPermission();
  Future<void> schedule(PlannerEvent event);
  Future<void> cancel(int notificationId);
}

abstract interface class PlannerAlarmPort {
  Future<void> schedule(PlannerEvent event);
  Future<void> cancel(int notificationId);
}

abstract interface class MeetingLinkPort {
  Future<void> open(String url);
  Future<void> createInBrowser();
}

class DeviceCalendar {
  const DeviceCalendar({
    required this.id,
    required this.name,
    required this.account,
    required this.writable,
  });
  final int id;
  final String name;
  final String account;
  final bool writable;
}

class DeviceCalendarEvent {
  const DeviceCalendarEvent({
    required this.id,
    required this.calendarId,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    this.notes = '',
    this.meetUrl,
  });
  final int id;
  final int calendarId;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final String notes;
  final String? meetUrl;
}

enum CalendarProblem { permission, unavailable, readOnly, operation }

class CalendarException implements Exception {
  const CalendarException(this.problem);
  final CalendarProblem problem;
}

abstract interface class DeviceCalendarPort {
  /// Explicitly requested by Connect, never during startup.
  Future<List<DeviceCalendar>> connect();
  Future<List<DeviceCalendarEvent>> events(
    int calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  );
  Future<int> create(int calendarId, PlannerEvent event);
  Future<void> update(int nativeId, int calendarId, PlannerEvent event);
  Future<void> delete(int nativeId);
}
