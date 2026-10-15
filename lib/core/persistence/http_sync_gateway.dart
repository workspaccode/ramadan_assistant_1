import 'package:dio/dio.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/sync_gateway.dart';

/// Where and how to reach the user's own sync server.
class SyncEndpoint {
  const SyncEndpoint({required this.baseUrl, required this.token});
  final String baseUrl;
  final String token;
}

/// Supplies the endpoint, or null while the user has not enabled syncing.
abstract interface class SyncEndpointSource {
  Future<SyncEndpoint?> current();
}

/// PUTs one document revision. The server must answer `{"revision": <int>}`;
/// the idempotency key makes retries after a lost response safe.
class HttpSyncGateway implements SyncGateway {
  HttpSyncGateway(this._dio, this._endpoint);
  final Dio _dio;
  final SyncEndpointSource _endpoint;

  @override
  Future<int> upload(StoredDocument document) async {
    final endpoint = await _endpoint.current();
    if (endpoint == null) throw const SyncNotConfigured();
    final response = await _dio.put<Map<String, dynamic>>(
      '${endpoint.baseUrl}/documents/${document.namespace}/${document.id}',
      data: {
        'revision': document.revision,
        'schemaVersion': document.schemaVersion,
        'updatedAt': document.updatedAt.toUtc().toIso8601String(),
        'deleted': document.isDeleted,
        'data': document.isDeleted ? null : document.data,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${endpoint.token}',
          'Idempotency-Key':
              '${document.namespace}/${document.id}/${document.revision}',
        },
      ),
    );
    final revision = response.data?['revision'];
    if (revision is! int) {
      throw StateError('Server receipt is missing a revision');
    }
    return revision;
  }
}

class SyncNotConfigured implements Exception {
  const SyncNotConfigured();
  @override
  String toString() => 'Sync is not configured';
}
