import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/adhan_screen.dart';

/// Service for scheduling Adhan alarms using the `alarm` package.
/// This replaces AwesomeNotifications for prayer audio playback,
/// ensuring full-length Adhan plays even when the app is in the background.
class AdhanAlarmService {
  static StreamSubscription<AlarmSet>? _ringingSubscription;

  /// Navigator key used to push the AdhanScreen when alarm fires.
  /// This should be the same key used by NotificationActionHandler.
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isAdhanScreenActive = false;

  /// Initialize the alarm service and listen for ringing events.
  static Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;
    await Alarm.init();

    // Listen for alarm ringing events
    _ringingSubscription?.cancel();
    _ringingSubscription = Alarm.ringing.listen((AlarmSet alarmSet) {
      for (final alarm in alarmSet.alarms) {
        _onAlarmRinging(alarm);
      }
    });
  }

  /// Schedule an Adhan alarm for a specific prayer.
  ///
  /// [id] - Unique ID for this prayer alarm (1=Fajr, 2=Dhuhr, 3=Asr, 4=Maghrib, 5=Isha)
  /// [prayerName] - English prayer name (e.g., 'Fajr', 'Dhuhr')
  /// [dateTime] - Exact time when the Adhan should play
  /// [iqamaDelay] - Minutes until Iqama (stored for AdhanScreen use)
  static Future<void> scheduleAdhan({
    required int id,
    required String prayerName,
    required DateTime dateTime,
    int iqamaDelay = 10,
  }) async {
    // Don't schedule if time has already passed
    if (dateTime.isBefore(DateTime.now())) return;

    final isFajr = prayerName.toLowerCase() == 'fajr';
    final audioPath = isFajr
        ? 'assets/audio/adhan_fajr.mp3'
        : 'assets/audio/adhan_regular.mp3';

    final localizedPrayer = prayerName.toLowerCase().tr();

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: audioPath,
      loopAudio: false,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 3),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'notification_adhan_title'.tr(args: [localizedPrayer]),
        body: 'notification_adhan_body'.tr(args: [localizedPrayer]),
        stopButton: 'stop_adhan'.tr(),
        icon: 'launcher_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint(
      'AdhanAlarmService: Scheduled $prayerName alarm (id=$id) at $dateTime',
    );
  }

  /// Stop a specific Adhan alarm by ID.
  static Future<void> stopAdhan(int id) async {
    await Alarm.stop(id);
    _isAdhanScreenActive = false;
  }

  /// Cancel all scheduled Adhan alarms.
  static Future<void> cancelAll() async {
    await Alarm.stopAll();
    _isAdhanScreenActive = false;
  }

  /// Called when an alarm starts ringing. Opens the AdhanScreen.
  static void _onAlarmRinging(AlarmSettings alarm) {
    if (_isAdhanScreenActive) return;
    _isAdhanScreenActive = true;

    // Extract prayer name from the alarm ID
    final prayerName = _getPrayerNameFromId(alarm.id);

    debugPrint(
      'AdhanAlarmService: Alarm ringing for $prayerName (id=${alarm.id})',
    );

    try {
      _navigatorKey?.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AdhanScreen(prayerName: prayerName),
          fullscreenDialog: true,
        ),
      );
    } catch (e) {
      debugPrint('AdhanAlarmService: Error showing AdhanScreen: $e');
    }
  }

  /// Map alarm ID back to prayer name.
  static String _getPrayerNameFromId(int id) {
    switch (id) {
      case 1:
        return 'Fajr';
      case 2:
        return 'Dhuhr';
      case 3:
        return 'Asr';
      case 4:
        return 'Maghrib';
      case 5:
        return 'Isha';
      default:
        return 'Prayer';
    }
  }

  /// Mark the Adhan screen as closed (call from AdhanScreen dispose).
  static void markAdhanScreenClosed() {
    _isAdhanScreenActive = false;
  }

  /// Dispose the service (call on app shutdown if needed).
  static void dispose() {
    _ringingSubscription?.cancel();
    _ringingSubscription = null;
  }
}
