import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import '../domain/worship_ports.dart';

class AndroidQuranReader implements QuranReaderPort {
  const AndroidQuranReader({
    this.channel = const MethodChannel('app.tawabti/features'),
  });
  final MethodChannel channel;
  @override
  Future<List<QuranReaderApp>> availableApps() async {
    final rows = await channel.invokeListMethod<Object?>('reader.apps') ?? [];
    return rows
        .map((row) {
          final data = (row as Map).cast<String, Object?>();
          return QuranReaderApp(
            id: data['packageName'] as String,
            label: data['label'] as String,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<bool> open({required String appId, required int page}) async =>
      await channel.invokeMethod<bool>('reader.open', {'packageName': appId}) ??
      false;
}

class AwesomeWorshipReminder implements WorshipReminderPort {
  static const notificationId = 2000000;
  @override
  Future<bool> scheduleDailyWird({
    required int minuteOfDay,
    required String title,
    required String body,
  }) async {
    if (minuteOfDay < 0 || minuteOfDay >= 1440) {
      throw ArgumentError.value(minuteOfDay);
    }
    final notifications = AwesomeNotifications();
    // A rejected replacement must not leave an older reminder for a changed plan.
    await notifications.cancel(notificationId);
    if (!await notifications.isNotificationAllowed() &&
        !await notifications.requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
          ],
        )) {
      return false;
    }
    return notifications.createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'personal_reminders',
        title: title,
        body: body,
        payload: {'type': 'worship'},
      ),
      schedule: NotificationCalendar(
        hour: minuteOfDay ~/ 60,
        minute: minuteOfDay % 60,
        second: 0,
        repeats: true,
        timeZone: await notifications.getLocalTimeZoneIdentifier(),
      ),
    );
  }

  @override
  Future<void> cancelDailyWird() =>
      AwesomeNotifications().cancel(notificationId);
}
