import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/persistence/auto_sync_service.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/http_sync_gateway.dart';
import 'package:ramadan_assistant/core/persistence/sync_gateway.dart';

class _Store implements DocumentStore {
  _Store(this.pending);
  final List<StoredDocument> pending;
  @override
  Future<List<StoredDocument>> pendingSync({int? limit}) async =>
      pending.take(limit ?? pending.length).toList();
  @override
  Future<bool> markSynced(String ns, String id, int rev) async {
    pending.removeWhere((d) => d.id == id && d.revision == rev);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Gateway implements SyncGateway {
  bool fail = false;
  int calls = 0;
  @override
  Future<int> upload(StoredDocument document) async {
    calls++;
    if (fail) throw StateError('offline');
    return document.revision;
  }
}

class _Endpoint implements SyncEndpointSource {
  _Endpoint(this.value);
  SyncEndpoint? value;
  @override
  Future<SyncEndpoint?> current() async => value;
}

StoredDocument _doc(String id) => StoredDocument(
  namespace: 'n',
  id: id,
  data: const {},
  revision: 1,
  updatedAt: DateTime(2026),
);

DocumentStore emptyStoreForTests() => _Store([]);

class OkGateway implements SyncGateway {
  @override
  Future<int> upload(StoredDocument document) async => document.revision;
}

void main() {
  late _Store store;
  late _Gateway gateway;
  late _Endpoint endpoint;
  late StreamController<bool> online;
  late AutoSyncService service;

  setUp(() {
    store = _Store([for (var i = 0; i < 5; i++) _doc('$i')]);
    gateway = _Gateway();
    endpoint = _Endpoint(const SyncEndpoint(baseUrl: 'x', token: 't'));
    online = StreamController<bool>();
    service = AutoSyncService(
      coordinator: SyncCoordinator(store, gateway),
      endpoint: endpoint,
      online: online.stream,
      batchSize: 2,
    );
  });
  tearDown(() async {
    await service.stop();
    unawaited(online.close());
  });

  test('drains all batches when connectivity returns', () async {
    service.start();
    online.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(store.pending, isEmpty);
    expect(gateway.calls, 5);
  });

  test('does nothing while offline or unconfigured', () async {
    service.start();
    online.add(false);
    endpoint.value = null;
    online.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(gateway.calls, 0);
    expect(store.pending, hasLength(5));
  });

  test('keeps data and records error when upload fails', () async {
    gateway.fail = true;
    expect(await service.syncNow(), 0);
    expect(service.lastError, isA<StateError>());
    expect(store.pending, hasLength(5));
    gateway.fail = false;
    expect(await service.syncNow(), 5);
    expect(service.lastError, isNull);
  });
}
