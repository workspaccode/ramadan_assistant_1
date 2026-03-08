import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/widgets/reminder_alarm_screen.dart';

/// Service for scheduling Dhikr (Reminder) alarms using the `alarm` package.
class DhikrAlarmService {
  static StreamSubscription<AlarmSet>? _ringingSubscription;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isAlarmScreenActive = false;

  /// Initialize the alarm service
  static Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;
    // Note: Alarm.init() is already called in AdhanAlarmService.init()

    _ringingSubscription?.cancel();
    _ringingSubscription = Alarm.ringing.listen((AlarmSet alarmSet) {
      for (final alarm in alarmSet.alarms) {
        // Dhikr alarm IDs are typically higher than prayer IDs (1000+)
        if (alarm.id >= 1000) {
          _onAlarmRinging(alarm);
        }
      }
    });
  }

  /// Schedule a Dhikr alarm
  static Future<void> scheduleReminder(
    Reminder reminder, {
    DateTime? testTime,
  }) async {
    final now = DateTime.now();
    final scheduledTime =
        testTime ?? now.add(Duration(minutes: reminder.intervalMinutes));

    final audioPaths = reminder.audioPaths?.split(',') ?? [];
    final audioPath = audioPaths.isNotEmpty && audioPaths.first.isNotEmpty
        ? 'assets/audio/${audioPaths.first}'
        : 'assets/audio/zakr/saly-ala-mohamed.mp3';

    // Ensure asset path is correct (remove assets/ if it's already there)
    final cleanAudioPath = audioPath.replaceFirst('assets/assets/', 'assets/');

    final alarmSettings = AlarmSettings(
      id: 1000 + reminder.id, // Custom offset for Dhikr alarms
      dateTime: scheduledTime,
      assetAudioPath: cleanAudioPath,
      loopAudio:
          true, // Audio loops until the screen's auto-dismiss timer stops it
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 3),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'notification_dhikr_title'.tr(),
        body: 'notification_dhikr_body'.tr(),
        stopButton: 'stop_btn'.tr(),
        icon: 'launcher_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint(
      'DhikrAlarmService: Scheduled reminder ${reminder.id} at $scheduledTime',
    );
  }

  /// Stop a specific alarm
  static Future<void> stopReminder(int reminderId) async {
    await Alarm.stop(1000 + reminderId);
    _isAlarmScreenActive = false;
  }

  /// Called when alarm rings
  static void _onAlarmRinging(AlarmSettings alarm) {
    if (_isAlarmScreenActive) return;
    _isAlarmScreenActive = true;

    final reminderId = alarm.id - 1000;

    _navigatorKey?.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ReminderAlarmScreen(reminderId: reminderId),
        fullscreenDialog: true,
      ),
    );
  }

  static void markAlarmScreenClosed() {
    _isAlarmScreenActive = false;
  }

  static void dispose() {
    _ringingSubscription?.cancel();
  }
}
