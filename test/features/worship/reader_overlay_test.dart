import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/features/worship/data/android_worship_adapters.dart';
import 'package:ramadan_assistant/features/worship/data/worship_codec.dart';
import 'package:ramadan_assistant/features/worship/data/worship_repository.dart';
import 'package:ramadan_assistant/features/worship/domain/worship_models.dart';
import 'package:ramadan_assistant/features/worship/domain/worship_ports.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_cubit.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_screen.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_strings.dart';

class _Reader implements QuranReaderPort {
  _Reader({this.opens = true});
  final bool opens;
  final opened = <String>[];
  @override
  Future<List<QuranReaderApp>> availableApps() async => [
    const QuranReaderApp(id: 'reader', label: 'Quran'),
  ];
  @override
  Future<bool> open({required String appId, required int page}) async {
    opened.add(appId);
    return opens;
  }
}

class _Overlay implements ReaderOverlayPort {
  _Overlay({this.canDraw = true, this.usageAccess = false});
  bool canDraw;
  bool usageAccess;
  bool pendingDone = false;
  bool throwOnShow = false;
  final shown = <ReaderOverlayRequest>[];
  var hides = 0;
  @override
  Future<OverlayStatus> status() async =>
      OverlayStatus(canDraw: canDraw, usageAccess: usageAccess);
  @override
  Future<void> openOverlaySettings() async {}
  @override
  Future<void> openUsageSettings() async {}
  @override
  Future<bool> show(ReaderOverlayRequest request) async {
    if (throwOnShow) throw PlatformException(code: 'x');
    shown.add(request);
    return true;
  }

  @override
  Future<void> hide() async => hides++;
  @override
  Future<bool> takePendingDone() async {
    final value = pendingDone;
    pendingDone = false;
    return value;
  }
}

const _copy = ReaderOverlayCopy(
  title: 'Wird',
  body: 'Pages 1-2',
  doneLabel: 'Done',
  closeLabel: 'Close',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late WorshipRepository repository;
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = WorshipRepository(DriftDocumentStore(database));
  });
  tearDown(() => database.close());

  Future<WorshipCubit> cubit(
    _Reader reader,
    _Overlay overlay, {
    bool enabled = true,
    bool autoHide = true,
  }) async {
    await repository.savePlan(
      WirdPlan(
        dailyPages: 2,
        nextPage: 1,
        readerAppId: 'reader',
        overlayEnabled: enabled,
        overlayAutoHide: autoHide,
      ),
    );
    final value = WorshipCubit(repository, readers: reader, overlays: overlay);
    addTearDown(value.close);
    await value.load();
    return value;
  }

  test('plan codec keeps overlay flags and defaults old plans to off', () {
    const plan = WirdPlan(
      dailyPages: 2,
      nextPage: 3,
      overlayEnabled: true,
      overlayAutoHide: true,
    );
    final back = WorshipCodec.readPlan(WorshipCodec.plan(plan));
    expect(back.overlayEnabled, isTrue);
    expect(back.overlayAutoHide, isTrue);
    expect(back.advance().overlayEnabled, isTrue);
    final legacy = WorshipCodec.readPlan({'dailyPages': 2, 'nextPage': 1});
    expect(legacy.overlayEnabled, isFalse);
    expect(legacy.overlayAutoHide, isFalse);
  });

  test(
    'enabled + permitted shows the bubble, opens reader, never completes',
    () async {
      final reader = _Reader();
      final overlay = _Overlay(usageAccess: true);
      final c = await cubit(reader, overlay);
      expect(await c.openReader(overlayCopy: _copy), isTrue);
      expect(reader.opened, ['reader']);
      expect(overlay.shown.single.packageName, 'reader');
      expect(overlay.shown.single.autoHide, isTrue);
      expect(c.state.noticeKey, isNull);
      expect(c.state.snapshot!.completion, isNull);
    },
  );

  test('auto-hide is requested only when Usage Access was granted', () async {
    final overlay = _Overlay(usageAccess: false);
    final c = await cubit(_Reader(), overlay);
    await c.openReader(overlayCopy: _copy);
    expect(overlay.shown.single.autoHide, isFalse);
  });

  test('toggle off never touches the overlay port', () async {
    final overlay = _Overlay();
    final reader = _Reader();
    final c = await cubit(reader, overlay, enabled: false);
    expect(await c.openReader(overlayCopy: _copy), isTrue);
    expect(overlay.shown, isEmpty);
    expect(reader.opened, ['reader']);
  });

  test('denied permission degrades: reader opens, notice explains', () async {
    final overlay = _Overlay(canDraw: false);
    final reader = _Reader();
    final c = await cubit(reader, overlay);
    expect(await c.openReader(overlayCopy: _copy), isTrue);
    expect(overlay.shown, isEmpty);
    expect(reader.opened, ['reader']);
    expect(c.state.noticeKey, 'worship_overlay_unavailable');
  });

  test('overlay failure never blocks the reader', () async {
    final overlay = _Overlay()..throwOnShow = true;
    final reader = _Reader();
    final c = await cubit(reader, overlay);
    expect(await c.openReader(overlayCopy: _copy), isTrue);
    expect(reader.opened, ['reader']);
    expect(c.state.noticeKey, 'worship_overlay_unavailable');
  });

  test('reader failure hides the bubble again', () async {
    final overlay = _Overlay();
    final c = await cubit(_Reader(opens: false), overlay);
    expect(await c.openReader(overlayCopy: _copy), isFalse);
    expect(overlay.hides, 1);
    expect(c.state.errorKey, 'worship_reader_unavailable');
  });

  test(
    'Done asks for confirmation; only completeWird records and hides',
    () async {
      final overlay = _Overlay();
      final c = await cubit(_Reader(), overlay);
      final requests = <void>[];
      c.confirmRequests.listen(requests.add);
      overlay.pendingDone = true;
      await c.load();
      await Future<void>.delayed(Duration.zero);
      expect(requests, hasLength(1));
      expect(c.state.snapshot!.completion, isNull);
      expect(await c.completeWird(), isTrue);
      expect(c.state.snapshot!.completion, isNotNull);
      expect(overlay.hides, 1);
    },
  );

  test('cold start: pending Done is picked up on load', () async {
    final overlay = _Overlay()..pendingDone = true;
    await repository.savePlan(const WirdPlan(dailyPages: 2, nextPage: 1));
    final c = WorshipCubit(repository, overlays: overlay);
    addTearDown(c.close);
    final got = c.confirmRequests.first;
    await c.load();
    await got.timeout(const Duration(seconds: 2));
  });

  test('Android adapter maps channel calls', () async {
    final calls = <MethodCall>[];
    const channel = MethodChannel('test/overlay');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'overlay.status' => {'canDraw': true, 'usageAccess': false},
            'overlay.show' => true,
            'overlay.takePendingDone' => true,
            _ => null,
          };
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final port = AndroidReaderOverlay(channel: channel);
    final status = await port.status();
    expect(status.canDraw, isTrue);
    expect(status.usageAccess, isFalse);
    expect(
      await port.show(
        const ReaderOverlayRequest(
          packageName: 'p',
          title: 't',
          body: 'b',
          doneLabel: 'd',
          closeLabel: 'c',
        ),
      ),
      isTrue,
    );
    expect(calls.last.arguments['timeoutMs'], 1800000);
    expect(await port.takePendingDone(), isTrue);
    await port.hide();
    expect(calls.last.method, 'overlay.hide');
  });

  testWidgets('bubble Done shows confirm dialog; only Yes records the wird', (
    tester,
  ) async {
    final overlay = _Overlay();
    await tester.runAsync(
      () => repository.savePlan(
        const WirdPlan(dailyPages: 2, nextPage: 1, overlayEnabled: true),
      ),
    );
    final c = WorshipCubit(repository, overlays: overlay);
    addTearDown(c.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.getLightTheme(const Locale('en')),
        home: WorshipScreen(cubit: c),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(c.state.snapshot!.completion, isNull);

    Future<void> pressDone() async {
      overlay.pendingDone = true;
      unawaited(c.load());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
    }

    final copy = worshipCopy['en']!;
    await pressDone();
    expect(find.text(copy['worship_overlay_confirm_title']!), findsOneWidget);
    await tester.tap(find.text(copy['worship_overlay_confirm_no']!));
    await tester.pumpAndSettle();
    expect(
      c.state.snapshot!.completion,
      isNull,
      reason: 'Not yet records nothing',
    );

    await pressDone();
    await tester.tap(find.text(copy['worship_overlay_confirm_yes']!));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(c.state.snapshot!.completion, isNotNull);
    expect(overlay.hides, 1);
  });

  testWidgets('fresh screen opened by bubble Done shows the confirmation', (
    tester,
  ) async {
    final overlay = _Overlay()..pendingDone = true;
    await tester.runAsync(
      () => repository.savePlan(const WirdPlan(dailyPages: 2, nextPage: 1)),
    );
    final c = WorshipCubit(repository, overlays: overlay);
    addTearDown(c.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.getLightTheme(const Locale('en')),
        home: WorshipScreen(cubit: c),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(worshipCopy['en']!['worship_overlay_confirm_title']!),
      findsOneWidget,
    );
    expect(c.state.snapshot!.completion, isNull);
  });
}
