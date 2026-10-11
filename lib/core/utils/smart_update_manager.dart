import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ramadan_assistant/core/models/update_models.dart';
import 'package:ramadan_assistant/core/services/preferences_service.dart';
import 'package:ramadan_assistant/core/widgets/update_dialogs.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart' as shorebird;

class SmartUpdateManager {
  final _shorebird = shorebird.ShorebirdUpdater();
  final _remoteConfig = FirebaseRemoteConfig.instance;
  final _logger = Logger();
  PreferencesService? _preferences;

  static const String _updatesConfigKey = 'shorebird_updates';
  static const String _lastUpdateCheckKey = 'last_update_check';
  static const Duration _checkInterval = Duration(hours: 1);

  Future<void> initialize() async {
    try {
      _logger.i('🚀 Initializing Smart Update Manager...');

      // Initialize PreferencesService
      _preferences = await PreferencesService.getInstance();

      // Initialize Remote Config
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Set default values
      await _remoteConfig.setDefaults({
        _updatesConfigKey: jsonEncode({
          'patch_v3.3.7': {
            'type': 'auto',
            'priority': 'low',
            'title_ar': 'تحسينات في الأداء',
            'description_ar': 'إصلاح بعض الأخطاء وتحسين استهلاك البطارية',
            'changelog_ar': ['تحسين استهلاك البطارية', 'إصلاح مشكلة الاتصال'],
            'force_update': false,
            'min_required_version': '3.3.0',
            'size_in_mb': 2,
          },
        }),
      });

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      _logger.i('✅ Smart Update Manager initialized successfully');
    } catch (e) {
      _logger.e('❌ Failed to initialize Smart Update Manager: $e');
    }
  }

  Future<void> checkCriticalUpdates(BuildContext context) async {
    try {
      _logger.i('🔍 Checking critical updates...');

      final status = await _checkShorebirdUpdate(UpdateTrack.criticalUpdate);

      if (status.isUpdateAvailable && status.isCritical) {
        _logger.w('⚠️ Critical update available! Forcing update...');
        if (context.mounted) {
          await _showForceUpdateDialog(context);
        }
        await _shorebird.update(
          track: shorebird.UpdateTrack(UpdateTrack.criticalUpdate.trackId),
        );

        // Ask the user to restart the app themselves — never exit(0):
        // a hard process kill mid-session is jarring and can look like a
        // crash to Android's app-not-responding / crash reporting.
        if (context.mounted) {
          await _showRestartDialog(context);
        }
      }
    } catch (e) {
      _logger.e('❌ Error checking critical updates: $e');
    }
  }

  bool _checkIsRunning = false;

  Future<void> handleNotification(Map<String, dynamic> data) async {
    final trackName = data['track'] as String?;
    final force = data['force'] == 'true';

    _logger.i(
      '🔔 Handling update notification for track: $trackName, force: $force',
    );

    if (_checkIsRunning) {
      _logger.w(
        '⚠️ Update check already in progress, skipping notification trigger.',
      );
      return;
    }

    if (trackName != null) {
      if (trackName == 'auto-update') {
        await checkAutoUpdates();
      } else if (trackName == 'manual-update') {
        _logger.w(
          '⚠️ Manual update triggered via notification without context. Skipping UI.',
        );
        await _checkShorebirdUpdate(UpdateTrack.manualUpdate);
      } else {
        _logger.i('Checking custom track: $trackName');
        final status = await _checkShorebirdUpdate(UpdateTrack.manualUpdate);
        if (status.isUpdateAvailable) {
          _logger.i('Update available on $trackName');
          if (data['download'] == 'true') {
            await _shorebird.update(track: shorebird.UpdateTrack(trackName));
          }
        }
      }
    } else {
      await checkAutoUpdates();
    }
  }

  Future<void> checkAutoUpdates() async {
    // Skip auto-updates in debug mode to prevent crashes
    if (kDebugMode) return;

    if (_checkIsRunning) return;
    _checkIsRunning = true;

    try {
      _logger.i('🔄 Checking auto updates...');

      // Check if enough time passed since last check
      final lastCheck = _preferences?.getLastUpdateCheck();
      if (lastCheck != null &&
          DateTime.now().difference(lastCheck) < _checkInterval) {
        _logger.d('⏰ Skipping auto update check - too soon');
        return;
      }

      // Add timeout to prevent hanging
      final status = await _checkShorebirdUpdate(
        UpdateTrack.autoUpdate,
      ).timeout(const Duration(seconds: 30));

      // Relaxed condition: Allow update if metadata is null OR if type is auto
      // This ensures that even if Remote Config is not set up for this specific patch,
      // the 'auto-update' track still receives the patch.
      if (status.isUpdateAvailable &&
          (status.metadata == null ||
              status.metadata?.type == UpdateType.auto)) {
        _logger.i('📥 Auto update available, downloading...');
        await _shorebird
            .update(
              track: shorebird.UpdateTrack(UpdateTrack.autoUpdate.trackId),
            )
            .timeout(const Duration(minutes: 2));
        _preferences?.saveLastUpdateCheck(DateTime.now());
        _logger.i('✅ Auto update downloaded successfully');
      }

      _preferences?.saveLastUpdateCheck(DateTime.now());
    } catch (e) {
      _logger.e('❌ Error checking auto updates: $e');
    } finally {
      _checkIsRunning = false;
    }
  }

  Future<void> checkManualUpdates(BuildContext context) async {
    try {
      _logger.i('👤 Checking manual updates...');

      // Get metadata from Remote Config
      final metadata = await _getUpdateMetadataFromRemoteConfig();

      if (metadata != null) {
        final status = await _checkShorebirdUpdate(UpdateTrack.manualUpdate);

        if (status.isUpdateAvailable) {
          if (!context.mounted) return;
          final shouldUpdate = await _showUpdateDialog(
            context,
            metadata: metadata,
            isOptional: metadata.type == UpdateType.optional,
          );

          if (shouldUpdate && context.mounted) {
            await _downloadAndShowProgress(context, metadata);
          }
        } else {
          if (context.mounted) {
            await _showNoUpdateDialog(context);
          }
        }
      }
    } catch (e) {
      _logger.e('❌ Error checking manual updates: $e');
      if (context.mounted) {
        await _showErrorDialog(context, e.toString());
      }
    }
  }

  Future<UpdateStatus> _checkShorebirdUpdate(UpdateTrack track) async {
    try {
      final shorebirdStatus = await _shorebird.checkForUpdate(
        track: shorebird.UpdateTrack(track.trackId),
      );

      if (shorebirdStatus == shorebird.UpdateStatus.upToDate) {
        return UpdateStatus(isUpdateAvailable: false);
      }

      // Get current version info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get metadata from Remote Config
      final metadata = await _getUpdateMetadataFromRemoteConfig();

      return UpdateStatus(
        isUpdateAvailable: true,
        metadata: metadata,
        currentVersion: currentVersion,
        availableVersion: metadata?.patchVersion,
        isCritical:
            metadata?.type == UpdateType.critical ||
            metadata?.forceUpdate == true,
      );
    } catch (e) {
      _logger.e('❌ Error checking Shorebird update: $e');
      return UpdateStatus(isUpdateAvailable: false);
    }
  }

  Future<UpdateMetadata?> _getUpdateMetadataFromRemoteConfig() async {
    try {
      final updatesJson = _remoteConfig.getString(_updatesConfigKey);
      if (updatesJson.trim().isEmpty) {
        _logger.d('ℹ️ Remote config updates JSON is empty');
        return null;
      }

      final updates = jsonDecode(updatesJson);
      if (updates is! Map<String, dynamic> || updates.isEmpty) {
        _logger.d('ℹ️ Remote config updates is not a valid non-empty Map');
        return null;
      }

      // Get the latest patch
      final latestPatchKey = updates.keys.last;
      final patchData = updates[latestPatchKey];

      if (patchData is! Map<String, dynamic>) {
        _logger.w('⚠️ Patch data for $latestPatchKey is not a Map');
        return null;
      }

      // Ensure patch_version is present or use key as fallback
      if (!patchData.containsKey('patch_version')) {
        patchData['patch_version'] = latestPatchKey;
      }

      return UpdateMetadata.fromJson(patchData);
    } catch (e) {
      _logger.e('❌ Error getting update metadata from Remote Config: $e');
      return null;
    }
  }

  Future<void> _downloadAndShowProgress(
    BuildContext context,
    UpdateMetadata metadata,
  ) async {
    await showProgressDialog(
      context,
      title: '🔄 جاري التحديث',
      message: metadata.descriptionAr,
      onCancel: () {},
    );

    try {
      await _shorebird.update(
        track: shorebird.UpdateTrack(UpdateTrack.manualUpdate.trackId),
      );

      if (context.mounted) {
        await _showUpdateCompleteDialog(context, metadata);
      }
    } catch (e) {
      _logger.e('❌ Error downloading update: $e');
      if (context.mounted) {
        await _showErrorDialog(context, 'فشل تحميل التحديث: ${e.toString()}');
      }
    }
  }

  Future<bool> _showUpdateDialog(
    BuildContext context, {
    required UpdateMetadata metadata,
    bool isOptional = false,
  }) async {
    return await showUpdateDialog(
      context,
      title: metadata.titleAr,
      description: metadata.descriptionAr,
      changelog: metadata.changelogAr,
      sizeInMB: metadata.sizeInMB,
      isOptional: isOptional,
    );
  }

  Future<void> _showForceUpdateDialog(BuildContext context) async {
    await showForceUpdateDialog(context);
  }

  Future<void> _showRestartDialog(BuildContext context) async {
    await showRestartDialog(context);
  }

  Future<void> _showNoUpdateDialog(BuildContext context) async {
    await showNoUpdateDialog(context);
  }

  Future<void> _showErrorDialog(BuildContext context, String error) async {
    await showErrorDialog(context, error);
  }

  Future<void> _showUpdateCompleteDialog(
    BuildContext context,
    UpdateMetadata metadata,
  ) async {
    await showUpdateCompleteDialog(context, metadata.titleAr);
  }

  // Method to get current update status for UI
  Future<UpdateStatus> getCurrentUpdateStatus() async {
    return await _checkShorebirdUpdate(UpdateTrack.manualUpdate);
  }

  // Method to clear update cache (for testing)
  Future<void> clearUpdateCache() async {
    _preferences?.remove(_lastUpdateCheckKey);
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }
}
