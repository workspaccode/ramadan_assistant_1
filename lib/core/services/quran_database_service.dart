import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
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

  QuranDatabaseService._init();

  Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = join(dbFolder.path, databaseName);
    return path;
  }

  Future<bool> isDatabaseExists() async {
    final path = await getDatabasePath();
    return File(path).exists();
  }

  Future<void> downloadDatabase(Function(double) onProgress) async {
    final path = await getDatabasePath();

    // Ensure directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    try {
      final dio = Dio();
      await dio.download(
        dbDownloadUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );
    } catch (e) {
      // Clean up the partial file if download fails
      debugPrint('Failed to download database: $e');
      if (await File(path).exists()) {
        await File(path).delete();
      }
      throw Exception('Failed to download database: $e');
    }
  }

  // Parses the AlQuran Cloud quran-tajweed JSON Edition and stores it in SQLite
  Future<void> fetchAndSeedTajweedData(Function(double) onProgress) async {
    const String url = 'https://api.alquran.cloud/v1/quran/quran-tajweed';

    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        onReceiveProgress: (received, total) {
          if (total != -1) {
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
      }
    } catch (e) {
      debugPrint('Failed to seed Tajweed data: $e');
      throw Exception('Failed to sync Tajweed data: $e');
    }
  }
}
