import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';
import 'package:ramadan_assistant/data/local/database/quran_database.dart';

class _Adapter implements HttpClientAdapter {
  final called = Completer<void>();
  final response = Completer<ResponseBody>();
  int requests = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests++;
    if (!called.isCompleted) called.complete();
    return response.future;
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _seed(QuranDatabase database) async {
  await database
      .into(database.surahs)
      .insert(const SurahEntity(number: 2, nameAr: 'البقرة', versesCount: 286));
  await database
      .into(database.surahs)
      .insert(const SurahEntity(number: 1, nameAr: 'الفاتحة', versesCount: 7));
  for (final number in [3, 2, 1]) {
    await database
        .into(database.verses)
        .insert(
          VerseEntity(
            surahNumber: 1,
            number: number,
            textAr: 'آية $number',
            juz: 1,
            page: number == 1 ? 1 : 2,
          ),
        );
  }
}

void main() {
  test(
    'Concurrent downloads publish one validated DB and preserve an installed DB',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'quran-download-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final fixtureFile = File('${directory.path}/fixture.db');
      final fixture = QuranDatabase(NativeDatabase(fixtureFile));
      await _seed(fixture);
      await fixture.close();
      final bytes = await fixtureFile.readAsBytes();
      final target = File('${directory.path}/installed.db');
      final adapter = _Adapter();
      final client = Dio()..httpClientAdapter = adapter;
      addTearDown(() => client.close());
      final service = QuranDatabaseService.testing(
        databasePath: () async => target.path,
        client: client,
      );
      final first = service.downloadDatabase((_) {});
      final second = service.downloadDatabase((_) {});
      await adapter.called.future;
      expect(await target.exists(), isFalse);
      expect(adapter.requests, 1);
      adapter.response.complete(
        ResponseBody.fromBytes(
          bytes,
          200,
          headers: {
            Headers.contentLengthHeader: ['${bytes.length}'],
          },
        ),
      );
      await Future.wait([first, second]);
      expect(await QuranDatabaseService.isUsableDatabase(target), isTrue);
      expect(await File('${target.path}.download').exists(), isFalse);
      final installed = await target.readAsBytes();
      await service.downloadDatabase((_) {});
      expect(adapter.requests, 1);
      expect(await target.readAsBytes(), installed);
    },
  );

  test('A corrupt download cannot replace the existing file', () async {
    final directory = await Directory.systemTemp.createTemp('quran-rejected-');
    addTearDown(() => directory.delete(recursive: true));
    final target = File('${directory.path}/installed.db');
    await target.writeAsString('previous incomplete file');
    final adapter = _Adapter();
    final client = Dio()..httpClientAdapter = adapter;
    addTearDown(() => client.close());
    final service = QuranDatabaseService.testing(
      databasePath: () async => target.path,
      client: client,
    );
    final result = expectLater(
      service.downloadDatabase((_) {}),
      throwsException,
    );
    await adapter.called.future;
    adapter.response.complete(
      ResponseBody.fromBytes(
        List.filled(1000, 0),
        200,
        headers: {
          Headers.contentLengthHeader: ['1000'],
        },
      ),
    );
    await result;
    expect(await target.readAsString(), 'previous incomplete file');
    expect(await File('${target.path}.download').exists(), isFalse);
  });
  test('Reader and index use Quran order despite insertion order', () async {
    final database = QuranDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _seed(database);
    expect((await database.getAllSurahs()).map((surah) => surah.number), [
      1,
      2,
    ]);
    expect((await database.getSurahVerses(1)).map((verse) => verse.number), [
      1,
      2,
      3,
    ]);
    expect((await database.getVersesByPage(2)).map((verse) => verse.number), [
      2,
      3,
    ]);
    expect(await database.getSurahStartPage(1), 1);
    expect(await database.getJuzStartPage(1), 1);
  });

  test(
    'Missing, corrupt, and empty Quran files are not treated as ready',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'quran-validation-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/quran.db');
      expect(await QuranDatabaseService.isUsableDatabase(file), isFalse);
      await file.writeAsString('invalid database'.padRight(1000, '.'));
      expect(await QuranDatabaseService.isUsableDatabase(file), isFalse);
      await file.delete();
      final database = QuranDatabase(NativeDatabase(file));
      await database.getAllSurahs();
      await database.close();
      expect(await QuranDatabaseService.isUsableDatabase(file), isFalse);
    },
  );

  test(
    'Legacy offline Quran gains optional Tajweed column without losing verses',
    () async {
      final directory = await Directory.systemTemp.createTemp('quran-legacy-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/quran.db');
      final original = QuranDatabase(NativeDatabase(file));
      await _seed(original);
      await original.customStatement(
        'ALTER TABLE verses DROP COLUMN text_tajweed',
      );
      await original.close();
      expect(await QuranDatabaseService.isUsableDatabase(file), isTrue);
      final upgraded = QuranDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);
      final verses = await upgraded.getSurahVerses(1);
      expect(verses, hasLength(3));
      expect(verses.every((verse) => verse.textTajweed == null), isTrue);
      expect(verses.first.textAr, 'آية 1');
    },
  );
}
