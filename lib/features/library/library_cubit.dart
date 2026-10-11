import 'package:flutter_bloc/flutter_bloc.dart';
import 'library_models.dart';
import 'library_data.dart';

class LibraryState {
  const LibraryState({
    this.items = const [],
    this.loading = false,
    this.loadFailed = false,
    this.saving = false,
    this.saveFailed = false,
  });
  final List<LibraryItem> items;
  final bool loading, loadFailed, saving, saveFailed;
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this.repository) : super(const LibraryState());
  final LibraryData repository;
  int _generation = 0;
  Future<void> _queue = Future.value();

  Future<void> load() async {
    if (isClosed) return;
    final generation = ++_generation;
    emit(LibraryState(items: state.items, loading: true));
    try {
      final items = await repository.load();
      if (!isClosed && generation == _generation) {
        emit(LibraryState(items: items));
      }
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(LibraryState(items: state.items, loadFailed: true));
      }
    }
  }

  Future<bool> _save(Future<void> Function() operation) async {
    var success = false;
    final pending = _queue.then((_) async {
      if (isClosed) return;
      _generation++;
      emit(LibraryState(items: state.items, saving: true));
      try {
        await operation();
        final items = await repository.load();
        success = true;
        if (!isClosed) emit(LibraryState(items: items));
      } catch (_) {
        if (!isClosed) emit(LibraryState(items: state.items, saveFailed: true));
      }
    });
    _queue = pending;
    await pending;
    return success;
  }

  Future<bool> setFavorite(String id, bool value) =>
      _save(() => repository.setFavorite(id, value));
  Future<bool> addMedia(
    String id,
    LibraryMediaKind kind,
    String url,
    String label,
  ) => _save(() => repository.addMedia(id, kind, url, label));
  Future<bool> removeMedia(String id, String mediaId) =>
      _save(() => repository.removeMedia(id, mediaId));
}
