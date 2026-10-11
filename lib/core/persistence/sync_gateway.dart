import 'package:ramadan_assistant/core/persistence/document_store.dart';

/// Future authenticated server adapter: receipts must acknowledge this revision.
/// Implementations must use namespace/id/revision as an idempotency key.
abstract interface class SyncGateway {
  Future<int> upload(StoredDocument document);
}

class SyncBatchResult {
  const SyncBatchResult({
    required this.uploaded,
    required this.changedDuringUpload,
  });
  final int uploaded;
  final int changedDuringUpload;
}

/// Explicitly constructed only after a real server adapter is configured.
/// No gateway is registered in the current, local-first application.
class SyncCoordinator {
  SyncCoordinator(this.store, this.gateway);
  final DocumentStore store;
  final SyncGateway gateway;
  Future<SyncBatchResult>? _active;

  Future<SyncBatchResult> uploadPending({int limit = 100}) {
    if (limit < 1) throw ArgumentError.value(limit, 'limit');
    final existing = _active;
    if (existing != null) return existing;
    final task = _upload(limit);
    _active = task;
    return task.whenComplete(() => _active = null);
  }

  Future<SyncBatchResult> _upload(int limit) async {
    var uploaded = 0;
    var changed = 0;
    for (final document in await store.pendingSync(limit: limit)) {
      final revision = await gateway.upload(document);
      if (revision != document.revision) {
        throw StateError('Server acknowledged a different revision');
      }
      if (await store.markSynced(document.namespace, document.id, revision)) {
        uploaded++;
      } else {
        changed++;
      }
    }
    return SyncBatchResult(uploaded: uploaded, changedDuringUpload: changed);
  }
}
