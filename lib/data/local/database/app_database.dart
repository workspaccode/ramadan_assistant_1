import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class PrayerLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get prayerName => text()();
  DateTimeColumn get prayerTime => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class TasbihSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dhikrName => text()();
  IntColumn get count => integer()();
  IntColumn get targetCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get reminderTypes => text()(); // comma-separated dhikr IDs
  TextColumn get offsets =>
      text().nullable()(); // comma-separated offsets in seconds
  IntColumn get intervalMinutes => integer()();
  IntColumn get repeatCount => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get audioPaths =>
      text().nullable()(); // comma-separated audio paths
}

class UmrahProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get step => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Duas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // umrah, daily, etc.
  TextColumn get arabicText => text()();
  TextColumn get transliteration => text().nullable()();
  TextColumn get translation => text()();
  TextColumn get audioPath => text().nullable()();
}

class WirdProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get planType => text()(); // khatma, pagesPerPrayer, juzPerDay
  IntColumn get planValue => integer()();
  IntColumn get completedPages => integer().withDefault(const Constant(0))();
  IntColumn get lastReadPage => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastUpdated => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class WirdDailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get fajrPages => integer().withDefault(const Constant(0))();
  IntColumn get dhuhrPages => integer().withDefault(const Constant(0))();
  IntColumn get asrPages => integer().withDefault(const Constant(0))();
  IntColumn get maghribPages => integer().withDefault(const Constant(0))();
  IntColumn get ishaPages => integer().withDefault(const Constant(0))();
  IntColumn get otherPages => integer().withDefault(const Constant(0))();
}

/// Versioned feature records and a durable outbox, alongside legacy tables.
class FeatureDocuments extends Table {
  TextColumn get namespace => text()();
  TextColumn get documentId => text()();
  TextColumn get payload => text()();
  IntColumn get revision => integer()();
  IntColumn get payloadVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get sortKey => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {namespace, documentId};
}

@DriftDatabase(
  tables: [
    PrayerLogs,
    TasbihSessions,
    Reminders,
    UmrahProgress,
    Duas,
    WirdProgress,
    WirdDailyLogs,
    FeatureDocuments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createDocumentIndexes();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Migration from 1 to 2
          try {
            await customStatement(
              'ALTER TABLE reminders ADD COLUMN reminder_types TEXT NOT NULL DEFAULT "salawat"',
            );
            await m.addColumn(reminders, reminders.offsets);
            await m.addColumn(reminders, reminders.audioPaths);
          } catch (e) {
            // Ignore errors if columns already exist
          }
        }

        if (from < 3) {
          // Migration to 3: Cleanly recreate table to fix any naming conflicts (reminder_type vs reminder_types)
          await m.deleteTable(reminders.actualTableName);
          await m.createTable(reminders);
        }

        if (from < 4) {
          await m.createTable(wirdProgress);
        }

        if (from < 5) {
          await m.addColumn(wirdProgress, wirdProgress.lastReadPage);
          await m.createTable(wirdDailyLogs);
        }
        if (from < 6) {
          await m.createTable(featureDocuments);
          await _createDocumentIndexes();
        }
      },
    );
  }

  Future<void> _createDocumentIndexes() async {
    await customStatement('CREATE INDEX IF NOT EXISTS feature_documents_range '
        'ON feature_documents(namespace, deleted_at, sort_key)');
    await customStatement('CREATE INDEX IF NOT EXISTS feature_documents_outbox '
        'ON feature_documents(pending_sync, updated_at)');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ramadan_assistant_db');
  }
}
