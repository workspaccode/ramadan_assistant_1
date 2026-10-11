import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/features/library/library_cubit.dart';
import 'package:ramadan_assistant/features/library/library_models.dart';
import 'package:ramadan_assistant/features/library/library_playback.dart';
import 'package:ramadan_assistant/features/library/library_reading_screen.dart';
import 'package:ramadan_assistant/features/library/library_repository.dart';
import 'package:ramadan_assistant/features/library/library_screen.dart';

class _Engine implements LibraryMediaEngine {
  final events = <String>[];
  final signals = StreamController<void>.broadcast();
  bool fail = false, disposed = false;
  Completer<void>? delayedSpeech;
  @override
  Stream<void> get completed => signals.stream;
  @override
  Future<void> speak(String text, String language) async {
    events.add('speak:$language');
    if (fail) throw StateError('Missing voice');
    await delayedSpeech?.future;
  }

  @override
  Future<void> play(Uri url) async {
    events.add('audio');
    if (fail) throw StateError('Missing audio');
  }

  @override
  Future<void> stop() async {
    events.add('stop');
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await signals.close();
  }
}

class _DelayedRepository extends LibraryRepository {
  _DelayedRepository(super.store);
  final pending = Completer<List<LibraryItem>>();
  @override
  Future<List<LibraryItem>> load() => pending.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late LibraryRepository repository;
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LibraryRepository(DriftDocumentStore(database));
  });
  tearDown(() async {
    await database.close();
  });

  test(
    'Favorites and valid media survive repository recreation without duplication',
    () async {
      final id = (await repository.load()).first.id;
      await repository.setFavorite(id, true);
      await repository.addMedia(
        id,
        LibraryMediaKind.audio,
        'https://example.org/audio.mp3',
        'My recording',
      );
      await repository.addMedia(
        id,
        LibraryMediaKind.audio,
        'https://example.org/audio.mp3',
        'Duplicate',
      );
      final restored = (await LibraryRepository(repository.store).load()).first;
      expect(restored.favorite, isTrue);
      expect(restored.media, hasLength(1));
      expect(restored.media.single.label, 'My recording');
      await repository.removeMedia(id, restored.media.single.id);
      final removed = (await repository.load()).first;
      expect(removed.favorite, isTrue);
      expect(removed.media, isEmpty);
    },
  );

  test(
    'Unsafe links and corrupt saved media do not enter the library',
    () async {
      for (final url in [
        'http://example.org/a',
        'javascript:alert(1)',
        'https://user:secret@example.org/a',
        'https://',
        'https://exa mple.org',
      ]) {
        expect(libraryHttpsUri(url), isNull);
        await expectLater(
          repository.addMedia('abu_bakr_cave', LibraryMediaKind.video, url, ''),
          throwsFormatException,
        );
      }
      await repository.store.upsert(
        LibraryRepository.namespace,
        'abu_bakr_cave',
        {
          'favorite': true,
          'media': [
            null,
            {'id': '1', 'kind': 'video', 'url': 'javascript:alert(1)'},
          ],
        },
      );
      final restored = (await repository.load()).first;
      expect(restored.favorite, isTrue);
      expect(restored.media, isEmpty);
    },
  );

  test(
    'Mutation failure retains content and successful retry recovers',
    () async {
      final cubit = LibraryCubit(repository);
      await cubit.load();
      expect(
        await cubit.addMedia(
          'abu_bakr_cave',
          LibraryMediaKind.audio,
          'http://invalid',
          '',
        ),
        isFalse,
      );
      expect(cubit.state.saveFailed, isTrue);
      expect(cubit.state.items, hasLength(6));
      expect(await cubit.setFavorite('abu_bakr_cave', true), isTrue);
      expect(cubit.state.saveFailed, isFalse);
      expect(cubit.state.items.first.favorite, isTrue);
      await cubit.close();
    },
  );

  test('Late load completion after disposal cannot emit', () async {
    final delayed = _DelayedRepository(repository.store);
    final cubit = LibraryCubit(delayed);
    final load = cubit.load();
    await cubit.close();
    delayed.pending.complete(await repository.load());
    await load;
    expect(cubit.isClosed, isTrue);
  });

  test(
    'Playback failures recover and completion clears active state',
    () async {
      final engine = _Engine()..fail = true;
      final playback = LibraryPlaybackCubit(engine);
      await playback.speak('Summary', 'en-US');
      expect(playback.state.failed, isTrue);
      engine.fail = false;
      await playback.play(Uri.parse('https://example.org/a.mp3'));
      expect(playback.state.active, isTrue);
      engine.signals.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(playback.state.active, isFalse);
      await playback.close();
      expect(engine.disposed, isTrue);
    },
  );

  test(
    'Disposal stops pending playback without waiting for stale completion',
    () async {
      final engine = _Engine()..delayedSpeech = Completer<void>();
      final playback = LibraryPlaybackCubit(engine);
      final speech = playback.speak('Summary', 'ar-SA');
      await Future<void>.delayed(Duration.zero);
      await playback.close();
      expect(engine.disposed, isTrue);
      engine.delayedSpeech!.complete();
      await speech;
      expect(playback.isClosed, isTrue);
    },
  );

  for (final locale in ['ar', 'en', 'ur']) {
    for (final reading in [false, true]) {
      testWidgets(
        'Library ${reading ? 'reader' : 'list'} $locale fits 320px at 2x type',
        (tester) async {
          tester.view.physicalSize = const Size(320, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final cubit = LibraryCubit(repository);
          await cubit.load();
          final engine = _Engine();
          await tester.pumpWidget(
            BlocProvider.value(
              value: cubit,
              child: MaterialApp(
                locale: Locale(locale),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                theme: AppTheme.getLightTheme(Locale(locale)),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: Builder(
                  builder: (context) {
                    AppLocalizationsLookup.init(context);
                    return reading
                        ? LibraryReadingScreen(
                            itemId: 'abu_bakr_cave',
                            mediaEngine: engine,
                          )
                        : LibraryScreen(onOpenHadith: () {});
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await cubit.close();
        },
      );
    }
  }

  testWidgets('Search empty state resets and favorite filter recovers', (
    tester,
  ) async {
    final cubit = LibraryCubit(repository);
    await cubit.load();
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.getLightTheme(const Locale('en')),
          home: Builder(
            builder: (context) {
              AppLocalizationsLookup.init(context);
              return LibraryScreen(onOpenHadith: () {});
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nothing matches this text');
    await tester.pumpAndSettle();
    expect(
      find.text(AppLocalizationsLookup.instance.ui_no_results),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('reset'.tr()));
    await tester.pumpAndSettle();
    expect(find.text('Abu Bakr in the cave'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await cubit.close();
  });

  testWidgets(
    'Media form validates HTTPS and saves a video link with the keyboard open',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final cubit = LibraryCubit(repository);
      await cubit.load();
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.getLightTheme(const Locale('en')),
            home: Builder(
              builder: (context) {
                AppLocalizationsLookup.init(context);
                return LibraryReadingScreen(
                  itemId: 'abu_bakr_cave',
                  mediaEngine: _Engine(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final add = find.widgetWithText(
        OutlinedButton,
        AppLocalizationsLookup.instance.library_add_media,
      );
      await tester.scrollUntilVisible(
        add,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'http://example.org/video',
      );
      final save = find.widgetWithText(
        FilledButton,
        AppLocalizationsLookup.instance.library_save,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(
        find.text(AppLocalizationsLookup.instance.library_invalid_link),
        findsOneWidget,
      );
      await tester.tap(
        find.widgetWithText(
          ChoiceChip,
          AppLocalizationsLookup.instance.library_video,
        ),
      );
      await tester.enterText(
        find.byType(TextField).first,
        'https://example.org/video',
      );
      await tester.enterText(find.byType(TextField).last, 'My video');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(cubit.state.items.first.media.single.kind, LibraryMediaKind.video);
      expect(cubit.state.items.first.media.single.label, 'My video');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await cubit.close();
    },
  );

  test(
    'Native voice setup stopped mid-flight does not speak afterwards',
    () async {
      const channel = MethodChannel('flutter_tts');
      final languageStarted = Completer<void>();
      final languageResult = Completer<int>();
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            if (call.method == 'setLanguage') {
              languageStarted.complete();
              return languageResult.future;
            }
            return 1;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final engine = DeviceLibraryMediaEngine();
      final speaking = engine.speak('Summary', 'ar-SA');
      await languageStarted.future;
      await engine.stop();
      languageResult.complete(1);
      await speaking;
      expect(calls, isNot(contains('speak')));
      await engine.dispose();
    },
  );

  test(
    'A plugin error event remains visible until a successful retry',
    () async {
      final engine = _Engine();
      final playback = LibraryPlaybackCubit(engine);
      await playback.play(Uri.parse('https://example.org/a.mp3'));
      engine.signals.addError(StateError('Native playback failed'));
      await Future<void>.delayed(Duration.zero);
      expect(playback.state.failed, isTrue);
      engine.signals.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(playback.state.failed, isTrue);
      await playback.speak('Summary', 'en-US');
      expect(playback.state.failed, isFalse);
      expect(playback.state.active, isTrue);
      await playback.close();
    },
  );

  test(
    'Disk write failure preserves a favorite and retry commits it',
    () async {
      final cubit = LibraryCubit(repository);
      await cubit.load();
      await database.customStatement(
        'CREATE TRIGGER fail_library_write BEFORE INSERT ON feature_documents '
        "BEGIN SELECT RAISE(ABORT, 'simulated disk failure'); END;",
      );
      expect(await cubit.setFavorite('abu_bakr_cave', true), isFalse);
      expect(cubit.state.saveFailed, isTrue);
      expect(cubit.state.items.first.favorite, isFalse);
      expect((await repository.load()).first.favorite, isFalse);
      await database.customStatement('DROP TRIGGER fail_library_write');
      expect(await cubit.setFavorite('abu_bakr_cave', true), isTrue);
      expect((await repository.load()).first.favorite, isTrue);
      await cubit.close();
    },
  );

  if (const bool.fromEnvironment('CAPTURE_LIBRARY')) {
    for (final dark in [false, true]) {
      for (final reading in [false, true]) {
        testWidgets('Render library ${reading ? 'reader' : 'list'} dark=$dark', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final font = FontLoader('Cairo')
            ..addFont(rootBundle.load('assets/fonts/Cairo.ttf'));
          await font.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
          final cubit = LibraryCubit(repository);
          await cubit.load();
          final boundary = GlobalKey();
          await tester.pumpWidget(
            BlocProvider.value(
              value: cubit,
              child: MaterialApp(
                locale: const Locale('ar'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                theme: dark
                    ? AppTheme.getDarkTheme(const Locale('ar'))
                    : AppTheme.getLightTheme(const Locale('ar')),
                home: Builder(
                  builder: (context) {
                    AppLocalizationsLookup.init(context);
                    return RepaintBoundary(
                      key: boundary,
                      child: reading
                          ? LibraryReadingScreen(
                              itemId: 'abu_bakr_cave',
                              mediaEngine: _Engine(),
                            )
                          : LibraryScreen(onOpenHadith: () {}),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await render.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final output = File(
              'report/ui/features/${reading ? 'library-reading' : 'library'}-${dark ? 'dark' : 'light'}.png',
            );
            await output.parent.create(recursive: true);
            await output.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          await tester.pumpWidget(const SizedBox.shrink());
          await cubit.close();
        });
      }
    }
  }
}
