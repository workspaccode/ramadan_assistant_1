import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
}
