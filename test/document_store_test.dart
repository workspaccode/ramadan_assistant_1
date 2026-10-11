import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/core/persistence/sync_gateway.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

class _Gateway implements SyncGateway {
  final Future<int> Function(StoredDocument) action;
  _Gateway(this.action);
  @override
  Future<int> upload(StoredDocument document) => action(document);
}

void main() {
  late AppDatabase database;
  late DriftDocumentStore store;
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    store = DriftDocumentStore(database);
  });
  tearDown(() => database.close());

  test(
    'version five migration preserves prayer logs and adds feature storage',
    () async {
      await database.close();
      database = AppDatabase.forTesting(
        NativeDatabase.memory(
          setup: (sql) {
            sql.execute(
              'CREATE TABLE prayer_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'prayer_name TEXT NOT NULL, prayer_time INTEGER NOT NULL, '
              'completed INTEGER NOT NULL DEFAULT 0, completed_at INTEGER)',
            );
            sql.execute(
              "INSERT INTO prayer_logs(prayer_name, prayer_time, completed) VALUES ('fajr', 1000, 1)",
            );
            sql.execute('PRAGMA user_version=5');
          },
        ),
      );
      final migrated = DriftDocumentStore(database);
      await migrated.upsert('planner', 'old', {'title': 'Retained'});
      expect(
        (await database.select(database.prayerLogs).get()).single.prayerName,
        'fajr',
      );
      expect((await migrated.get('planner', 'old'))!.data['title'], 'Retained');
      expect(
        (await database.customSelect('PRAGMA user_version').get()).single
            .read<int>('user_version'),
        6,
      );
    },
  );

  test(
    'stale writes conflict, deleted documents remain in durable outbox',
    () async {
      final record = await store.upsert('tasks', 'a', {
        'name': 'A',
      }, expectedRevision: 0);
      expect(record.revision, 1);
      await store.upsert('tasks', 'a', {'name': 'B'}, expectedRevision: 1);
      await expectLater(
        store.upsert('tasks', 'a', {'name': 'Lost'}, expectedRevision: 1),
        throwsA(isA<DocumentConflict>()),
      );
      await store.delete('tasks', 'a');
      expect(await store.list('tasks'), isEmpty);
      final tombstone = (await store.pendingSync()).single;
      expect(tombstone.isDeleted, isTrue);
      expect(tombstone.revision, 3);
      expect(tombstone.data['name'], 'B');
      expect(await store.markSynced('tasks', 'a', 2), isFalse);
      expect(await store.markSynced('tasks', 'a', 3), isTrue);
      expect(await store.pendingSync(), isEmpty);
    },
  );

  test(
    'transaction failure rolls back records and watch ranges are isolated',
    () async {
      final stream = store.watch(
        'worship',
        fromSortKey: '2026-10-11',
        toSortKey: '2026-10-11',
      );
      final matching = stream.firstWhere((rows) => rows.length == 1);
      await expectLater(
        store.transaction(() async {
          await store.upsert('worship', 'bad', {
            'done': true,
          }, sortKey: '2026-10-11');
          throw StateError('fail');
        }),
        throwsStateError,
      );
      expect(await store.get('worship', 'bad'), isNull);
      await store.upsert('worship', 'tomorrow', {
        'done': false,
      }, sortKey: '2026-10-12');
      await store.upsert('worship', 'today', {
        'done': true,
      }, sortKey: '2026-10-11');
      expect((await matching).single.id, 'today');
    },
  );

  test('unsupported payload is rejected before mutation', () async {
    await expectLater(
      store.upsert('tasks', 'bad', {'value': Object()}),
      throwsA(isA<JsonUnsupportedObjectError>()),
    );
    expect(await store.list('tasks'), isEmpty);
  });

  test('sync keeps newer edits and deduplicates concurrent uploads', () async {
    await store.upsert('tasks', 'a', {'name': 'A'});
    final entered = Completer<void>();
    final release = Completer<void>();
    var calls = 0;
    final coordinator = SyncCoordinator(
      store,
      _Gateway((document) async {
        calls++;
        entered.complete();
        await release.future;
        return document.revision;
      }),
    );
    final first = coordinator.uploadPending();
    final second = coordinator.uploadPending();
    await entered.future;
    await store.upsert('tasks', 'a', {'name': 'B'});
    release.complete();
    expect((await first).changedDuringUpload, 1);
    expect((await second).uploaded, 0);
    expect(calls, 1);
    expect((await store.pendingSync()).single.revision, 2);
  });

  test(
    'failed server receipt never drops pending changes and retry can succeed',
    () async {
      await store.upsert('tasks', 'a', {'name': 'A'});
      var fail = true;
      final coordinator = SyncCoordinator(
        store,
        _Gateway((document) async {
          if (fail) throw StateError('offline');
          return document.revision;
        }),
      );
      await expectLater(coordinator.uploadPending(), throwsStateError);
      expect(await store.pendingSync(), hasLength(1));
      fail = false;
      expect((await coordinator.uploadPending()).uploaded, 1);
      expect(await store.pendingSync(), isEmpty);
    },
  );
}
