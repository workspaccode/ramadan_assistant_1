import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

    final historyEntry = {
      'title': notification?.title ?? data['title_ar'] ?? 'تحديث جديد',
      'body': notification?.body ?? data['description_ar'] ?? '',
      'type': data['type'] ?? 'auto',
      'track': data['track'] ?? 'auto-update',
      'timestamp': DateTime.now().toIso8601String(),
      'status': data['type'] == 'manual' ? 'pending' : 'applied',
      'data': data,
    };

    await prefs.addUpdateToHistory(historyEntry);
  } catch (e) {
    _logger.e('❌ Error handling background FCM message: $e');
  }
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM — request permission, get token, set up handlers
  static Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _logger.i('🔔 FCM permission: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _messaging.getToken();
      _logger.i('🔑 FCM Token: $token');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _logger.i('🔑 FCM Token refreshed: $newToken');
      });

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // When app is opened from notification tap
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpenedApp(initialMessage);
      }

      _logger.i('✅ FCM initialized successfully');
    } catch (e) {
      _logger.e('❌ FCM initialization error: $e');
    }
  }

  /// Handle foreground FCM messages
  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    _logger.i('🔔 FCM foreground message: ${message.messageId}');

    final data = message.data;
    final notification = message.notification;
    final type = data['type'] ?? 'auto';
    final track = data['track'] ?? 'auto-update';

    // Save to history
    try {
      final prefs = await PreferencesService.getInstance();
      final historyEntry = {
        'title': notification?.title ?? data['title_ar'] ?? 'تحديث جديد',
        'body': notification?.body ?? data['description_ar'] ?? '',
        'type': type,
        'track': track,
        'timestamp': DateTime.now().toIso8601String(),
        'status': type == 'manual' ? 'pending' : 'downloading',
        'data': data,
      };
      await prefs.addUpdateToHistory(historyEntry);
    } catch (e) {
      _logger.e('Error saving FCM to history: $e');
    }

    // Route to SmartUpdateManager
    final updateManager = sl<SmartUpdateManager>();
    await updateManager.handleNotification(data);

    // Show a local notification for manual updates
    if (type == 'manual') {
      await NotificationService.showUpdateNotification(
        title: notification?.title ?? data['title_ar'] ?? 'تحديث جديد متاح',
        body: notification?.body ?? data['description_ar'] ?? 'اضغط للتحديث',
        payload: data.map((k, v) => MapEntry(k, v.toString())),
      );
    }

    // Mark auto updates as applied after download
    if (type == 'auto') {
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
    _pendingNavigation = type == 'manual'
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
