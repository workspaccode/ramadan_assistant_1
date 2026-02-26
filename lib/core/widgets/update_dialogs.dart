import 'package:flutter/material.dart';

/// Show an update dialog with changelog details
/// Returns true if user chose to update
Future<bool> showUpdateDialog(
  BuildContext context, {
  required String title,
  required String description,
  required List<String> changelog,
  required int sizeInMB,
  bool isOptional = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: isOptional,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
              ),
              if (changelog.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'ما الجديد:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...changelog.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (sizeInMB > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'الحجم: $sizeInMB MB',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (isOptional)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لاحقاً'),
            ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('تحديث الآن'),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// Show a force update dialog — cannot be dismissed
Future<void> showForceUpdateDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'تحديث إلزامي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'يوجد تحديث أمني مهم. سيتم تحميل التحديث الآن.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('حسناً'),
          ),
        ],
      ),
    ),
  );
}

/// Show progress dialog while downloading
Future<void> showProgressDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onCancel,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: onCancel != null
            ? [
                TextButton(
                  onPressed: () {
                    onCancel();
                    Navigator.pop(context);
                  },
                  child: const Text('إلغاء'),
                ),
              ]
            : null,
      ),
    ),
  );
}

/// Show restart dialog after successful download
Future<void> showRestartDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt, color: Colors.teal, size: 28),
            SizedBox(width: 12),
            Text('إعادة تشغيل'),
          ],
        ),
        content: const Text(
          'تم تحميل التحديث بنجاح. يجب إعادة تشغيل التطبيق لتطبيق التحديث.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إعادة التشغيل'),
          ),
        ],
      ),
    ),
  );
}

/// Show "no update available" dialog
Future<void> showNoUpdateDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('لا يوجد تحديث'),
          ],
        ),
        content: const Text(
          'أنت تستخدم أحدث إصدار من التطبيق ✅',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    ),
  );
}

/// Show error dialog
Future<void> showErrorDialog(BuildContext context, String error) async {
  await showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text('خطأ'),
          ],
        ),
        content: Text(error, style: const TextStyle(fontSize: 14)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    ),
  );
}

/// Show update complete dialog with optional restart
Future<void> showUpdateCompleteDialog(
  BuildContext context,
  String updateTitle,
) async {
  await showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text('تم التحديث بنجاح! 🎉'),
          ],
        ),
        content: Text(
          'تم تحميل "$updateTitle" بنجاح.\nأعد تشغيل التطبيق لتطبيق التغييرات.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // The caller should handle app restart
            },
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('إعادة التشغيل'),
          ),
        ],
      ),
    ),
  );
}
