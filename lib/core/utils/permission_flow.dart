import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Requests location + notification permissions in-context, with a rationale
/// dialog shown first.
///
/// Google Play UX guidance: never trigger system permission prompts at cold
/// start — explain the value to the user and let them opt in. This flow:
///   1. (first launch only) shows a rationale dialog with Allow / Skip;
///   2. if allowed, requests location (needed for prayer times);
///   3. then requests notifications (needed for planner / wird reminders).
///
/// Users who decline are never nagged again — they can grant permissions later
/// from system Settings.
class PermissionFlow {
  static const String _rationaleShownKey = 'permission_rationale_shown';

  /// Call once after the home screen's first frame (NOT in main()).
  static Future<bool> requestCorePermissions(BuildContext context) async {
    try {
      return await _requestCorePermissions(context);
    } catch (error) {
      debugPrint('PermissionFlow: permission check failed: $error');
      return false;
    }
  }

  static Future<bool> _requestCorePermissions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final rationaleShown = prefs.getBool(_rationaleShownKey) ?? false;

    if (!rationaleShown) {
      await prefs.setBool(_rationaleShownKey, true);
      if (!context.mounted) return false;
      final proceed = await _showRationaleDialog(context);
      if (!proceed || !context.mounted) return false;
    } else {
      // Automatic home entry only checks existing grants; it never re-prompts
      // someone who has already seen the rationale or chosen to skip.
      return (await Permission.location.status).isGranted;
    }

    // --- Location (prayer times) ---
    var locationStatus = await Permission.location.status;
    if (!context.mounted) return false;
    if (locationStatus.isDenied) {
      locationStatus = await Permission.location.request();
      // "permanently denied" users are handled by the relevant screens
      // (Prayer Times shows its own guidance); no nagging here.
    }
    if (!context.mounted) return locationStatus.isGranted;

    // --- Notifications (planner / wird reminders) ---
    final notifStatus = await Permission.notification.status;
    if (notifStatus.isDenied) {
      await Permission.notification.request();
    }
    return locationStatus.isGranted;
  }

  static Future<bool> _showRationaleDialog(BuildContext context) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('permissions_rationale_title'.tr()),
        content: Text('permissions_rationale_body'.tr()),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('skip_for_now'.tr()),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('got_it_continue'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
