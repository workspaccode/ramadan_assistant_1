import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_assistant/data/models/dua_model.dart';

class DuaCategory {
  final String category;
  final List<Dua> duas;

  DuaCategory({required this.category, required this.duas});
}

class DuaService {
  List<Dua> _allDuas = [];
  List<DuaCategory> _hundredDuas = [];

  List<Dua> get allDuas => _allDuas;
  List<DuaCategory> get hundredDuas => _hundredDuas;
  List<String> get categories => _allDuas.map((d) => d.category).toSet().toList();

  Future<void> init() async {
    await loadDuas();
    await load100Duas();
  }

  Future<void> loadDuas() async {
    try {
      final String response = await rootBundle.loadString('assets/data/duas.json');
      final data = json.decode(response);
      final List<dynamic> duaList = data['duas'] ?? [];
      _allDuas = duaList.map((json) => Dua.fromJson(json)).toList();
      debugPrint('Loaded ${_allDuas.length} general duas');
    } catch (e) {
      debugPrint('Error loading general duas: $e');
    }
  }

  Future<void> load100Duas() async {
    try {
      final String response = await rootBundle.loadString('assets/data/duas_100.json');
      final data = await json.decode(response) as List;
      _hundredDuas = data.map((item) {
        final categoryName = item['category'] as String;
        final duasList = (item['duas'] as List).map((d) {
          return Dua(
            category: categoryName,
            arabic: d['text'],
            translation: d['translation'],
            source: d['reference'],
          );
        }).toList();
        return DuaCategory(category: categoryName, duas: duasList);
      }).toList();
    } catch (e) {
      _hundredDuas = [];
    }
  }

  List<Dua> getByCategory(String category) {
    return _allDuas.where((d) => d.category == category).toList();
  }

  List<Dua> search(String query) {
    if (query.isEmpty) return _allDuas;
    return _allDuas.where((d) => 
      d.arabic.contains(query) || 
      (d.translation?.contains(query) ?? false) ||
      d.category.contains(query)
    ).toList();
  }
}
