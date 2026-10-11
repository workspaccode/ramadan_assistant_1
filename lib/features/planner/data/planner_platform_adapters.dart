import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/planner_event.dart';
import '../domain/planner_ports.dart';

class AwesomePlannerReminders implements PlannerReminderPort {
  const AwesomePlannerReminders({this.alarms = const PluginPlannerAlarms()});
  final PlannerAlarmPort alarms;
  static const channelKey = 'personal_reminders';

  @override
  Future<void> requestPermission() async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      final granted = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      if (!granted) throw const ReminderException(ReminderProblem.permission);
    }
  }

  @override
  Future<void> schedule(PlannerEvent event) async {
    // Replacing an event must remove its previous schedule, including when
    // the new reminder is disabled, denied, or already in the past.
    await cancel(event.notificationId);
    final time = event.reminderAt;
    if (time == null) {
      return;
    }
    if (!time.isAfter(DateTime.now().toUtc())) {
      throw const ReminderException(ReminderProblem.expired);
    }
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      throw const ReminderException(ReminderProblem.permission);
    }
    if (event.ringUntilStopped) {
      await alarms.schedule(event);
      return;
    }
    final created = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: event.notificationId,
        channelKey: channelKey,
        title: event.title,
        body: event.notes.isEmpty ? event.title : event.notes,
        payload: {'type': 'planner', 'eventId': event.id},
      ),
      // A one-off instant reminder; no exact-alarm/full-screen permission.
      schedule: NotificationCalendar.fromDate(date: time.toLocal()),
    );
    if (!created) throw const ReminderException(ReminderProblem.scheduling);
  }

  @override
  Future<void> cancel(int notificationId) async {
    if (!isPersonalAlarmId(notificationId)) {
      throw const ReminderException(ReminderProblem.scheduling);
    }
    Object? failure;
    try { await AwesomeNotifications().cancel(notificationId); } catch (error) { failure = error; }
    try { await alarms.cancel(notificationId); } catch (error) { failure ??= error; }
    if (failure != null) throw const ReminderException(ReminderProblem.scheduling);
  }
}

typedef PersonalAlarmSetter = Future<bool> Function(AlarmSettings settings);
typedef PersonalAlarmStopper = Future<bool> Function(int id);
typedef PersonalAlarmLookup = Future<AlarmSettings?> Function(int id);

class PluginPlannerAlarms implements PlannerAlarmPort {
  const PluginPlannerAlarms({this.setAlarm, this.stopAlarm, this.getAlarm, this.requestExactPermission});
  final PersonalAlarmSetter? setAlarm;
  final PersonalAlarmStopper? stopAlarm;
  final PersonalAlarmLookup? getAlarm;
  final Future<bool> Function()? requestExactPermission;

  @override
  Future<void> schedule(PlannerEvent event) async {
    if (!isPersonalAlarmId(event.notificationId) || !event.ringUntilStopped || event.reminderAt == null) {
      throw const ReminderException(ReminderProblem.scheduling);
    }
    if (!event.reminderAt!.isAfter(DateTime.now().toUtc())) {
      throw const ReminderException(ReminderProblem.expired);
    }
    // Called only after the user explicitly enables the continuous alarm.
    if (requestExactPermission != null) {
      if (!await requestExactPermission!()) throw const ReminderException(ReminderProblem.permission);
    } else if (Platform.isAndroid && !await Permission.scheduleExactAlarm.isGranted) {
      if (!await Permission.scheduleExactAlarm.request().isGranted) {
        throw const ReminderException(ReminderProblem.permission);
      }
    }
    final loc = AppLocalizationsLookup.instance;
    final settings = AlarmSettings(
      id: event.notificationId,
      dateTime: event.reminderAt!.toLocal(),
      assetAudioPath: 'assets/audio/tasbih_click.wav',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      allowSameSecondScheduling: true,
      allowAlarmOverlap: true,
      volumeSettings: VolumeSettings.fade(volume: .65,
        fadeDuration: const Duration(seconds: 2), volumeEnforced: true),
      notificationSettings: NotificationSettings(title: event.title,
        body: loc.planner_alarm_description, stopButton: loc.planner_alarm_stop,
        icon: 'launcher_icon'),
      payload: event.id,
    );
    final succeeded = await (setAlarm?.call(settings) ?? Alarm.set(alarmSettings: settings));
    if (!succeeded) throw const ReminderException(ReminderProblem.scheduling);
  }

  @override
  Future<void> cancel(int notificationId) async {
    if (!isPersonalAlarmId(notificationId)) throw const ReminderException(ReminderProblem.scheduling);
    final existing = await (getAlarm?.call(notificationId) ?? Alarm.getAlarm(notificationId));
    if (existing == null) return;
    final stopped = await (stopAlarm?.call(notificationId) ?? Alarm.stop(notificationId));
    if (!stopped) throw const ReminderException(ReminderProblem.scheduling);
  }
}

class UrlMeetingLinkPort implements MeetingLinkPort {
  const UrlMeetingLinkPort();
  @override
  Future<void> open(String url) async {
    if (!isGoogleMeetLink(url)) {
      throw const PlannerValidationException(PlannerValidation.meetingLink);
    }
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw StateError('Meeting application unavailable');
    }
  }

  @override
  Future<void> createInBrowser() async {
    if (!await launchUrl(
      Uri.parse('https://meet.google.com/new'),
      mode: LaunchMode.externalApplication,
    )) {
      throw StateError('Meeting application unavailable');
    }
  }
}

class AndroidDeviceCalendarPort implements DeviceCalendarPort {
  const AndroidDeviceCalendarPort({
    this.channel = const MethodChannel('app.tawabti/features'),
  });
  final MethodChannel channel;

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      throw const CalendarException(CalendarProblem.unavailable);
    } on PlatformException catch (error) {
      throw CalendarException(switch (error.code) {
        'calendar_permission_denied' => CalendarProblem.permission,
        'calendar_read_only' => CalendarProblem.readOnly,
        _ => CalendarProblem.operation,
      });
    }
  }

  @override
  Future<List<DeviceCalendar>> connect() async {
    final data = await _invoke<List<Object?>>('calendar.list') ?? [];
    return data.map((value) {
      final item = Map<String, Object?>.from(value as Map);
      return DeviceCalendar(
        id: item['id'] as int,
        name: item['name'] as String,
        account: item['account'] as String,
        writable: item['writable'] as bool,
      );
    }).toList();
  }

  @override
  Future<List<DeviceCalendarEvent>> events(
    int calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    final data =
        await _invoke<List<Object?>>('calendar.events', {
          'calendarId': calendarId,
          'from': fromUtc.millisecondsSinceEpoch,
          'to': toUtc.millisecondsSinceEpoch,
        }) ??
        [];
    return data.map((value) {
      final item = Map<String, Object?>.from(value as Map);
      return DeviceCalendarEvent(
        id: item['id'] as int,
        calendarId: calendarId,
        title: item['title'] as String,
        notes: item['notes'] as String? ?? '',
        startUtc: DateTime.fromMillisecondsSinceEpoch(
          item['start'] as int,
          isUtc: true,
        ),
        endUtc: DateTime.fromMillisecondsSinceEpoch(
          item['end'] as int,
          isUtc: true,
        ),
        meetUrl: isGoogleMeetLink(item['meetUrl'] as String? ?? '')
            ? item['meetUrl'] as String
            : null,
      );
    }).toList();
  }

  Map<String, Object?> _encode(int calendarId, PlannerEvent event) => {
    'localId': event.id,
    'calendarId': calendarId,
    'title': event.title,
    'notes': event.notes,
    'start': event.startUtc.millisecondsSinceEpoch,
    'end': event.endUtc.millisecondsSinceEpoch,
    'timeZone': DateTime.now().timeZoneName,
    'meetUrl': event.meetUrl,
    'reminderMinutes': event.reminderMinutes,
  };

  @override
  Future<int> create(int calendarId, PlannerEvent event) async {
    event.validate();
    return (await _invoke<int>('calendar.create', _encode(calendarId, event)))!;
  }

  @override
  Future<void> update(int nativeId, int calendarId, PlannerEvent event) async {
    event.validate();
    await _invoke<Object?>('calendar.update', {
      ..._encode(calendarId, event),
      'id': nativeId,
    });
  }

  @override
  Future<void> delete(int nativeId) async {
    await _invoke<Object?>('calendar.delete', {'id': nativeId});
  }
}
