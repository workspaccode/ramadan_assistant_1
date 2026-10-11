import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/preferences_service.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';

final _logger = Logger();

/// Top-level background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _logger.i('🔔 FCM background message: ${message.messageId}');

  // Store the notification in history
  try {
    final prefs = await PreferencesService.getInstance();
    final data = message.data;
    final notification = message.notification;

    final type = data['type'] ?? 'general';
    final track = data['track'] ?? 'auto-update';

    String category = data['category'] ?? 'general';
    if (type == 'update') {
      category = track == 'manual-update' ? 'manual_update' : 'instant_update';
    }

    final historyEntry = {
      'title':
          notification?.title ??
          data['title_ar'] ??
          data['title'] ??
          'إشعار جديد',
      'body':
          notification?.body ?? data['description_ar'] ?? data['body'] ?? '',
      'type': type,
      'track': track,
      'category': category,
      'version': data['version'] ?? '',
      'patch': data['patch'] ?? '',
      'features_en': data['features_en'] ?? '',
      'features_ar': data['features_ar'] ?? '',
      'features_ur': data['features_ur'] ?? '',
      'fixes_en': data['fixes_en'] ?? '',
      'fixes_ar': data['fixes_ar'] ?? '',
      'fixes_ur': data['fixes_ur'] ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      'status': (type == 'update' && track == 'manual-update')
          ? 'pending'
          : 'applied',
      'data': data,
    };

    await prefs.addUpdateToHistory(historyEntry);
  } catch (e) {
    _logger.e('❌ Error handling background FCM message: $e');
  }
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _handlersRegistered = false;

  /// Initialize FCM — set up handlers + token.
  ///
  /// NOTE: Notification permission is intentionally NOT requested here.
  /// Asking before the first frame violates Google Play UX guidance
  /// (permissions must be requested in context). The request happens in
  /// PermissionFlow.requestCorePermissions() from the home screen, after a
  /// rationale dialog the user can decline.
  static Future<void> initialize() async {
    try {
      // Network/token failures must not prevent local message handlers.
      if (!_handlersRegistered) {
        _messaging.onTokenRefresh.listen(
          (newToken) => _logger.i('🔑 FCM Token refreshed: $newToken'),
          onError: (Object error, StackTrace stackTrace) => _logger.e(
            'FCM token refresh failed',
            error: error,
            stackTrace: stackTrace,
          ),
        );
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
        FirebaseMessaging.onMessage.listen(
          (message) => unawaited(_handleForegroundMessage(message)),
          onError: (Object error, StackTrace stackTrace) => _logger.e(
            'FCM message stream failed',
            error: error,
            stackTrace: stackTrace,
          ),
        );
        FirebaseMessaging.onMessageOpenedApp.listen(
          _onMessageOpenedApp,
          onError: (Object error, StackTrace stackTrace) => _logger.e(
            'FCM notification tap stream failed',
            error: error,
            stackTrace: stackTrace,
          ),
        );
        _handlersRegistered = true;
      }

      // Check (don't request) current authorization status
      final settings = await _messaging.getNotificationSettings();
      _logger.i('🔔 FCM authorization status: ${settings.authorizationStatus}');

      // Get FCM token (works regardless of notification permission on Android)
      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpenedApp(initialMessage);
      }

      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 10),
      );
      _logger.i('🔑 FCM Token: $token');

      _logger.i('✅ FCM initialized successfully');
    } catch (e) {
      _logger.e('❌ FCM initialization error: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      await _onForegroundMessage(message);
    } catch (error, stackTrace) {
      // Stream.listen does not await async callbacks; report their failures.
      _logger.e(
        'FCM foreground message failed: ${message.messageId}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle foreground FCM messages
  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    _logger.i('🔔 FCM foreground message: ${message.messageId}');

    final data = message.data;
    final notification = message.notification;
    final type = data['type'] ?? 'general';
    final track = data['track'] ?? 'auto-update';

    String category = data['category'] ?? 'general';
    if (type == 'update') {
      category = track == 'manual-update' ? 'manual_update' : 'instant_update';
    }

    // Save to history
    try {
      final prefs = await PreferencesService.getInstance();
      final historyEntry = {
        'title':
            notification?.title ??
            data['title_ar'] ??
            data['title'] ??
            'إشعار جديد',
        'body':
            notification?.body ?? data['description_ar'] ?? data['body'] ?? '',
        'type': type,
        'track': track,
        'category': category,
        'version': data['version'] ?? '',
        'patch': data['patch'] ?? '',
        'features_en': data['features_en'] ?? '',
        'features_ar': data['features_ar'] ?? '',
        'features_ur': data['features_ur'] ?? '',
        'fixes_en': data['fixes_en'] ?? '',
        'fixes_ar': data['fixes_ar'] ?? '',
        'fixes_ur': data['fixes_ur'] ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'status': (type == 'update' && track == 'manual-update')
            ? 'pending'
            : 'downloading',
        'data': data,
      };
      await prefs.addUpdateToHistory(historyEntry);
    } catch (e) {
      _logger.e('Error saving FCM to history: $e');
    }

    // Route to SmartUpdateManager
    final updateManager = sl<SmartUpdateManager>();
    await updateManager.handleNotification(data);

    // Show a local notification for manual updates or non-update categories
    if ((type == 'update' && track == 'manual-update') || type != 'update') {
      await NotificationService.showUpdateNotification(
        title:
            notification?.title ??
            data['title_ar'] ??
            data['title'] ??
            'إشعار جديد',
        body:
            notification?.body ?? data['description_ar'] ?? data['body'] ?? '',
        payload: data.map((k, v) => MapEntry(k, v.toString())),
      );
    }

    // Mark auto updates as applied after download
    if (type == 'update' && track != 'manual-update') {
      try {
        final prefs = await PreferencesService.getInstance();
        await prefs.markLastUpdateApplied();
      } catch (_) {}
    }
  }

  /// Handle notification tap — navigate to appropriate screen
  static void _onMessageOpenedApp(RemoteMessage message) {
    _logger.i('🔔 FCM notification tapped: ${message.messageId}');

    final data = message.data;
    final type = data['type'] ?? 'auto';

    // Navigation will be handled by NotificationActionHandler
    // We store the pending navigation so the handler can pick it up
    _pendingNavigation = (type == 'update' && data['track'] == 'manual-update')
        ? 'update_screen'
        : 'notifications_screen';
  }

  /// Pending navigation target from notification tap
  static String? _pendingNavigation;

  /// Consume and return the pending navigation (if any)
  static String? consumePendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
  }

  /// Get the current FCM token
  static Future<String?> getToken() => _messaging.getToken();

  /// Subscribe to a topic (e.g., 'updates')
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    _logger.i('📢 Subscribed to FCM topic: $topic');
  }
}
