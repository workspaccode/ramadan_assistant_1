import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A thin wrapper around SharedPreferences for the update manager
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService._(this._prefs);

  static PreferencesService? _instance;

  static const String _updateHistoryKey = 'update_history';

  /// Get the singleton instance
  static Future<PreferencesService> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = PreferencesService._(prefs);
    return _instance!;
  }

  /// Get the last time an update check was performed
  DateTime? getLastUpdateCheck() {
    final millis = _prefs.getInt('last_update_check');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Save the timestamp of the latest update check
  Future<void> saveLastUpdateCheck(DateTime dateTime) async {
    await _prefs.setInt('last_update_check', dateTime.millisecondsSinceEpoch);
  }

  /// Remove a specific key from preferences
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // ── Update History ──────────────────────────────────────────────

  /// Get the stored update notification history
  List<Map<String, dynamic>> getUpdateHistory() {
    final json = _prefs.getString(_updateHistoryKey);
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Add an update notification entry to history
  Future<void> addUpdateToHistory(Map<String, dynamic> entry) async {
    final history = getUpdateHistory();
    history.add(entry);
    // Keep only last 50 entries
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }
    await _prefs.setString(_updateHistoryKey, jsonEncode(history));
  }

  /// Mark the last update entry as applied
  Future<void> markLastUpdateApplied() async {
    final history = getUpdateHistory();
    if (history.isNotEmpty) {
      history.last['status'] = 'applied';
      await _prefs.setString(_updateHistoryKey, jsonEncode(history));
    }
  }

  /// Clear all update history
  Future<void> clearUpdateHistory() async {
    await _prefs.remove(_updateHistoryKey);
  }

  /// Get count of pending (manual) updates
  int getPendingUpdateCount() {
    return getUpdateHistory().where((e) => e['status'] == 'pending').length;
  }
}
