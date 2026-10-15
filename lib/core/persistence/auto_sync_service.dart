import 'dart:async';

import 'package:ramadan_assistant/core/persistence/http_sync_gateway.dart';
import 'package:ramadan_assistant/core/persistence/sync_gateway.dart';

/// Emits true whenever the device regains connectivity (and once at start if
/// already online). Kept as a stream so the trigger is testable and the
/// platform plugin stays out of this layer.
typedef OnlineSignal = Stream<bool>;

/// Uploads pending local changes whenever the device is online.
/// Silent when sync is not configured; failures retry on the next signal.
class AutoSyncService {
  AutoSyncService({
    required this.coordinator,
    required this.endpoint,
    required this.online,
    this.batchSize = 100,
  });

  final SyncCoordinator coordinator;
  final SyncEndpointSource endpoint;
  final OnlineSignal online;
  final int batchSize;
  StreamSubscription<bool>? _subscription;
  Object? lastError;

  void start() {
    _subscription ??= online.where((online) => online).listen((_) => syncNow());
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Drains the pending queue; returns the number of documents uploaded.
  Future<int> syncNow() async {
    if (await endpoint.current() == null) return 0;
    var total = 0;
    try {
      while (true) {
        final batch = await coordinator.uploadPending(limit: batchSize);
        total += batch.uploaded;
        // Stop when drained, or when every doc raced with a local edit.
        if (batch.uploaded == 0) break;
      }
      lastError = null;
    } catch (error) {
      lastError = error;
    }
    return total;
  }
}
