import 'package:ramadan_assistant/core/services/adhan_alarm_service.dart';
import 'package:ramadan_assistant/core/services/dhikr_alarm_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

class TestService {
  static Future<void> triggerAdhanNow() async {
    final now = DateTime.now().add(const Duration(seconds: 10));
    await AdhanAlarmService.scheduleAdhan(
      id: 9991,
      prayerName: 'Fajr',
      dateTime: now,
      iqamaDelay: 5,
    );
  }

  static Future<void> triggerIqamaNow() async {
    final now = DateTime.now().add(const Duration(seconds: 15));
    await NotificationService.scheduleIqamaReminder(
      id: 9992,
      prayerName: 'Dhuhr',
      iqamaTime: now,
    );
  }

  static Future<void> triggerPrayerNearingNow() async {
    final now = DateTime.now().add(const Duration(seconds: 5));
    await NotificationService.schedulePrayerNearing(
      id: 9993,
      prayerName: 'Asr',
      prayerTime: now.add(const Duration(minutes: 10)),
    );
  }

  static Future<void> triggerDhikrNow() async {
    final now = DateTime.now().add(const Duration(seconds: 12));
    // We'll use a temporary reminder object for testing
    final testReminder = Reminder(
      id: 9994,
      reminderTypes: 'salawat',
      intervalMinutes: 1,
      isActive: true,
      repeatCount: 1, // Set to 1 as per user request to play once
      offsets: null,
      audioPaths: null,
    );
    await DhikrAlarmService.scheduleReminder(testReminder, testTime: now);
  }
}
