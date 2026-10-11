import 'dart:math';

/// Persistence contract used by feature data repositories, never by widgets.
/// Payloads must contain JSON-compatible primitives; domain models remain typed.
class StoredDocument {
  const StoredDocument({
    required this.namespace,
    required this.id,
    required this.data,
    required this.revision,
    required this.updatedAt,
    this.sortKey,
    this.schemaVersion = 1,
    this.pendingSync = true,
    this.deletedAt,
  });
  final String namespace;
  final String id;
  final Map<String, Object?> data;
  final int revision;
  final DateTime updatedAt;
  final String? sortKey;
  final int schemaVersion;
  final bool pendingSync;
  final DateTime? deletedAt;
  bool get isDeleted => deletedAt != null;
}

class DocumentConflict implements Exception {
  const DocumentConflict(this.namespace, this.id);
  final String namespace;
  final String id;
  @override
  String toString() =>
      'Document changed before it could be saved: $namespace/$id';
}

abstract interface class DocumentStore {
  Future<StoredDocument?> get(String namespace, String id);
  Future<List<StoredDocument>> list(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  });
  Stream<List<StoredDocument>> watch(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  });
  Future<StoredDocument> upsert(
    String namespace,
    String id,
    Map<String, Object?> data, {
    String? sortKey,
    int schemaVersion = 1,
    int? expectedRevision,
  });
  Future<void> delete(String namespace, String id);
  Future<T> transaction<T>(Future<T> Function() action);
  Future<List<StoredDocument>> pendingSync({int? limit});
  Future<bool> markSynced(String namespace, String id, int expectedRevision);
}

typedef AppClock = DateTime Function();
typedef RecordIdGenerator = String Function();
String newRecordId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
