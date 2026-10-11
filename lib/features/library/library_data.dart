import 'library_models.dart';

/// Typed library domain boundary; persistence stays behind the implementation.
abstract interface class LibraryData {
  Future<List<LibraryItem>> load();
  Future<void> setFavorite(String id, bool favorite);
  Future<void> addMedia(
    String id,
    LibraryMediaKind kind,
    String url,
    String label,
  );
  Future<void> removeMedia(String id, String mediaId);
}
