import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// One foreground player; each new control request supersedes older work.
class AudioService {
  static final AudioService _instance = AudioService._withPlayer(AudioPlayer());
  factory AudioService() => _instance;
  AudioService._withPlayer(this._audioPlayer) {
    _completion = _audioPlayer.onPlayerComplete.listen(
      (_) {
        if (!_disposed) _isPlaying = false;
      },
      onError: (Object error, StackTrace stack) {
        _isPlaying = false;
        debugPrint('Audio playback stream failed: $error');
      },
    );
  }
  @visibleForTesting
  AudioService.forTesting(AudioPlayer player) : this._withPlayer(player);

  final AudioPlayer _audioPlayer;
  late final StreamSubscription<void> _completion;
  Future<void> _queue = Future.value();
  bool _isPlaying = false;
  bool _disposed = false;
  int _generation = 0;

  bool get isPlaying => _isPlaying;
  int get playbackGeneration => _generation;
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  int _newRequest() {
    _isPlaying = false;
    return ++_generation;
  }

  Future<void> _enqueue(Future<void> Function() action, {int? generation}) {
    final next = _queue.then((_) async {
      if (_disposed || (generation != null && generation != _generation)) {
        return;
      }
      try {
        await action();
      } catch (error) {
        if (generation == _generation) _isPlaying = false;
        debugPrint('Audio operation failed: $error');
      }
    });
    _queue = next;
    return next;
  }

  Future<void> _play(Source source, {int? request}) {
    final generation = request ?? _newRequest();
    return _enqueue(() async {
      await _audioPlayer.stop();
      if (_disposed || generation != _generation) return;
      await _audioPlayer.play(source);
      if (!_disposed && generation == _generation) _isPlaying = true;
    }, generation: generation);
  }

  Future<void> playTasbihClick() =>
      _play(AssetSource('audio/tasbih_click.wav'));
  Future<void> playTasbihComplete() =>
      _play(AssetSource('audio/tasbih_complete.mp3'));
  Future<void> playDhikr(String file) => _play(AssetSource('audio/$file'));
  Future<void> playUrl(String url) => _play(UrlSource(url));

  Future<void> stop() {
    final request = _newRequest();
    return _enqueue(_audioPlayer.stop, generation: request);
  }

  Future<void> pause() {
    final request = _newRequest();
    return _enqueue(_audioPlayer.pause, generation: request);
  }

  Future<void> resume() {
    final request = _newRequest();
    return _enqueue(() async {
      await _audioPlayer.resume();
      if (!_disposed && request == _generation) _isPlaying = true;
    }, generation: request);
  }

  Future<void> setVolume(double volume) =>
      _enqueue(() => _audioPlayer.setVolume(volume.clamp(0.0, 1.0)));

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _newRequest();
    await _completion.cancel();
    await _queue;
    try {
      await _audioPlayer.dispose();
    } catch (error) {
      debugPrint('Audio cleanup failed: $error');
    }
  }

  /// A temporary background player has exactly one cleanup path, including
  /// playback errors and the maximum-duration fallback.
  static Future<void> _playInBackground(String file, Duration maximum) async {
    final player = AudioPlayer();
    Timer? timeout;
    StreamSubscription<void>? completion;
    var finished = false;
    Future<void> finish() async {
      if (finished) return;
      finished = true;
      timeout?.cancel();
      await completion?.cancel();
      try {
        await player.dispose();
      } catch (error) {
        debugPrint('Background audio cleanup failed: $error');
      }
    }

    try {
      completion = player.onPlayerComplete.listen(
        (_) => unawaited(finish()),
        onError: (Object error, StackTrace stack) {
          debugPrint('Background audio stream failed: $error');
          unawaited(finish());
        },
      );
      await player.play(AssetSource('audio/$file'));
      if (!finished) timeout = Timer(maximum, () => unawaited(finish()));
    } catch (error) {
      debugPrint('Background audio failed: $error');
      await finish();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> playDhikrInBackground(String file) =>
      _playInBackground(file, const Duration(seconds: 30));
}
