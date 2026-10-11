import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/services/adhan_alarm_service.dart';

class _Navigator implements NavigatorState {
  final routes = <Completer<void>>[];
  bool failNext = false;
  @override
  bool get mounted => true;
  @override
  Future<T?> push<T extends Object?>(Route<T> route) {
    if (failNext) {
      failNext = false;
      throw StateError('navigation failed');
    }
    final completion = Completer<void>();
    routes.add(completion);
    return completion.future.then<T?>((_) => null);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      '_Navigator';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(AdhanAlarmService.markAdhanScreenClosed);
  test('Local clock and scheduled trigger share one active route', () async {
    final navigator = _Navigator();
    final first = AdhanAlarmService.presentAdhan(navigator, prayerName: 'Fajr');
    await AdhanAlarmService.presentAdhan(navigator, prayerName: 'Fajr');
    expect(navigator.routes, hasLength(1));
    navigator.routes.first.complete();
    await first;
    final next = AdhanAlarmService.presentAdhan(navigator, prayerName: 'Dhuhr');
    expect(navigator.routes, hasLength(2));
    navigator.routes.last.complete();
    await next;
  });
  test('Navigation failure releases presentation guard', () async {
    final navigator = _Navigator()..failNext = true;
    await AdhanAlarmService.presentAdhan(navigator, prayerName: 'Fajr');
    final retry = AdhanAlarmService.presentAdhan(navigator, prayerName: 'Fajr');
    expect(navigator.routes, hasLength(1));
    navigator.routes.single.complete();
    await retry;
  });
  test('Dhikr and unrelated alarms cannot open the Adhan screen', () {
    for (var id = 1; id <= 5; id++) {
      expect(AdhanAlarmService.isPrayerAlarmId(id), true);
    }
    for (final id in [0, 6, 100, 3001]) {
      expect(AdhanAlarmService.isPrayerAlarmId(id), false);
    }
  });
}
