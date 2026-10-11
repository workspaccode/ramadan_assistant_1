import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:awesome_notifications/awesome_notifications_platform_interface.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/core/services/personal_alarm_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/features/planner/data/document_planner_repository.dart';
import 'package:ramadan_assistant/features/planner/data/planner_platform_adapters.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_event.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_ports.dart';
import 'package:ramadan_assistant/features/planner/presentation/personal_alarm_screen.dart';

PlannerEvent _event({bool ring = false}) => PlannerEvent(id: 'family', title: 'Family appointment',
  startUtc: DateTime.utc(2030, 1, 1, 10), endUtc: DateTime.utc(2030, 1, 1, 11),
  reminderMinutes: 5, ringUntilStopped: ring, notificationId: 1000000042);

class _AlarmPort implements PlannerAlarmPort {
  final cancelled = <int>[];
  final scheduled = <PlannerEvent>[];
  @override
  Future<void> cancel(int notificationId) async { cancelled.add(notificationId); }
  @override
  Future<void> schedule(PlannerEvent event) async { scheduled.add(event); }
}

Widget _app({GlobalKey<NavigatorState>? navigatorKey, String language = 'en',
  double scale = 1, Widget? home}) => MaterialApp(navigatorKey: navigatorKey,
  locale: Locale(language), supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.getLightTheme(Locale(language)),
  builder: (context, child) {
    AppLocalizationsLookup.init(context);
    return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!);
  }, home: home ?? const Scaffold(body: Text('Home')));

AlarmSettings _alarm(int id) => AlarmSettings(id: id, dateTime: DateTime(2030, 1, 1),
  assetAudioPath: 'assets/audio/tasbih_click.wav', loopAudio: true,
  volumeSettings: VolumeSettings.fixed(volume: .65),
  notificationSettings: const NotificationSettings(title: 'Family appointment', body: 'Stop alarm'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Continuous flag round trips and old documents default to regular notification', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final store = DriftDocumentStore(database);
    final repository = DocumentPlannerRepository(store);
    addTearDown(database.close);
    final saved = await repository.save(_event(ring: true));
    expect(saved.ringUntilStopped, isTrue);
    expect(saved.withPersistence(notificationId: saved.notificationId, revision: 2).ringUntilStopped, isTrue);
    expect(saved.withDeviceLink(1, 2).ringUntilStopped, isTrue);
    final document = (await store.get(DocumentPlannerRepository.namespace, saved.id))!;
    await store.upsert(document.namespace, document.id,
      Map<String, Object?>.of(document.data)..remove('ringUntilStopped'),
      expectedRevision: document.revision);
    expect((await repository.list()).single.ringUntilStopped, isFalse);
  });

  test('Planner alarm IDs cannot collide with prayer or dhikr ranges', () {
    for (final id in [0, 1, 5, 1000, 999999999, 1500000000]) {
      expect(isPersonalAlarmId(id), isFalse);
    }
    expect(isPersonalAlarmId(1000000000), isTrue);
    expect(isPersonalAlarmId(1499999999), isTrue);
  });

  testWidgets('Plugin adapter schedules real looping settings after explicit permission', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    AlarmSettings? settings;
    var permissionRequests = 0;
    final stopped = <int>[];
    final port = PluginPlannerAlarms(setAlarm: (value) async { settings = value; return true; },
      stopAlarm: (id) async { stopped.add(id); return true; },
      getAlarm: (id) async => _alarm(id),
      requestExactPermission: () async { permissionRequests++; return true; });
    await port.schedule(_event(ring: true));
    expect(permissionRequests, 1);
    expect(settings!.loopAudio, isTrue);
    expect(settings!.allowSameSecondScheduling, isTrue);
    expect(settings!.assetAudioPath, 'assets/audio/tasbih_click.wav');
    expect(settings!.notificationSettings.stopButton, AppLocalizationsLookup.instance.planner_alarm_stop);
    expect(settings!.id, 1000000042);
    await port.cancel(settings!.id);
    expect(stopped, [1000000042]);
    final denied = PluginPlannerAlarms(setAlarm: (_) async { fail('Denied permission must not schedule'); },
      requestExactPermission: () async => false);
    await expectLater(denied.schedule(_event(ring: true)), throwsA(isA<ReminderException>()));
  });

  test('Cancelling an absent alarm is idempotent, while a known failed stop is recoverable', () async {
    var stops = 0;
    final absent = PluginPlannerAlarms(getAlarm: (_) async => null,
      stopAlarm: (_) async { stops++; return false; });
    await absent.cancel(1000000042);
    expect(stops, 0);
    final existing = PluginPlannerAlarms(getAlarm: (id) async => _alarm(id),
      stopAlarm: (_) async { stops++; return false; });
    await expectLater(existing.cancel(1000000042), throwsA(isA<ReminderException>()));
    expect(stops, 1);
  });

  testWidgets('Replacing schedules cancels both channels and normal reminders remain notifications', (tester) async {
    final originalSystem = AwesomeNotificationsPlatform.operatingSystem;
    AwesomeNotificationsPlatform.operatingSystem = 'android';
    AwesomeNotificationsPlatform.resetInstance();
    const channel = MethodChannel('awesome_notifications');
    final calls = <MethodCall>[];
    var failCancellation = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'cancelNotification' && failCancellation) throw PlatformException(code: 'cancel_failed');
      return true;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
      AwesomeNotificationsPlatform.operatingSystem = originalSystem;
      AwesomeNotificationsPlatform.resetInstance();
    });
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final alarms = _AlarmPort();
    final reminders = AwesomePlannerReminders(alarms: alarms);
    await reminders.schedule(_event(ring: true));
    expect(alarms.scheduled, hasLength(1));
    expect(calls.where((call) => call.method == 'createNewNotification'), isEmpty);
    await reminders.schedule(_event());
    expect(alarms.cancelled, [1000000042, 1000000042]);
    expect(calls.where((call) => call.method == 'createNewNotification'), hasLength(1));
    failCancellation = true;
    await expectLater(reminders.cancel(1000000042), throwsA(isA<ReminderException>()));
    expect(alarms.cancelled, hasLength(3));
  });

  testWidgets('Ringing listener ignores other ranges, dedupes, and Back stops before dismissing', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    final ringing = StreamController<AlarmSet>.broadcast();
    final stopped = <int>[];
    await tester.pumpWidget(_app(navigatorKey: navigator));
    await tester.pumpAndSettle();
    await PersonalAlarmService.init(navigatorKey: navigator, ringing: ringing.stream,
      stopAlarm: (id) async { stopped.add(id); return true; });
    final alarm = _alarm(1000000042);
    ringing.add(AlarmSet([alarm, _alarm(1), _alarm(1000)]));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalAlarmScreen), findsOneWidget);
    ringing.add(AlarmSet([alarm]));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalAlarmScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(stopped, [1000000042]);
    expect(find.byType(PersonalAlarmScreen), findsNothing);
    ringing.add(AlarmSet([alarm]));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalAlarmScreen), findsNothing);
    await PersonalAlarmService.dispose();
    await ringing.close();
    expect(tester.takeException(), isNull);
  });

  for (final language in ['ar', 'en', 'ur']) {
    testWidgets('Alarm stop failure $language remains visible and retries at320px2x', (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_app(navigatorKey: navigator, language: language, scale: 2));
      await tester.pumpAndSettle();
      var attempts = 0;
      unawaited(navigator.currentState!.push<void>(MaterialPageRoute(builder: (_) => PersonalAlarmScreen(
        alarmId: 1000000042, title: 'Family appointment', onStop: (_) async => ++attempts > 1))));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, AppLocalizationsLookup.instance.planner_alarm_stop));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalAlarmScreen), findsOneWidget);
      expect(find.text(AppLocalizationsLookup.instance.planner_alarm_stop_failed), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, AppLocalizationsLookup.instance.planner_alarm_stop));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalAlarmScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
