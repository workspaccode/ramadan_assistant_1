import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ramadan_assistant/data/local/database/quran_database.dart';

class QuranDatabaseService {
  static const String databaseName = 'quran_uthmani.db';
  static final QuranDatabaseService instance = QuranDatabaseService._init();

  // Downloading a known Quran DB
  final String dbDownloadUrl =
      'https://raw.githubusercontent.com/rn0x/Quran-Data/version-2.0/data/sqlite/database.sqlite';

  QuranDatabaseService._init() : databasePath = null, client = null;
  @visibleForTesting
  QuranDatabaseService.testing({
    required this.databasePath,
    required this.client,
  });
  final Future<String> Function()? databasePath;
  final Dio? client;
  Future<void>? _downloadInFlight;
  Future<void>? _seedInFlight;

  /// Verify the installed file before sending a reader into an incomplete DB.
  static Future<bool> isUsableDatabase(File file) async {
    if (!await file.exists() || await file.length() < 100) return false;
    final database = NativeDatabase(file, enableMigrations: false);
    try {
      await database.ensureOpen(_QuranValidationUser());
      await database.runCustom('PRAGMA busy_timeout = 2000');
      final verses = await database.runSelect(
        'SELECT surah_number, number, text_ar, text_en, juz, page, sajda FROM verses LIMIT 1',
        [],
      );
      final surahs = await database.runSelect(
        'SELECT number, name_ar, name_en, name_transliteration, revelation_place_ar, revelation_place_en, verses_count, words_count, letters_count FROM surahs LIMIT 1',
        [],
      );
      final check = await database.runSelect('PRAGMA quick_check', []);
      return verses.isNotEmpty &&
          surahs.isNotEmpty &&
          check.length == 1 &&
          check.first.values.single == 'ok';
    } catch (_) {
      return false;
    } finally {
      await database.close();
    }
  }

  Future<String> getDatabasePath() async {
    if (databasePath != null) return databasePath!();
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = join(dbFolder.path, databaseName);
    return path;
  }

  Future<bool> isDatabaseExists() async {
    final path = await getDatabasePath();
    return isUsableDatabase(File(path));
  }

  Future<void> downloadDatabase(Function(double) onProgress) async {
    if (_downloadInFlight != null) return _downloadInFlight!;
    final operation = _downloadDatabase(onProgress);
    _downloadInFlight = operation;
    try {
      await operation;
    } finally {
      _downloadInFlight = null;
    }
  }

  Future<void> _downloadDatabase(Function(double) onProgress) async {
    final path = await getDatabasePath();
    if (await isUsableDatabase(File(path))) {
      onProgress(1);
      return;
    }
    final partial = File('$path.download');

    // Ensure directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    try {
      final dio = client ?? Dio();
      await dio.download(
        dbDownloadUrl,
        partial.path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );
      if (!await isUsableDatabase(partial)) {
        throw const FormatException('Downloaded Quran database is incomplete');
      }
      // Only publish the complete, validated file; preserve an existing valid DB.
      if (!await isUsableDatabase(File(path))) await partial.rename(path);
      onProgress(1);
    } catch (e) {
      // Clean up the partial file if download fails
      debugPrint('Failed to download database: $e');
      throw Exception('Failed to download database: $e');
    } finally {
      if (await partial.exists()) await partial.delete();
    }
  }

  // Parses the AlQuran Cloud quran-tajweed JSON Edition and stores it in SQLite
  Future<void> fetchAndSeedTajweedData(Function(double) onProgress) async {
    if (_seedInFlight != null) return _seedInFlight!;
    final operation = _seedTajweedData(onProgress);
    _seedInFlight = operation;
    try {
      await operation;
    } finally {
      _seedInFlight = null;
    }
  }

  Future<void> _seedTajweedData(Function(double) onProgress) async {
    const String url = 'https://api.alquran.cloud/v1/quran/quran-tajweed';

    try {
      final dio = client ?? Dio();
      final response = await dio.get(
        url,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress =
                (received / total) * 0.5; // Download is 50% of the work
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['surahs'] as List;
        final db = QuranDatabase.instance;

        // Ensure the text_tajweed column exists before attempting to update it.
        // The downloaded sqlite file doesn't have it initially. We ignore errors if it already exists.
        try {
          await db.customStatement(
            'ALTER TABLE verses ADD COLUMN text_tajweed TEXT;',
          );
        } catch (_) {
          // Column already exists, safe to ignore
        }

        int totalAyahs = 6236;
        int processedAyahs = 0;

        await db.batch((batch) {
          for (var surah in data) {
            final surahNumber = surah['number'] as int;
            final ayahs = surah['ayahs'] as List;

            for (var ayah in ayahs) {
              final ayahNumber = ayah['numberInSurah'] as int;
              final tajweedText = ayah['text'] as String;

              batch.update(
                db.verses,
                VersesCompanion(textTajweed: drift.Value(tajweedText)),
                where: (v) =>
                    v.surahNumber.equals(surahNumber) &
                    v.number.equals(ayahNumber),
              );

              processedAyahs++;

              // Report parsing progress artificially mapping to 0.5 -> 1.0 progress range
              if (processedAyahs % 100 == 0) {
                final parsingProgress =
                    0.5 + ((processedAyahs / totalAyahs) * 0.5);
                onProgress(parsingProgress);
              }
            }
          }
        });

        onProgress(1.0);
      } else {
        throw StateError('Tajweed service returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to seed Tajweed data: $e');
      throw Exception('Failed to sync Tajweed data: $e');
    }
  }
}

class _QuranValidationUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 1;
  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
