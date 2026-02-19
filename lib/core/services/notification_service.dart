import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // default icon
      [
        NotificationChannel(
          channelKey: 'prayer_times',
          channelName: 'Prayer Times',
          channelDescription: 'Notifications for prayer times and Adhan',
          defaultColor: AppTheme.primaryColor,
          ledColor: AppTheme.secondaryColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'iqama',
          channelName: 'Iqama Reminder',
          channelDescription: 'Notifications for Iqama time',
          defaultColor: AppTheme.secondaryColor,
          ledColor: AppTheme.primaryColor,
          importance: NotificationImportance.High,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
        ),
        NotificationChannel(
          channelKey: 'reminders',
          channelName: 'Daily Reminders',
          channelDescription: 'Notifications for dhikr and other reminders',
          defaultColor: AppTheme.primaryColor,
          ledColor: AppTheme.secondaryColor,
          importance: NotificationImportance.High,
          playSound: false, // We'll handle audio ourselves
          channelShowBadge: true,
          criticalAlerts: true,
          enableLights: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );
  }

  static Future<void> requestPermissions() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications(
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
    });
  }

  /// Show immediate Adhan notification (full-screen intent)
  static Future<void> showAdhanNotification(String prayerName) async {
    final localizedPrayer = prayerName.toLowerCase().tr();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'prayer_times',
        title: 'notification_adhan_title'.tr(args: [localizedPrayer]),
        body: 'notification_adhan_body'.tr(args: [localizedPrayer]),
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        backgroundColor: AppTheme.primaryColor,
        color: AppTheme.secondaryColor,
        payload: {'prayer': prayerName, 'type': 'adhan'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_ADHAN',
          label: 'open_adhan_btn'.tr(),
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'dismiss_btn'.tr(),
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }

  /// Schedule prayer notification at specific time
  static Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    Map<String, String>? payload,
  }) async {
    final localizedPrayer = prayerName.toLowerCase().tr();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'prayer_times',
        title: 'notification_adhan_title'.tr(args: [localizedPrayer]),
        body: 'notification_adhan_body'.tr(args: [localizedPrayer]),
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        payload: payload ?? {'prayer': prayerName, 'type': 'adhan'},
      ),
      schedule: NotificationCalendar(
        year: prayerTime.year,
        month: prayerTime.month,
        day: prayerTime.day,
        hour: prayerTime.hour,
        minute: prayerTime.minute,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Schedule Iqama reminder after Adhan
  static Future<void> scheduleIqamaReminder({
    required int id,
    required String prayerName,
    required DateTime iqamaTime,
  }) async {
    final localizedPrayer = prayerName.toLowerCase().tr();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'iqama',
        title: 'notification_iqama_title'.tr(),
        body: 'notification_iqama_body'.tr(args: [localizedPrayer]),
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        payload: {'prayer': prayerName, 'type': 'iqama'},
      ),
      schedule: NotificationCalendar(
        year: iqamaTime.year,
        month: iqamaTime.month,
        day: iqamaTime.day,
        hour: iqamaTime.hour,
        minute: iqamaTime.minute,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Schedule repeating dhikr reminder
  static Future<void> scheduleDhikrReminder({
    required int id,
    required String dhikrText,
    required int intervalMinutes,
    String? audioPath,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminders',
        title: 'notification_dhikr_title'.tr(),
        body: dhikrText.tr(),
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        payload: {'type': 'dhikr', 'id': id.toString(), 'audioPath': audioPath},
      ),
      schedule: NotificationInterval(
        interval: Duration(minutes: intervalMinutes),
        repeats: true,
        preciseAlarm: true,
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
}
