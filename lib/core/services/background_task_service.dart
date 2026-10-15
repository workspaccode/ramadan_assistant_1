import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/platform/feature_platform.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/update_screen/update_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/update_details_dialog.dart';
import 'package:workmanager/workmanager.dart';

final _logger = Logger();

/// Callback for background tasks - must be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == BackgroundTaskService.dailyExtrasTask ||
          task == Workmanager.iOSBackgroundTask) {
        await _scheduleDailyExtras().timeout(const Duration(minutes: 2));
      } else if (task == 'tasbihReportTask') {
        await _sendIntelligentTasbihReport().timeout(
          const Duration(minutes: 1),
        );
      }
      return true;
    } catch (e) {
      _logger.e('Background Task Error: $task', error: e);
      return false;
    }
  });
}

/// Schedules the two daily, prayer-independent notifications: the Islamic tip
/// (10:00, repeating) and the evening tasbih report (21:00 one-off task).
Future<void> _scheduleDailyExtras() async {
  final now = DateTime.now();

  // Daily Islamic Tip (10 AM, repeats every day).
  await NotificationService.scheduleIslamicTip(
    id: 500,
    tipTitle: 'Islamic Pearl of the Day'.tr(),
    tipBody: 'Today is a gift from Allah. Make the most of it with Dhikr.'.tr(),
    scheduleTime: DateTime(now.year, now.month, now.day, 10, 0),
  );

  // Daily Tasbih Report (21:00).
  final reportTime = DateTime(now.year, now.month, now.day, 21, 0);
  if (reportTime.isAfter(now)) {
    // Register a one-off task for the intelligent report
    await Workmanager().registerOneOffTask(
      'daily-tasbih-report',
      'tasbihReportTask',
      initialDelay: reportTime.difference(now),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
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
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static const String dailyExtrasTask = 'dailyExtrasTask';

  /// Registers the daily job that (re)schedules the tip + tasbih report, and
  /// cancels the retired prayer-notification job left by older versions.
  static Future<void> scheduleDailyUpdate() async {
    await Workmanager().cancelByUniqueName('daily-prayer-update');
    await Workmanager().registerPeriodicTask(
      'daily-extras-update',
      dailyExtrasTask,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  /// Manually (re)schedule today's tip + tasbih report (initial load).
  static Future<void> scheduleDailyExtrasNow() async {
    try {
      await _scheduleDailyExtras().timeout(const Duration(minutes: 2));
    } catch (e) {
      _logger.e('Error scheduling daily notifications', error: e);
    }
  }

  /// Request battery optimization exemption (Android only)
  /// This is critical for reliable background notifications.
  static Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;
    try {
      // Use AwesomeNotifications' built-in method to check/request
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    } catch (e) {
      _logger.e('Battery optimization request error', error: e);
    }
  }
}

/// Handles notification actions (when user taps notification)
class NotificationActionHandler {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Future<void> initialize() async {
    // Listen for notification actions
    await AwesomeNotifications().setListeners(
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

      if (type == 'tasbih_report') {
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

      if (type == 'planner' || type == 'worship') {
        FeatureNavigation.request(
          type == 'planner' ? AppShortcut.planner : AppShortcut.worship,
        );
        return;
      }

      if (receivedAction.buttonKeyPressed == 'OPEN_UPDATE') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const UpdateScreen()),
        );
      } else if (receivedAction.buttonKeyPressed == 'DISMISS') {
        if (receivedAction.id != null) {
          await AwesomeNotifications().cancel(receivedAction.id!);
        }
      } else if (type == 'update') {
        // Tapped update notification - Show rich details dialog
        final context = navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.8),
            builder: (_) => UpdateDetailsDialog(
              updateData: payload,
              onUpdateTap: () {
                final updateType = payload['track'];
                if (updateType == 'manual-update') {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => const UpdateScreen()),
                  );
                }
              },
            ),
          );
        }
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // No per-notification state to reset.
  }
}
