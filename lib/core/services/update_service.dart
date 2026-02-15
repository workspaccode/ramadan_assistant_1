import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Service for managing OTA updates via Shorebird
class UpdateService {
  final _updater = ShorebirdUpdater();

  /// Check if a patch update is available
  Future<bool> isUpdateAvailable() async {
    try {
      final status = await _updater.checkForUpdate();
      return status == UpdateStatus.outdated;
    } catch (e) {
      return false;
    }
  }

  /// Check if the app is currently running a patch
  Future<bool> isRunningPatch() async {
    try {
      final patch = await _updater.readCurrentPatch();
      return patch != null;
    } catch (e) {
      return false;
    }
  }

  /// Get the current patch number
  Future<int?> currentPatchNumber() async {
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } catch (e) {
      return null;
    }
  }

  /// Download and install the latest patch if available
  Future<void> downloadUpdate() async {
    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await _updater.update();
      }
    } catch (e) {
      // Handle or log error
    }
  }
}
