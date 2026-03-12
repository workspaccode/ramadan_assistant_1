import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_assistant/data/models/dua_model.dart';

class DuaService {
  static final DuaService _instance = DuaService._internal();
  factory DuaService() => _instance;
  DuaService._internal();

  List<Dua> _duas = [];
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final String response = await rootBundle.loadString('assets/data/duas.json');
      final data = json.decode(response);
      final List<dynamic> duasList = data['duas'];
      _duas = duasList.map((e) => Dua.fromJson(e)).toList();
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading duas: $e');
    }
  }

  List<Dua> get allDuas => _duas;

  List<String> get categories {
    return _duas.map((e) => e.category).toSet().toList();
  }

  List<Dua> getByCategory(String category) {
    return _duas.where((e) => e.category == category).toList();
  }

  List<Dua> search(String query) {
    if (query.isEmpty) return _duas;
    final lowercaseQuery = query.toLowerCase();
    return _duas.where((dua) {
      return dua.arabic.contains(query) ||
          (dua.category.toLowerCase().contains(lowercaseQuery)) ||
          (dua.source?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
}
