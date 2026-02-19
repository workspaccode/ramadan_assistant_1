import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/adhan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Callback for background tasks - must be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final locationService = LocationService();
    final prayerService = PrayerService();

    try {
      final position = await locationService.getCurrentLocation();
      await _scheduleDayPrayerNotifications(position, prayerService);
      return true;
    } catch (e) {
      print("Background Task Error: $e");
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

      // Schedule Iqama reminder
      final iqamaTime = prayerTime.add(Duration(minutes: delay));
      await NotificationService.scheduleIqamaReminder(
        id: prayerId + 100, // Offset ID for Iqama
        prayerName: prayerName,
        iqamaTime: iqamaTime,
      );

      // Schedule Wird Reminder (if plan is pagesPerPrayer)
      // We check shared prefs for active plan
      final wirdPlanType = prefs.getString('wird_plan_type');
      final wirdPlanValue = prefs.getInt('wird_plan_value');

      if (wirdPlanType == 'pagesPerPrayer' && wirdPlanValue != null) {
        // Schedule 20 mins after prayer (or 30, user didn't specify exact time, but "remind him *of* the prayer"
        // usually means "don't forget what you have to do *at* this prayer")
        // Since this is a "read *after* prayer" plan, a reminder 20-30m after prayer (or 10m after iqama) makes sense.
        // Let's do 20 mins after prayer time.
        final reminderTime = prayerTime.add(const Duration(minutes: 20));
        await NotificationService.scheduleWirdReminder(
          id: prayerId + 200, // Offset ID for Wird
          prayerName: prayerName,
          reminderTime: reminderTime,
          pages: wirdPlanValue,
        );
      }
    }
  }

  // Daily Summary Check (Post-Isha)
  final ishaTime =
      prayers.firstWhere((p) => p['name'] == 'Isha')['time'] as DateTime;
  if (ishaTime.isAfter(now)) {
    final summaryTime = ishaTime.add(const Duration(hours: 1));
    // Generic reminder to check progress if not done
    // We can't easily check DB here without opening it, so we'll just schedule a generic "Daily Review"
    // notification that deep links to Wird screen
    await NotificationService.scheduleWirdReminder(
      id: 300,
      prayerName: 'Daily Review',
      reminderTime: summaryTime,
      pages: 0, // 0 indicates summary/review
    );
  }
}

class BackgroundTaskService {
  static void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static void scheduleDailyUpdate() {
    // Run at midnight to schedule next day's prayers
    Workmanager().registerPeriodicTask(
      "daily-prayer-update",
      "prayerUpdateTask",
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
      print("Error scheduling notifications: $e");
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

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Called when notification is created
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    final payload = receivedNotification.payload;
    if (payload != null) {
      final type = payload['type'];

      if (type == 'adhan' && !_isAdhanScreenActive) {
        final prayer = payload['prayer'] ?? 'Prayer';
        final delay = int.tryParse(payload['iqamaDelay'] ?? '10') ?? 10;

        // Always show adhan screen for adhan notifications
        await _showAdhanScreen(prayer, delay);

        // Play adhan audio in background
        final isFajr = prayer.toLowerCase() == 'fajr';
        await AudioService.playAdhanInBackground(isFajr: isFajr);
      } else if (type == 'iqama') {
        // Play iqama reminder sound in background
        final prayer = payload['prayer'] ?? '';
        final isFajr = prayer.toLowerCase() == 'fajr';
        await AudioService.playIqamaReminderInBackground(isFajr: isFajr);
      } else if (type == 'dhikr') {
        final audioPath = payload['audioPath'];
        if (audioPath != null && audioPath.isNotEmpty) {
          // Play dhikr sound in background using static method
          await AudioService.playDhikrInBackground(audioPath);
        }
      }
    }
  }

  @pragma("vm:entry-point")
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
      } else if (receivedAction.buttonKeyPressed == 'DISMISS') {
        _isAdhanScreenActive = false;
        await AwesomeNotifications().cancelAll();
      } else if (type == 'adhan') {
        // Default tap on adhan notification
        await _showAdhanScreen(prayer ?? 'Prayer', delay);
      } else if (type == 'iqama') {
        navigatorKey.currentState?.pushNamed('/iqama', arguments: prayer);
      }
    }
  }

  @pragma("vm:entry-point")
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
          builder: (_) => AdhanScreen(
            prayerName: prayerName,
            iqamaDelayMinutes: iqamaDelay,
          ),
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
