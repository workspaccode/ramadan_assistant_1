import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';

part 'quran_database.g.dart';

@DataClassName('SurahEntity')
class Surahs extends Table {
  IntColumn get number => integer()();
  TextColumn get nameAr => text().named('name_ar')();
  TextColumn get nameEn => text().named('name_en').nullable()();
  TextColumn get nameTransliteration =>
      text().named('name_transliteration').nullable()();
  TextColumn get revelationPlaceAr =>
      text().named('revelation_place_ar').nullable()();
  TextColumn get revelationPlaceEn =>
      text().named('revelation_place_en').nullable()();
  IntColumn get versesCount => integer().named('verses_count')();
  IntColumn get wordsCount => integer().named('words_count').nullable()();
  IntColumn get lettersCount => integer().named('letters_count').nullable()();

  @override
  Set<Column> get primaryKey => {number};
}

@DataClassName('VerseEntity')
class Verses extends Table {
  IntColumn get surahNumber => integer().named('surah_number')();
  IntColumn get number => integer()();
  TextColumn get textAr => text().named('text_ar')();
  TextColumn get textEn => text().named('text_en').nullable()();
  TextColumn get textTajweed => text().named('text_tajweed').nullable()();
  IntColumn get juz => integer()();
  IntColumn get page => integer()();
  BoolColumn get sajda => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {surahNumber, number};
}

@DataClassName('AudioEntity')
class Audios extends Table {
  IntColumn get id => integer()();
  IntColumn get surahNumber => integer().named('surah_number')();
  TextColumn get reciterAr => text().named('reciter_ar')();
  TextColumn get reciterEn => text().named('reciter_en').nullable()();
  TextColumn get rewayaAr => text().named('rewaya_ar').nullable()();
  TextColumn get rewayaEn => text().named('rewaya_en').nullable()();
  TextColumn get server => text().nullable()();
  TextColumn get link => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'audio';
}

@DriftDatabase(tables: [Surahs, Verses, Audios])
class QuranDatabase extends _$QuranDatabase {
  QuranDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          // Schema changed, but standard migration not needed right now
        }
      },
      beforeOpen: (_) async {
        // The offline source can predate optional Tajweed coloring.
        final columns = await customSelect('PRAGMA table_info(verses)').get();
        if (!columns.any(
          (column) => column.read<String>('name') == 'text_tajweed',
        )) {
          await customStatement(
            'ALTER TABLE verses ADD COLUMN text_tajweed TEXT',
          );
        }
      },
    );
  }

  // Singletons
  static final QuranDatabase instance = QuranDatabase();

  // Query Methods
  Future<List<VerseEntity>> getVersesByPage(int pageNum) {
    return (select(verses)
          ..where((v) => v.page.equals(pageNum))
          ..orderBy([
            (v) => OrderingTerm.asc(v.surahNumber),
            (v) => OrderingTerm.asc(v.number),
          ]))
        .get();
  }

  Future<List<VerseEntity>> getSurahVerses(int surahNum) {
    return (select(verses)
          ..where((v) => v.surahNumber.equals(surahNum))
          ..orderBy([(v) => OrderingTerm.asc(v.number)]))
        .get();
  }

  Future<List<SurahEntity>> getAllSurahs() {
    return (select(surahs)..orderBy([(s) => OrderingTerm.asc(s.number)])).get();
  }

  // Used for Fihris (Index)
  Future<int> getSurahStartPage(int surahNum) async {
    final verse =
        await (select(verses)
              ..where((v) => v.surahNumber.equals(surahNum))
              ..orderBy([(v) => OrderingTerm.asc(v.number)])
              ..limit(1))
            .getSingle();
    return verse.page;
  }

  Future<int> getJuzStartPage(int juzNum) async {
    final verse =
        await (select(verses)
              ..where((v) => v.juz.equals(juzNum))
              ..orderBy([
                (v) => OrderingTerm.asc(v.page),
                (v) => OrderingTerm.asc(v.surahNumber),
                (v) => OrderingTerm.asc(v.number),
              ])
              ..limit(1))
            .getSingle();
    return verse.page;
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

// Invalidate builder cache
