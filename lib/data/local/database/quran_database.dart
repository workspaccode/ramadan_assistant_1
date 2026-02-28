import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';

part 'quran_database.g.dart';

@DataClassName('SurahEntity')
class Surahs extends Table {
  IntColumn get number => integer()();
  TextColumn get nameAr => text().named('name_ar')();
  TextColumn get nameEn => text().named('name_en')();
  TextColumn get nameTransliteration => text().named('name_transliteration')();
  TextColumn get revelationPlaceAr => text().named('revelation_place_ar')();
  TextColumn get revelationPlaceEn => text().named('revelation_place_en')();
  IntColumn get versesCount => integer().named('verses_count')();
  IntColumn get wordsCount => integer().named('words_count')();
  IntColumn get lettersCount => integer().named('letters_count')();

  @override
  Set<Column> get primaryKey => {number};
}

@DataClassName('VerseEntity')
class Verses extends Table {
  IntColumn get surahNumber => integer().named('surah_number')();
  IntColumn get number => integer()();
  TextColumn get textAr => text().named('text_ar')();
  TextColumn get textEn => text().named('text_en')();
  IntColumn get juz => integer()();
  IntColumn get page => integer()();
  BoolColumn get sajda => boolean()();

  @override
  Set<Column> get primaryKey => {surahNumber, number};
}

@DataClassName('AudioEntity')
class Audios extends Table {
  IntColumn get id => integer()();
  IntColumn get surahNumber => integer().named('surah_number')();
  TextColumn get reciterAr => text().named('reciter_ar')();
  TextColumn get reciterEn => text().named('reciter_en')();
  TextColumn get rewayaAr => text().named('rewaya_ar')();
  TextColumn get rewayaEn => text().named('rewaya_en')();
  TextColumn get server => text()();
  TextColumn get link => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'audio';
}

@DriftDatabase(tables: [Surahs, Verses, Audios])
class QuranDatabase extends _$QuranDatabase {
  QuranDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Singletons
  static final QuranDatabase instance = QuranDatabase();

  // Query Methods
  Future<List<VerseEntity>> getVersesByPage(int pageNum) {
    return (select(verses)..where((v) => v.page.equals(pageNum))).get();
  }

  Future<List<VerseEntity>> getSurahVerses(int surahNum) {
    return (select(verses)..where((v) => v.surahNumber.equals(surahNum))).get();
  }

  Future<List<SurahEntity>> getAllSurahs() {
    return select(surahs).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final path = await QuranDatabaseService.instance.getDatabasePath();
    final file = File(path);
    // Return a NativeDatabase that points to the downloaded file
    return NativeDatabase.createInBackground(file);
  });
}
