import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'library_catalog.dart';
import 'library_data.dart';
import 'library_models.dart';

class LibraryRepository implements LibraryData {
  LibraryRepository(this.store, {List<LibraryItem>? catalog})
    : catalog = List.unmodifiable(catalog ?? libraryCatalog);
  final DocumentStore store;
  final List<LibraryItem> catalog;
  static const namespace = 'library_preferences';

  @override
  Future<List<LibraryItem>> load() async {
    final documents = await store.list(namespace);
    final preferences = {
      for (final item in documents)
        if (!item.isDeleted) item.id: item.data,
    };
    return List.unmodifiable(
      catalog.map((item) {
        final data = preferences[item.id];
        final media = data?['media'];
        return item.withPreferences(
          favorite: data?['favorite'] == true,
          media: media is List
              ? media
                    .map(LibraryMedia.fromJson)
                    .whereType<LibraryMedia>()
                    .toList()
              : [],
        );
      }),
    );
  }

  Future<void> _update(
    String id,
    Map<String, Object?> Function(Map<String, Object?>) change,
  ) async {
    if (!catalog.any((item) => item.id == id)) {
      throw ArgumentError.value(id, 'id');
    }
    await store.transaction(() async {
      final previous = await store.get(namespace, id);
      final payload = change(
        previous == null || previous.isDeleted ? {} : previous.data,
      );
      await store.upsert(
        namespace,
        id,
        payload,
        sortKey: id,
        expectedRevision: previous?.revision ?? 0,
      );
    });
  }

  @override
  Future<void> setFavorite(String id, bool favorite) =>
      _update(id, (data) => {...data, 'favorite': favorite});

  @override
  Future<void> addMedia(
    String id,
    LibraryMediaKind kind,
    String url,
    String label,
  ) async {
    final uri = libraryHttpsUri(url);
    if (uri == null) throw const FormatException('Invalid HTTPS media link');
    final media = LibraryMedia(
      id: newRecordId(),
      kind: kind,
      url: uri,
      label: label.trim(),
    );
    await _update(id, (data) {
      final previous = data['media'] is List
          ? (data['media'] as List)
                .map(LibraryMedia.fromJson)
                .whereType<LibraryMedia>()
                .toList()
          : <LibraryMedia>[];
      if (!previous.any((value) => value.kind == kind && value.url == uri)) {
        previous.add(media);
      }
      return {
        ...data,
        'media': previous.map((value) => value.toJson()).toList(),
      };
    });
  }

  @override
  Future<void> removeMedia(String id, String mediaId) => _update(id, (data) {
    final previous = data['media'] is List
        ? (data['media'] as List)
              .map(LibraryMedia.fromJson)
              .whereType<LibraryMedia>()
        : <LibraryMedia>[];
    return {
      ...data,
      'media': previous
          .where((value) => value.id != mediaId)
          .map((value) => value.toJson())
          .toList(),
    };
  });
}
