import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract interface class LibraryMediaEngine {
  Stream<void> get completed;
  Future<void> speak(String text, String language);
  Future<void> play(Uri url);
  Future<void> stop();
  Future<void> dispose();
}

class DeviceLibraryMediaEngine implements LibraryMediaEngine {
  final _completed = StreamController<void>.broadcast();
  AudioPlayer? _player;
  FlutterTts? _tts;
  StreamSubscription<void>? _audioCompletion;
  StreamSubscription<PlayerState>? _audioState;
  bool _disposed = false;
  int _generation = 0;
  @override
  Stream<void> get completed => _completed.stream;

  void _finished() {
    if (!_disposed) _completed.add(null);
  }

  void _failed() {
    if (!_disposed) _completed.addError(StateError('Playback failed'));
  }

  @override
  Future<void> speak(String text, String language) async {
    if (_disposed) return;
    final generation = _generation;
    final tts = _tts ??= FlutterTts();
    await tts.awaitSpeakCompletion(false);
    if (_disposed || generation != _generation) return;
    tts.setCompletionHandler(_finished);
    tts.setCancelHandler(_finished);
    tts.setErrorHandler((_) => _failed());
    final result = await tts.setLanguage(language);
    if (_disposed || generation != _generation) return;
    if (result == 0 || result == -1) {
      throw StateError('Voice language unavailable');
    }
    await tts.setSpeechRate(.45);
    if (_disposed || generation != _generation) return;
    final started = await tts.speak(text);
    if (started == 0 || started == -1) throw StateError('Voice unavailable');
  }

  @override
  Future<void> play(Uri url) async {
    if (_disposed) return;
    final generation = _generation;
    final player = _player ??= AudioPlayer();
    _audioCompletion ??= player.onPlayerComplete.listen(
      (_) => _finished(),
      onError: (_) => _failed(),
    );
    _audioState ??= player.onPlayerStateChanged.listen(
      (_) {},
      onError: (_) {
        _failed();
      },
    );
    await player.play(UrlSource(url.toString()));
    if (_disposed || generation != _generation) await player.stop();
  }

  @override
  Future<void> stop() async {
    _generation++;
    Object? error;
    try {
      await _player?.stop();
    } catch (caught) {
      error = caught;
    }
    try {
      await _tts?.stop();
    } catch (caught) {
      error ??= caught;
    }
    if (error != null) throw StateError('Playback could not stop');
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    try {
      await stop();
    } catch (_) {
      /* Teardown remains safe. */
    }
    try {
      await _audioCompletion?.cancel();
      await _audioState?.cancel();
    } catch (_) {
      /* Plugin unavailable. */
    }
    try {
      await _player?.dispose();
    } catch (_) {
      /* Plugin unavailable. */
    }
    await _completed.close();
  }
}

class LibraryPlaybackState {
  const LibraryPlaybackState({
    this.active = false,
    this.busy = false,
    this.failed = false,
  });
  final bool active, busy, failed;
}

class LibraryPlaybackCubit extends Cubit<LibraryPlaybackState> {
  LibraryPlaybackCubit(this.engine) : super(const LibraryPlaybackState()) {
    _completion = engine.completed.listen(
      (_) {
        if (!isClosed && !_disposing && !state.busy && !state.failed) {
          emit(const LibraryPlaybackState());
        }
      },
      onError: (_) {
        if (!isClosed && !_disposing) {
          _generation++;
          emit(const LibraryPlaybackState(failed: true));
        }
      },
    );
  }
  final LibraryMediaEngine engine;
  late final StreamSubscription<void> _completion;
  Future<void> _queue = Future.value();
  int _generation = 0;
  bool _disposing = false;

  Future<void> _operate(Future<void> Function()? start) {
    final generation = ++_generation;
    if (isClosed || _disposing) return Future.value();
    emit(LibraryPlaybackState(active: state.active, busy: true));
    _queue = _queue.then((_) async {
      try {
        await engine.stop();
        if (generation != _generation || _disposing) return;
        if (start != null) await start();
        if (!isClosed && generation == _generation) {
          emit(LibraryPlaybackState(active: start != null));
        }
      } catch (_) {
        if (!isClosed && generation == _generation) {
          emit(const LibraryPlaybackState(failed: true));
        }
      }
    });
    return _queue;
  }

  Future<void> speak(String text, String language) =>
      _operate(() => engine.speak(text, language));
  Future<void> play(Uri url) => _operate(() => engine.play(url));
  Future<void> stop() async {
    if (isClosed || _disposing) return;
    final generation = ++_generation;
    try {
      await engine.stop();
      if (!isClosed && generation == _generation) {
        emit(const LibraryPlaybackState());
      }
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(const LibraryPlaybackState(failed: true));
      }
    }
  }

  @override
  Future<void> close() async {
    _disposing = true;
    _generation++;
    try {
      await _completion.cancel();
    } catch (_) {
      /* Keep teardown safe. */
    }
    try {
      await engine.dispose();
    } catch (_) {
      /* Keep teardown safe. */
    }
    return super.close();
  }
}
