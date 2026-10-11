import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';

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
                        '${'size_label'.tr()}: $sizeInMB MB',
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
              child: Text('later'.tr()),
            ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.download, size: 18),
            label: Text('update_now_btn'.tr()),
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
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'mandatory_update'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'mandatory_update_desc'.tr(),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('ok'.tr()),
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
                  child: Text('cancel'.tr()),
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
        title: Row(
          children: [
            const Icon(Icons.restart_alt, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Text('restart'.tr()),
          ],
        ),
        content: Text(
          'update_downloaded_restart'.tr(),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('restart'.tr()),
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
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text('no_update_found'.tr()),
          ],
        ),
        content: Text(
          'latest_version_msg'.tr(),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
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
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            Text('error_occurred'.tr()),
          ],
        ),
        content: Text(error, style: const TextStyle(fontSize: 14)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
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
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Text('update_completed'.tr()),
          ],
        ),
        content: Text(
          'update_complete_msg'.tr(namedArgs: {'title': updateTitle}),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('later'.tr()),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // The caller should handle app restart
            },
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text('restart'.tr()),
          ),
        ],
      ),
    ),
  );
}
