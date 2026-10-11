import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/adhan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for scheduling Adhan alarms using the `alarm` package.
/// This replaces AwesomeNotifications for prayer audio playback,
/// ensuring full-length Adhan plays even when the app is in the background.
class AdhanAlarmService {
  static StreamSubscription<AlarmSet>? _ringingSubscription;

  /// Navigator key used to push the AdhanScreen when alarm fires.
  /// This should be the same key used by NotificationActionHandler.
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isAdhanScreenActive = false;
  static int _presentation = 0;

  /// Initialize the alarm service and listen for ringing events.
  static Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;
    await Alarm.init();

    // Listen for alarm ringing events
    await _ringingSubscription?.cancel();
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
    final prefs = await SharedPreferences.getInstance();
    final adhanEnabled = prefs.getBool('adhan_enabled') ?? true;

    // Don't schedule if disabled or if time has already passed
    if (!adhanEnabled || dateTime.isBefore(DateTime.now())) return;

    final isFajr = prayerName.toLowerCase() == 'fajr';
    final audioPath = isFajr
        ? 'assets/audio/adhan_fajr.mp3'
        : 'assets/audio/adhan_regular.mp3';

    final localizedPrayer = prayerName.toLowerCase().tr();

    final alarmSettings = AlarmSettings(
      id: id,
      allowSameSecondScheduling: true,
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

  /// Cancel specific adhan alarms (id range 1-5)
  static Future<void> cancelAdhans() async {
    for (int i = 1; i <= 5; i++) {
      await Alarm.stop(i);
    }
  }

  /// Called when an alarm starts ringing. Opens the AdhanScreen.
  static void _onAlarmRinging(AlarmSettings alarm) {
    if (!isPrayerAlarmId(alarm.id)) return;
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    // Extract prayer name from the alarm ID
    final prayerName = _getPrayerNameFromId(alarm.id);

    debugPrint(
      'AdhanAlarmService: Alarm ringing for $prayerName (id=${alarm.id})',
    );

    unawaited(presentAdhan(navigator, prayerName: prayerName));
  }

  static bool isPrayerAlarmId(int id) => id >= 1 && id <= 5;

  /// All foreground triggers share the same presentation guard, so the local
  /// prayer clock and native alarm cannot stack two full-screen routes.
  static Future<void> presentAdhan(
    NavigatorState navigator, {
    required String prayerName,
  }) async {
    if (_isAdhanScreenActive || !navigator.mounted) return;
    _isAdhanScreenActive = true;
    final presentation = ++_presentation;
    try {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => AdhanScreen(prayerName: prayerName),
          fullscreenDialog: true,
        ),
      );
    } catch (error) {
      debugPrint('AdhanAlarmService: Error showing AdhanScreen: $error');
    } finally {
      if (presentation == _presentation) _isAdhanScreenActive = false;
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
