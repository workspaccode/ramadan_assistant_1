import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

/// Atomic local records. Sync acknowledgements never clear a newer local edit.
class DriftDocumentStore implements DocumentStore {
  DriftDocumentStore(this.database, {AppClock? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase database;
  final AppClock _clock;

  StoredDocument _decode(FeatureDocument row) => StoredDocument(
    namespace: row.namespace,
    id: row.documentId,
    data: Map<String, Object?>.unmodifiable(
      (jsonDecode(row.payload) as Map).cast<String, Object?>(),
    ),
    revision: row.revision,
    schemaVersion: row.payloadVersion,
    updatedAt: row.updatedAt.toUtc(),
    sortKey: row.sortKey,
    pendingSync: row.pendingSync,
    deletedAt: row.deletedAt?.toUtc(),
  );

  void _validateKey(String namespace, String id) {
    if (namespace.isEmpty ||
        id.isEmpty ||
        namespace.length > 100 ||
        id.length > 200) {
      throw ArgumentError('A valid namespace and record ID are required');
    }
  }

  SimpleSelectStatement<$FeatureDocumentsTable, FeatureDocument> _query(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  }) {
    if (namespace.isEmpty || (limit != null && limit < 1)) {
      throw ArgumentError('Invalid record query');
    }
    final query = database.select(database.featureDocuments)
      ..where((row) => row.namespace.equals(namespace));
    if (!includeDeleted) query.where((row) => row.deletedAt.isNull());
    if (fromSortKey != null) {
      query.where((row) => row.sortKey.isBiggerOrEqualValue(fromSortKey));
    }
    if (toSortKey != null) {
      query.where((row) => row.sortKey.isSmallerOrEqualValue(toSortKey));
    }
    query.orderBy([
      (row) => OrderingTerm.asc(row.sortKey),
      (row) => OrderingTerm.asc(row.documentId),
    ]);
    if (limit != null) query.limit(limit);
    return query;
  }

  @override
  Future<StoredDocument?> get(String namespace, String id) async {
    _validateKey(namespace, id);
    final query = database.select(database.featureDocuments)
      ..where(
        (row) => row.namespace.equals(namespace) & row.documentId.equals(id),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _decode(row);
  }

  @override
  Future<List<StoredDocument>> list(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  }) async => (await _query(
    namespace,
    includeDeleted: includeDeleted,
    fromSortKey: fromSortKey,
    toSortKey: toSortKey,
    limit: limit,
  ).get()).map(_decode).toList(growable: false);

  @override
  Stream<List<StoredDocument>> watch(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  }) => _query(
    namespace,
    includeDeleted: includeDeleted,
    fromSortKey: fromSortKey,
    toSortKey: toSortKey,
    limit: limit,
  ).watch().map((rows) => rows.map(_decode).toList(growable: false));

  @override
  Future<StoredDocument> upsert(
    String namespace,
    String id,
    Map<String, Object?> data, {
    String? sortKey,
    int schemaVersion = 1,
    int? expectedRevision,
  }) async {
    _validateKey(namespace, id);
    if (schemaVersion < 1) throw ArgumentError('Invalid schema version');
    // Encoding before the transaction prevents unsupported payloads entering SQL.
    final payload = jsonEncode(data);
    return transaction(() async {
      final previous = await get(namespace, id);
      if (expectedRevision != null &&
          (previous?.revision ?? 0) != expectedRevision) {
        throw DocumentConflict(namespace, id);
      }
      final now = _clock().toUtc();
      final revision = (previous?.revision ?? 0) + 1;
      await database
          .into(database.featureDocuments)
          .insertOnConflictUpdate(
            FeatureDocumentsCompanion.insert(
              namespace: namespace,
              documentId: id,
              payload: payload,
              revision: revision,
              payloadVersion: Value(schemaVersion),
              updatedAt: now,
              sortKey: Value(sortKey),
              deletedAt: const Value(null),
              pendingSync: const Value(true),
            ),
          );
      return StoredDocument(
        namespace: namespace,
        id: id,
        data: Map<String, Object?>.unmodifiable(
          (jsonDecode(payload) as Map).cast<String, Object?>(),
        ),
        revision: revision,
        updatedAt: now,
        sortKey: sortKey,
        schemaVersion: schemaVersion,
      );
    });
  }

  @override
  Future<void> delete(String namespace, String id) => transaction(() async {
    final previous = await get(namespace, id);
    if (previous == null || previous.isDeleted) return;
    final now = _clock().toUtc();
    final query = database.update(database.featureDocuments)
      ..where(
        (row) => row.namespace.equals(namespace) & row.documentId.equals(id),
      );
    await query.write(
      FeatureDocumentsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        revision: Value(previous.revision + 1),
        pendingSync: const Value(true),
      ),
    );
  });

  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      database.transaction(action);

  @override
  Future<List<StoredDocument>> pendingSync({int? limit}) async {
    if (limit != null && limit < 1) throw ArgumentError('Invalid batch size');
    final query = database.select(database.featureDocuments)
      ..where((row) => row.pendingSync.equals(true))
      ..orderBy([
        (row) => OrderingTerm.asc(row.updatedAt),
        (row) => OrderingTerm.asc(row.documentId),
      ]);
    if (limit != null) query.limit(limit);
    return (await query.get()).map(_decode).toList(growable: false);
  }

  @override
  Future<bool> markSynced(
    String namespace,
    String id,
    int expectedRevision,
  ) async {
    _validateKey(namespace, id);
    final query = database.update(database.featureDocuments)
      ..where(
        (row) =>
            row.namespace.equals(namespace) &
            row.documentId.equals(id) &
            row.revision.equals(expectedRevision),
      );
    return await query.write(
          const FeatureDocumentsCompanion(pendingSync: Value(false)),
        ) ==
        1;
  }
}
