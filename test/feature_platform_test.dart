import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/platform/feature_platform.dart';
import 'package:ramadan_assistant/features/worship/data/android_worship_adapters.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.tawabti/features');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    FeatureNavigation.pending.value = null;
  });

  test('unsupported platform leaves local features usable', () async {
    final platform = FeaturePlatform();
    addTearDown(platform.dispose);
    expect(await platform.initialize(), isNull);
    expect(await platform.canPin(), isFalse);
  });

  test(
    'launch shortcut is validated and pin success means only request accepted',
    () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return switch (call.method) {
          'shortcuts.initial' => 'planner',
          'shortcuts.supported' || 'shortcuts.pin' => true,
          _ => null,
        };
      });
      final platform = FeaturePlatform();
      addTearDown(platform.dispose);
      expect(await platform.initialize(), AppShortcut.planner);
      expect(await platform.canPin(), isTrue);
      expect(await platform.requestPin(AppShortcut.tasbih, 'Tasbih'), isTrue);
      expect(calls.last.arguments, {'id': 'tasbih', 'label': 'Tasbih'});
    },
  );

  test('unknown shortcut never triggers navigation', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => 'unknown');
    final platform = FeaturePlatform();
    addTearDown(platform.dispose);
    expect(await platform.initialize(), isNull);
  });

  test(
    'reader catalog and failed launch are represented without recording reading',
    () async {
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => switch (call.method) {
          'reader.apps' => [
            {'packageName': 'com.reader', 'label': 'Reader'},
          ],
          'reader.open' => false,
          _ => null,
        },
      );
      const reader = AndroidQuranReader();
      expect((await reader.availableApps()).single.id, 'com.reader');
      expect(await reader.open(appId: 'com.reader', page: 30), isFalse);
    },
  );

  test('notification destination is retained while app is not ready', () {
    FeatureNavigation.request(AppShortcut.worship);
    expect(FeatureNavigation.pending.value, AppShortcut.worship);
  });
}
