import 'dart:convert';

import 'package:ramadan_assistant/data/models/hadith_model.dart';
import 'package:ramadan_assistant/data/services/hadith_service.dart';

class HadithRepository {
  final HadithService _service;

  // Use Nawawi 40 Hadith from the AhmedBaset/hadith-json repo as the default
  final String _jsonUrl =
      'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/forties/nawawi40.json';

  HadithRepository(this._service);

  Future<List<Hadith>> loadHadiths({String? url}) async {
    final dataString = await _service.getHadithData(url ?? _jsonUrl);

    // Parse JSON
    final decoded = json.decode(dataString);
    List<dynamic> list;

    // Handle different common JSON structures
    if (decoded is Map && decoded.containsKey('hadiths')) {
      list = decoded['hadiths'];
    } else if (decoded is Map && decoded.containsKey('data')) {
      list = decoded['data'];
    } else if (decoded is List) {
      list = decoded;
    } else {
      // Fallback: try to find the largest list in the map
      var largestList = [];
      if (decoded is Map) {
        for (var value in decoded.values) {
          if (value is List && value.length > largestList.length) {
            largestList = value;
          }
        }
      }
      list = largestList;
    }

    return list.map((json) => Hadith.fromJson(json)).toList();
  }

  Future<void> forceRefresh({String? url}) async {
    await _service.clearCache();
    await loadHadiths(url: url);
  }
}
