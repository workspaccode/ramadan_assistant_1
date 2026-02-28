import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/umrah_trip_model.dart';

class UmrahStorageService {
  final SharedPreferences _prefs;

  UmrahStorageService._(this._prefs);

  static UmrahStorageService? _instance;

  static const String _umrahHistoryKey = 'umrah_history';

  static Future<UmrahStorageService> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = UmrahStorageService._(prefs);
    return _instance!;
  }

  List<UmrahTrip> getUmrahHistory() {
    final jsonString = _prefs.getString(_umrahHistoryKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final list = jsonDecode(jsonString) as List;
      return list
          .map((e) => UmrahTrip.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        // Sort by start date descending
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUmrahTrip(UmrahTrip trip) async {
    final history = getUmrahHistory();
    final index = history.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      history[index] = trip;
    } else {
      history.add(trip);
    }
    await _saveHistory(history);
  }

  Future<void> _saveHistory(List<UmrahTrip> history) async {
    final jsonList = history.map((t) => t.toJson()).toList();
    await _prefs.setString(_umrahHistoryKey, jsonEncode(jsonList));
  }

  UmrahTrip? getActiveTrip() {
    final history = getUmrahHistory();
    try {
      return history.firstWhere((t) => t.status == 'in_progress');
    } catch (_) {
      return null;
    }
  }

  Future<void> startNewTrip(DateTime date) async {
    // If there's already an active trip, maybe we shouldn't overwrite? Or we ask user.
    // For now we just create a new one.
    final trip = UmrahTrip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: date,
      status: 'in_progress',
    );
    await saveUmrahTrip(trip);
  }

  Future<void> completeActiveTrip() async {
    final activeTrip = getActiveTrip();
    if (activeTrip != null) {
      final completedTrip = activeTrip.copyWith(
        endDate: DateTime.now(),
        status: 'completed',
      );
      await saveUmrahTrip(completedTrip);
    }
  }
}
