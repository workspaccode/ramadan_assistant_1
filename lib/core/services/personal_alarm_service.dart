import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_event.dart';
import 'package:ramadan_assistant/features/planner/presentation/personal_alarm_screen.dart';

/// Presents only personal alarms; prayer/dhikr alarm routes remain independent.
class PersonalAlarmService {
  static StreamSubscription<AlarmSet>? _subscription;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static Future<bool> Function(int) _stopAlarm = Alarm.stop;
  static final _ringing = <int, AlarmSettings>{};
  static final _routes = <int, MaterialPageRoute<void>>{};
  static final _dismissed = <int>{};
  static bool _presentationPending = false;

  /// Call after the app's existing Alarm.init(). Extra arguments support tests.
  static Future<void> init({required GlobalKey<NavigatorState> navigatorKey,
    Stream<AlarmSet>? ringing, Future<bool> Function(int)? stopAlarm}) async {
    try { await _subscription?.cancel(); } catch (_) { /* Restore listener even if old plugin teardown fails. */ }
    _navigatorKey = navigatorKey;
    _stopAlarm = stopAlarm ?? Alarm.stop;
    _subscription = (ringing ?? Alarm.ringing).listen(_onRinging, onError: (Object error) {
      debugPrint('PersonalAlarmService: ringing stream unavailable');
    });
  }

  static void _onRinging(AlarmSet alarms) {
    final personal = {for (final alarm in alarms.alarms)
      if (isPersonalAlarmId(alarm.id)) alarm.id: alarm};
    _dismissed.removeWhere((id) => !personal.containsKey(id));
    _ringing..clear()..addAll(personal);
    for (final entry in Map<int, MaterialPageRoute<void>>.of(_routes).entries) {
      if (!personal.containsKey(entry.key)) {
        final navigator = entry.value.navigator;
        if (navigator != null && navigator.mounted) navigator.removeRoute(entry.value);
      }
    }
    _schedulePresentation();
  }

  static void _schedulePresentation() {
    if (_presentationPending) return;
    _presentationPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presentationPending = false;
      final navigator = _navigatorKey?.currentState;
      if (navigator == null || !navigator.mounted) return;
      for (final alarm in _ringing.values.toList()) {
        if (!_dismissed.contains(alarm.id) && !_routes.containsKey(alarm.id)) {
          unawaited(_present(navigator, alarm));
        }
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  static Future<bool> stop(int id) async {
    if (!isPersonalAlarmId(id)) return false;
    try {
      final stopped = await _stopAlarm(id);
      if (stopped) {
        _dismissed.add(id);
        _ringing.remove(id);
      }
      return stopped;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _present(NavigatorState navigator, AlarmSettings alarm) async {
    final route = MaterialPageRoute<void>(fullscreenDialog: true,
      builder: (_) => PersonalAlarmScreen(alarmId: alarm.id,
        title: alarm.notificationSettings.title, onStop: stop));
    _routes[alarm.id] = route;
    try {
      await navigator.push<void>(route);
    } catch (_) {
      debugPrint('PersonalAlarmService: alarm screen unavailable');
    } finally {
      if (identical(_routes[alarm.id], route)) _routes.remove(alarm.id);
      if (_ringing.containsKey(alarm.id) && !_dismissed.contains(alarm.id)) {
        _schedulePresentation();
      }
    }
  }

  static Future<void> dispose() async {
    final subscription = _subscription;
    _subscription = null;
    _navigatorKey = null;
    _ringing.clear();
    _dismissed.clear();
    try { await subscription?.cancel(); } catch (_) { /* Safe app teardown. */ }
  }
}
