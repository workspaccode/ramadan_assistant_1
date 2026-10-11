enum PlannerValidation { title, dates, meetingLink, reminder }

class PlannerValidationException implements Exception {
  const PlannerValidationException(this.issue);
  final PlannerValidation issue;
}

/// Appointments are stored as instants; the UI edits and displays local time.
class PlannerEvent {
  const PlannerEvent({
    required this.id,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    this.notes = '',
    this.reminderMinutes,
    this.ringUntilStopped = false,
    this.meetUrl,
    this.notificationId = 0,
    this.revision = 0,
    this.deviceCalendarId,
    this.deviceEventId,
  });

  final String id;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final String notes;
  final int? reminderMinutes;
  final bool ringUntilStopped;
  final String? meetUrl;
  final int notificationId;
  final int revision;
  final int? deviceCalendarId;
  final int? deviceEventId;

  DateTime? get reminderAt => reminderMinutes == null
      ? null
      : startUtc.subtract(Duration(minutes: reminderMinutes!));

  void validate() {
    if (id.trim().isEmpty || title.trim().isEmpty || title.length > 160) {
      throw const PlannerValidationException(PlannerValidation.title);
    }
    if (!endUtc.isAfter(startUtc) || !startUtc.isUtc || !endUtc.isUtc) {
      throw const PlannerValidationException(PlannerValidation.dates);
    }
    if (reminderMinutes != null &&
        (reminderMinutes! < 0 || reminderMinutes! > 10080)) {
      throw const PlannerValidationException(PlannerValidation.reminder);
    }
    if (ringUntilStopped && reminderMinutes == null) {
      throw const PlannerValidationException(PlannerValidation.reminder);
    }
    if (meetUrl != null &&
        meetUrl!.trim().isNotEmpty &&
        !isGoogleMeetLink(meetUrl!)) {
      throw const PlannerValidationException(PlannerValidation.meetingLink);
    }
  }

  PlannerEvent withPersistence({
    required int notificationId,
    required int revision,
  }) => PlannerEvent(
    id: id,
    title: title.trim(),
    startUtc: startUtc,
    endUtc: endUtc,
    notes: notes,
    reminderMinutes: reminderMinutes,
    ringUntilStopped: ringUntilStopped,
    meetUrl: meetUrl?.trim().isEmpty == true ? null : meetUrl?.trim(),
    notificationId: notificationId,
    revision: revision,
    deviceCalendarId: deviceCalendarId,
    deviceEventId: deviceEventId,
  );

  PlannerEvent withDeviceLink(int calendarId, int eventId) => PlannerEvent(
    id: id,
    title: title,
    startUtc: startUtc,
    endUtc: endUtc,
    notes: notes,
    reminderMinutes: reminderMinutes,
    ringUntilStopped: ringUntilStopped,
    meetUrl: meetUrl,
    notificationId: notificationId,
    revision: revision,
    deviceCalendarId: calendarId,
    deviceEventId: eventId,
  );
}

bool isGoogleMeetLink(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.toLowerCase() == 'meet.google.com' &&
      uri.userInfo.isEmpty &&
      (!uri.hasPort || uri.port == 443) &&
      RegExp(r'^/[a-z]{3}-[a-z]{4}-[a-z]{3}/?$').hasMatch(uri.path);
}

bool isPersonalAlarmId(int id) => id >= 1000000000 && id < 1500000000;
