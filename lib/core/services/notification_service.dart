import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static Future<void> initialize() async {
    // Legacy channels from the removed prayer/adhan/iqama and dhikr alerts;
    // removing a channel also cancels anything still scheduled on it.
    const legacy = [
      'prayer_times_v2',
      'prayer_times_fajr_v2',
      'iqama_channel',
      'reminders',
    ];
    await AwesomeNotifications().initialize('resource://mipmap/launcher_icon', [
      NotificationChannel(
        channelKey: 'islamic_tips',
        channelName: 'Islamic Facts & Tips',
        channelDescription: 'Daily educational Islamic facts',
        defaultColor: AppTheme.primaryColor,
        importance: NotificationImportance.Default,
      ),
      NotificationChannel(
        channelKey: 'personal_reminders',
        channelName: 'Personal reminders',
        channelDescription: 'Appointments and daily reading reminders',
        defaultColor: AppTheme.primaryColor,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'daily_reports',
        channelName: 'Daily Progress Reports',
        channelDescription: 'Summary of your daily worship performance',
        importance: NotificationImportance.High,
        defaultColor: AppTheme.secondaryColor,
      ),
      NotificationChannel(
        channelKey: 'app_updates',
        channelName: 'App Updates',
        channelDescription: 'Notifications for app updates and patches',
        defaultColor: AppTheme.primaryColor,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ], debug: true);
    for (final key in legacy) {
      await AwesomeNotifications().removeChannel(key);
    }
  }

  static Future<void> requestPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.FullScreenIntent,
          NotificationPermission.PreciseAlarms,
          NotificationPermission.CriticalAlert,
          NotificationPermission.OverrideDnD,
        ],
      );
    }
  }

  /// Save notification to local history in SharedPreferences
  static Future<void> saveToHistory({
    required String title,
    required String body,
    required String category,
    Map<String, dynamic>? data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const String historyKey = 'update_history';

      final historyJson = prefs.getString(historyKey);
      List<Map<String, dynamic>> history = [];
      if (historyJson != null && historyJson.isNotEmpty) {
        final decoded = jsonDecode(historyJson) as List;
        history = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      final entry = {
        'title': title,
        'body': body,
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'applied',
        'data': data,
      };

      history.add(entry);
      if (history.length > 50) history.removeRange(0, history.length - 50);

      await prefs.setString(historyKey, jsonEncode(history));
    } catch (e) {
      // Ignore errors in background
    }
  }

  /// Schedule the Islamic tip every day at [scheduleTime]'s hour/minute
  static Future<void> scheduleIslamicTip({
    required int id,
    required String tipTitle,
    required String tipBody,
    required DateTime scheduleTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'islamic_tips',
        title: tipTitle,
        body: tipBody,
        category: NotificationCategory.Status,
        payload: {'type': 'tip'},
      ),
      schedule: NotificationCalendar(
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

  static Future<void> showImmediateTasbihReport({
    required int id,
    required String title,
    required String message,
    String? audioPath,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'daily_reports',
        title: title,
        body: message,
        category: NotificationCategory.Status,
        payload: {'type': 'tasbih_report', 'audioPath': audioPath},
      ),
    );
  }

  static Future<void> scheduleTasbihReport({
    required int id,
    required String title,
    required String message,
    required DateTime scheduleTime,
    String? audioPath,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'daily_reports',
        title: title,
        body: message,
        category: NotificationCategory.Status,
        payload: {'type': 'tasbih_report', 'audioPath': audioPath},
      ),
      schedule: NotificationCalendar(
        year: scheduleTime.year,
        month: scheduleTime.month,
        day: scheduleTime.day,
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: 0,
        allowWhileIdle: true,
      ),
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Show a local notification for app updates (triggered by FCM)
  static Future<void> showUpdateNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        channelKey: 'app_updates',
        title: title,
        body: body,
        category: NotificationCategory.Status,
        wakeUpScreen: true,
        payload: {'type': 'update', ...?payload},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_UPDATE',
          label: 'تحديث الآن',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'لاحقاً',
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }
}
