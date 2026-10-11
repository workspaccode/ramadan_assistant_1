import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/data/local/database/quran_database.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/widgets/prayer_times_content.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/download_quran_screen.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/quran_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class _Audio implements AudioService {
  final completion = StreamController<void>.broadcast();
  final played = <String>[];
  Completer<void>? pendingPlay;
  int stopCount = 0;
  @override
  int playbackGeneration = 0;
  @override
  bool isPlaying = false;
  @override
  Stream<void> get onPlayerComplete => completion.stream;
  @override
  Future<void> playUrl(String url) async {
    final generation = ++playbackGeneration;
    played.add(url);
    if (pendingPlay != null) await pendingPlay!.future;
    if (generation == playbackGeneration) isPlaying = true;
  }

  @override
  Future<void> stop() async {
    playbackGeneration++;
    stopCount++;
    isPlaying = false;
  }

  void takeOver() {
    playbackGeneration++;
    isPlaying = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuranData implements QuranDatabase {
  final nextPage = Completer<List<VerseEntity>>();
  final requested = <int>[];
  @override
  Future<List<SurahEntity>> getAllSurahs() async => [];
  @override
  Future<List<VerseEntity>> getVersesByPage(int page) {
    requested.add(page);
    return page == 1
        ? Future.value([
            const VerseEntity(
              surahNumber: 1,
              number: 1,
              textAr: 'بسم الله',
              juz: 1,
              page: 1,
            ),
          ])
        : nextPage.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  theme: AppTheme.getLightTheme(const Locale('en')),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Builder(
    builder: (context) {
      AppLocalizationsLookup.init(context);
      return child;
    },
  ),
);

void main() {
  testWidgets('Another audio source completion cannot advance Quran', (
    tester,
  ) async {
    final audio = _Audio();
    final db = _QuranData();
    addTearDown(audio.completion.close);
    await tester.pumpWidget(
      _app(QuranScreen(audioService: audio, database: db)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(audio.played, hasLength(1));
    audio.takeOver();
    audio.completion.add(null);
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(db.requested, isNot(contains(2)));
    expect(audio.played, hasLength(1));
    await tester.pumpWidget(const SizedBox());
    expect(audio.stopCount, 0);
  });

  testWidgets(
    'Async Quran start cannot claim playback after another source takes over',
    (tester) async {
      final audio = _Audio()..pendingPlay = Completer<void>();
      final db = _QuranData();
      addTearDown(audio.completion.close);
      await tester.pumpWidget(
        _app(QuranScreen(audioService: audio, database: db)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      audio.takeOver();
      audio.pendingPlay!.complete();
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
      await tester.pumpWidget(const SizedBox());
      expect(audio.isPlaying, isTrue);
      expect(audio.stopCount, 0);
    },
  );
  testWidgets(
    'Stopping Quran playback cancels a pending next-page continuation',
    (tester) async {
      final audio = _Audio();
      final db = _QuranData();
      addTearDown(audio.completion.close);
      await tester.pumpWidget(
        _app(QuranScreen(audioService: audio, database: db)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(audio.played, hasLength(1));
      audio.completion.add(null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(db.requested, contains(2));
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump();
      db.nextPage.complete([
        const VerseEntity(
          surahNumber: 2,
          number: 1,
          textAr: 'الم',
          juz: 1,
          page: 2,
        ),
      ]);
      await tester.pump();
      expect(audio.played, hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  final times = PrayerTimes(
    date: DateTime(2026, 10, 10),
    coordinates: const Coordinates(21.4225, 39.8262),
    calculationParameters: CalculationMethodParameters.ummAlQura(),
  );

  test('Adhan only triggers at or shortly after an obligatory prayer', () {
    for (final prayer in obligatoryPrayers(times)) {
      expect(
        dueObligatoryPrayer(
          times,
          prayer.time.subtract(const Duration(milliseconds: 1)),
        ),
        isNull,
      );
      expect(dueObligatoryPrayer(times, prayer.time)?.name, prayer.name);
      expect(
        dueObligatoryPrayer(
          times,
          prayer.time.add(const Duration(seconds: 2)),
        )?.name,
        prayer.name,
      );
      expect(
        dueObligatoryPrayer(
          times,
          prayer.time.add(const Duration(milliseconds: 2001)),
        ),
        isNull,
      );
    }
    expect(dueObligatoryPrayer(times, times.sunrise), isNull);
  });

  test('Next prayer excludes sunrise and uses calculated next-day Fajr', () {
    expect(
      nextObligatoryPrayer(
        times,
        times.fajr.add(const Duration(minutes: 1)),
      ).name,
      'dhuhr',
    );
    expect(
      nextObligatoryPrayer(
        times,
        times.isha.add(const Duration(minutes: 1)),
      ).time,
      times.fajrAfter.toLocal(),
    );
    expect(nextObligatoryPrayer(times, times.isha).name, 'fajr');
  });

  testWidgets('Retained root pages observe active tab changes', (tester) async {
    final selected = ValueNotifier(1);
    addTearDown(selected.dispose);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<int>(
          valueListenable: selected,
          builder: (context, index, _) => AppShellScope(
            activeTab: index,
            child: Builder(
              builder: (context) => Text(
                AppShellScope.isActive(context, 1) ? 'active' : 'hidden',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('active'), findsOneWidget);
    selected.value = 0;
    await tester.pump();
    expect(find.text('hidden'), findsOneWidget);
  });

  for (final fails in [false, true]) {
    testWidgets('Download callbacks after disposal are safe (fails=$fails)', (
      tester,
    ) async {
      final download = Completer<void>();
      late ValueChanged<double> progress;
      await tester.pumpWidget(
        _app(
          DownloadQuranScreen(
            downloadDatabase: (callback) {
              progress = callback;
              return download.future;
            },
            seedTajweed: (callback) async {
              callback(1);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      progress(0.5);
      if (fails) {
        download.completeError(StateError('Offline'));
      } else {
        download.complete();
      }
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Quran tab setup returns to caller after success', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DownloadQuranScreen(
                    returnToCaller: true,
                    downloadDatabase: (progress) async {
                      progress(1);
                    },
                    seedTajweed: (progress) async {
                      progress(1);
                    },
                  ),
                ),
              ),
              child: const Text('Open setup'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open setup'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Open setup'), findsOneWidget);
    expect(find.byType(DownloadQuranScreen), findsNothing);
    expect(find.byType(QuranScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
