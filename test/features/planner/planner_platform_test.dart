import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/features/planner/data/planner_platform_adapters.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_event.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_ports.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test.planner/calendar');
  const port = AndroidDeviceCalendarPort(channel: channel);
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test(
    'Device adapter decodes account/write access and sends UTC instants/local id',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return switch (call.method) {
              'calendar.list' => [
                {
                  'id': 7,
                  'name': 'Work',
                  'account': 'Local account',
                  'writable': false,
                },
              ],
              'calendar.create' => 81,
              _ => null,
            };
          });
      final calendars = await port.connect();
      expect(calendars.single.account, 'Local account');
      expect(calendars.single.writable, isFalse);
      final event = PlannerEvent(
        id: 'local',
        title: 'Call',
        startUtc: DateTime.utc(2030, 1, 1, 10),
        endUtc: DateTime.utc(2030, 1, 1, 11),
      );
      expect(await port.create(7, event), 81);
      expect((calls.last.arguments as Map)['localId'], 'local');
      expect(
        (calls.last.arguments as Map)['start'],
        event.startUtc.millisecondsSinceEpoch,
      );
    },
  );

  test('Calendar permission failure reaches a typed recovery state', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          throw PlatformException(code: 'calendar_permission_denied');
        });
    await expectLater(
      port.connect(),
      throwsA(
        isA<CalendarException>().having(
          (error) => error.problem,
          'problem',
          CalendarProblem.permission,
        ),
      ),
    );
  });
}
