import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/adhan_screen.dart';
import 'package:ramadan_assistant/presentation/screens/notifications_screen/notifications_screen.dart';
import 'package:ramadan_assistant/presentation/screens/update_screen/update_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Callback for background tasks - must be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final locationService = LocationService();
    final prayerService = PrayerService();

    try {
      if (task == 'prayerUpdateTask' || task == Workmanager.iOSBackgroundTask) {
        final position = await locationService.getCurrentLocation();
        await _scheduleDayPrayerNotifications(position, prayerService);
      } else if (task == 'tasbihReportTask') {
        await _sendIntelligentTasbihReport();
      }
      return true;
    } catch (e) {
      print('Background Task Error: $e');
      return false;
    }
  });
}

/// Schedule all prayer notifications for the day
Future<void> _scheduleDayPrayerNotifications(
  Position position,
  PrayerService prayerService,
) async {
  final prefs = await SharedPreferences.getInstance();
  final iqamaSystem = prefs.getString('iqama_system') ?? 'manual';
  final iqamaPreset = prefs.getString('iqama_preset') ?? 'saudi';
  final manualDelay = prefs.getInt('iqama_delay') ?? 10;
  final methodId = prefs.getString('calculation_method');
  final madhabId = prefs.getString('madhab');

  final prayerTimes = prayerService.getPrayerTimes(
    position,
    methodId: methodId,
    madhabId: madhabId,
  );
  final now = DateTime.now();

  final prayers = [
    {'name': 'Fajr', 'time': prayerTimes.fajr, 'id': 1},
    {'name': 'Dhuhr', 'time': prayerTimes.dhuhr, 'id': 2},
    {'name': 'Asr', 'time': prayerTimes.asr, 'id': 3},
    {'name': 'Maghrib', 'time': prayerTimes.maghrib, 'id': 4},
    {'name': 'Isha', 'time': prayerTimes.isha, 'id': 5},
  ];

  final delaysJson = prefs.getString('iqama_delays_map');
  final Map<String, int> delays = delaysJson != null
      ? Map<String, int>.from(jsonDecode(delaysJson))
      : {'fajr': 20, 'dhuhr': 15, 'asr': 15, 'maghrib': 5, 'isha': 10};

  for (final prayer in prayers) {
    final prayerTime = prayer['time'] as DateTime;
    final prayerId = prayer['id'] as int;
    final prayerName = prayer['name'] as String;

    int delay = delays[prayerName.toLowerCase()] ?? manualDelay;

    if (iqamaSystem == 'preset') {
      if (iqamaPreset == 'saudi') {
        switch (prayerName) {
          case 'Fajr':
            delay = 15;
            break;
          case 'Dhuhr':
            delay = 12;
            break;
          case 'Asr':
            delay = 10;
            break;
          case 'Maghrib':
            delay = 7;
            break;
          case 'Isha':
            delay = 15;
            break;
        }
      } else if (iqamaPreset == 'egypt') {
        switch (prayerName) {
          case 'Fajr':
            delay = 10;
            break;
          case 'Dhuhr':
            delay = 10;
            break;
          case 'Asr':
            delay = 8;
            break;
          case 'Maghrib':
            delay = 5;
            break;
          case 'Isha':
            delay = 10;
            break;
        }
      }
    }

    // Schedule Adhan notification if time hasn't passed
    if (prayerTime.isAfter(now)) {
      // 1. Prayer Nearing Reminder (10 mins before)
      await NotificationService.schedulePrayerNearing(
        id: prayerId,
        prayerName: prayerName,
        prayerTime: prayerTime,
      );

      // 2. Adhan Notification
      await NotificationService.schedulePrayerNotification(
        id: prayerId,
        prayerName: prayerName,
        prayerTime: prayerTime,
        payload: {
          'prayer': prayerName,
          'type': 'adhan',
          'iqamaDelay': delay.toString(),
        },
      );

      // 3. Iqama Reminder
      final iqamaTime = prayerTime.add(Duration(minutes: delay));
      await NotificationService.scheduleIqamaReminder(
        id: prayerId + 100, // Offset ID for Iqama
        prayerName: prayerName,
        iqamaTime: iqamaTime,
      );

      // 4. Wird Reminder (if plan is pagesPerPrayer)
      final wirdPlanType = prefs.getString('wird_plan_type');
      final wirdPlanValue = prefs.getInt('wird_plan_value');

      if ((wirdPlanType == 'pagesPerPrayer' || wirdPlanType == 'khatma') &&
          wirdPlanValue != null) {
        // For khatma (1/month), we aim for ~4 pages per prayer (total 21)
        final pagesToRead = wirdPlanType == 'khatma' ? 4 : wirdPlanValue;

        final reminderTime = prayerTime.add(const Duration(minutes: 20));
        await NotificationService.scheduleWirdReminder(
          id: prayerId + 200, // Offset ID for Wird
          prayerName: prayerName,
          reminderTime: reminderTime,
          pages: pagesToRead,
        );
      }
    }
  }

  // Daily Islamic Tip (e.g., at 10 AM)
  final tipTime = DateTime(now.year, now.month, now.day, 10, 0);
  if (tipTime.isAfter(now)) {
    await NotificationService.scheduleIslamicTip(
      id: 500,
      tipTitle: 'Islamic Pearl of the Day'.tr(),
      tipBody: 'Today is a gift from Allah. Make the most of it with Dhikr.'
          .tr(),
      scheduleTime: tipTime,
    );
  }

  // Daily Summary & Tasbih Report (Post-Isha)
  final ishaEntry = prayers.firstWhere((p) => p['name'] == 'Isha');
  final ishaTime = ishaEntry['time'] as DateTime;
  if (ishaTime.isAfter(now)) {
    final summaryTime = ishaTime.add(const Duration(hours: 1));
    final delay = summaryTime.difference(now);

    // Register a one-off task for the intelligent report
    Workmanager().registerOneOffTask(
      'daily-tasbih-report',
      'tasbihReportTask',
      initialDelay: delay,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

Future<void> _sendIntelligentTasbihReport() async {
  final db = GetIt.instance<AppDatabase>();
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  try {
    // Query completed sessions for today
    final sessions =
        await (db.select(db.tasbihSessions)..where(
              (t) =>
                  t.createdAt.isBiggerOrEqualValue(todayStart) &
                  t.completedAt.isNotNull(),
            ))
            .get();

    final totalDhikr = sessions.length;
    final totalCount = sessions.fold<int>(0, (sum, s) => sum + s.count);

    String title;
    String message;

    if (totalDhikr >= 5 || totalCount >= 150) {
      // Tier 1: Advice (Positive)
      title = 'ما شاء الله! يوم عامر بالذكر'.tr();
      message = 'لقد أتممت {} جلسة تسبيح اليوم. هنيئاً لك هذا القرب من الله.'
          .tr(args: [totalDhikr.toString()]);
    } else if (totalDhikr > 0) {
      // Tier 2: Guidance (Neutral)
      title = 'خطوات مباركة في طريق الذكر'.tr();
      message =
          'بداية طيبة اليوم بـ {} جلسات. ما رأيك بزيادة الورد غداً لزيادة الطمأنينة؟'
              .tr(args: [totalDhikr.toString()]);
    } else {
      // Tier 3: Admonishment (Gentle)
      title = 'رسالة محب.. لا تنسَ ذكر الله'.tr();
      message =
          'مر اليوم دون تسجيل جلسات تسبيح. الذكر حياة القلوب، ابدأ الآن ولو بالقليل.'
              .tr();
    }

    await NotificationService.showImmediateTasbihReport(
      id: 600,
      title: title,
      message: message,
      audioPath: 'zakr/la-ilaha-illallah.wav',
    );
  } finally {
    await db.close();
  }
}

class BackgroundTaskService {
  static void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static void scheduleDailyUpdate() {
    // Run at midnight to schedule next day's prayers
    Workmanager().registerPeriodicTask(
      'daily-prayer-update',
      'prayerUpdateTask',
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );
  }

  /// Manually trigger prayer notification scheduling (for initial load)
  static Future<void> scheduleNotificationsNow() async {
    final locationService = LocationService();
    final prayerService = PrayerService();

    try {
      final position = await locationService.getCurrentLocation();
      await _scheduleDayPrayerNotifications(position, prayerService);
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }
}

/// Handles notification actions (when user taps notification)
class NotificationActionHandler {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isAdhanScreenActive = false;

  static Future<void> initialize() async {
    // Listen for notification actions
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Called when notification is created
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    final payload = receivedNotification.payload;
    if (payload != null) {
      final type = payload['type'];

      if (type == 'adhan' && !_isAdhanScreenActive) {
        final prayer = payload['prayer'] ?? 'Prayer';
        final delay = int.tryParse(payload['iqamaDelay'] ?? '10') ?? 10;

        // Show adhan screen — sound is handled by notification channel natively
        await _showAdhanScreen(prayer, delay);
      }
      // Note: adhan/iqama sounds now play via notification channel soundSource
      // (works even when app is killed). Only dhikr still uses Dart audio.
      if (type == 'dhikr' || type == 'tasbih_report') {
        final audioPath = payload['audioPath'];
        if (audioPath != null && audioPath.isNotEmpty) {
          await AudioService.playDhikrInBackground(audioPath);
        }
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload;

    if (payload != null) {
      final type = payload['type'];
      final prayer = payload['prayer'];
      final delay = int.tryParse(payload['iqamaDelay'] ?? '10') ?? 10;

      if (receivedAction.buttonKeyPressed == 'OPEN_ADHAN') {
        await _showAdhanScreen(prayer ?? 'Prayer', delay);
      } else if (receivedAction.buttonKeyPressed == 'OPEN_UPDATE') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const UpdateScreen()),
        );
      } else if (receivedAction.buttonKeyPressed == 'DISMISS') {
        _isAdhanScreenActive = false;
        await AwesomeNotifications().cancelAll();
      } else if (type == 'adhan') {
        // Default tap on adhan notification
        await _showAdhanScreen(prayer ?? 'Prayer', delay);
      } else if (type == 'iqama') {
        navigatorKey.currentState?.pushNamed('/iqama', arguments: prayer);
      } else if (type == 'update') {
        // Tapped update notification
        final updateType = payload['track'];
        if (updateType == 'manual-update') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const UpdateScreen()),
          );
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        }
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    _isAdhanScreenActive = false;
  }

  static Future<void> _showAdhanScreen(
    String prayerName,
    int iqamaDelay,
  ) async {
    if (_isAdhanScreenActive) return;
    _isAdhanScreenActive = true;

    try {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AdhanScreen(prayerName: prayerName),
          fullscreenDialog: true,
        ),
      );
    } catch (e) {
      debugPrint('Error showing Adhan screen: $e');
    }
  }

  static void markAdhanScreenClosed() {
    _isAdhanScreenActive = false;
  }
}
