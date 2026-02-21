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
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          soundSource: 'resource://raw/adhan_regular',
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'prayer_times_fajr',
          channelName: 'Fajr Adhan',
          channelDescription: 'Fajr prayer adhan notification',
          defaultColor: AppTheme.primaryColor,
          ledColor: AppTheme.secondaryColor,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          soundSource: 'resource://raw/adhan_fajr',
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'iqama',
          channelName: 'Iqama Reminder',
          channelDescription: 'Notifications for Iqama time',
          defaultColor: AppTheme.secondaryColor,
          ledColor: AppTheme.primaryColor,
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          soundSource: 'resource://raw/iqama_sound',
          playSound: true,
          criticalAlerts: true,
          locked: true,
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
        NotificationChannel(
          channelKey: 'islamic_tips',
          channelName: 'Islamic Facts & Tips',
          channelDescription: 'Daily educational Islamic facts',
          defaultColor: AppTheme.primaryColor,
          importance: NotificationImportance.Default,
        ),
        NotificationChannel(
          channelKey: 'daily_reports',
          channelName: 'Daily Progress Reports',
          channelDescription: 'Summary of your daily worship performance',
          importance: NotificationImportance.High,
          defaultColor: AppTheme.secondaryColor,
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
    final isFajr = prayerName.toLowerCase() == 'fajr';
    final channelKey = isFajr ? 'prayer_times_fajr' : 'prayer_times';
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: channelKey,
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
    final isFajr = prayerName.toLowerCase() == 'fajr';
    final channelKey = isFajr ? 'prayer_times_fajr' : 'prayer_times';
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: 'notification_adhan_title'.tr(args: [localizedPrayer]),
        body: 'notification_adhan_body'.tr(args: [localizedPrayer]),
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        payload: payload ?? {'prayer': prayerName, 'type': 'adhan'},
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
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        payload: {'prayer': prayerName, 'type': 'iqama'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'dismiss_btn'.tr(),
          actionType: ActionType.DismissAction,
        ),
      ],
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

  /// Schedule Wird reminder after prayer
  static Future<void> scheduleWirdReminder({
    required int id,
    required String prayerName,
    required DateTime reminderTime,
    required int pages,
  }) async {
    final localizedPrayer = prayerName.toLowerCase().tr();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'reminders',
        title: 'Daily Wird Reminder'.tr(),
        body: 'Do not forget to read your {} pages for {}'.tr(
          args: ['$pages', localizedPrayer],
        ),
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        payload: {'type': 'wird', 'prayer': prayerName},
      ),
      schedule: NotificationCalendar(
        year: reminderTime.year,
        month: reminderTime.month,
        day: reminderTime.day,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  static Future<void> schedulePrayerNearing({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    final localizedPrayer = prayerName.toLowerCase().tr();
    final nearingTime = prayerTime.subtract(const Duration(minutes: 10));

    if (nearingTime.isBefore(DateTime.now())) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id + 500, // Offset for nearing
        channelKey: 'prayer_times',
        title: 'اقتراب وقت الصلاة'.tr(),
        body: 'بقي 10 دقائق على صلاة {}'.tr(args: [localizedPrayer]),
        category: NotificationCategory.Reminder,
        payload: {'type': 'nearing', 'prayer': prayerName},
      ),
      schedule: NotificationCalendar(
        year: nearingTime.year,
        month: nearingTime.month,
        day: nearingTime.day,
        hour: nearingTime.hour,
        minute: nearingTime.minute,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Schedule a daily Islamic tip
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
}
