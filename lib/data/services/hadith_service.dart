import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class HadithService {
  final Dio _dio;

  HadithService() : _dio = Dio();

  Future<File> getCachedFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/hadiths_cache.json');
  }

  Future<void> clearCache() async {
    final file = await getCachedFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> getHadithData(String url) async {
    final file = await getCachedFile();

    // Offline-first: if file exists, return its contents
    if (await file.exists()) {
      return await file.readAsString();
    }

    // Try to download and cache
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      final responseData = response.data.toString();

      // Save to cache
      await file.writeAsString(responseData);
      return responseData;
    } catch (e) {
      throw Exception(
        'Failed to load Hadiths. Please check your internet connection.',
      );
    }
  }
}
