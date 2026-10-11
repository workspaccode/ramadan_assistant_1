import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';

class _CountedStream extends Stream<void> {
  _CountedStream(this.stream);
  final Stream<void> stream;
  int listeners = 0;
  @override
  StreamSubscription<void> listen(
    void Function(void)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    listeners++;
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _Player implements AudioPlayer {
  final events = StreamController<void>.broadcast();
  late final counted = _CountedStream(events.stream);
  final started = Completer<void>();
  final calls = <String>[];
  Completer<void>? playGate;
  Source? lastSource;
  bool failPlay = false;
  int disposals = 0;
  @override
  Stream<void> get onPlayerComplete => counted;
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    calls.add('play');
    lastSource = source;
    if (!started.isCompleted) started.complete();
    final gate = playGate;
    playGate = null;
    await gate?.future;
    if (failPlay) throw StateError('native player unavailable');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {
    disposals++;
    await events.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Repeated playback keeps one completion listener', () async {
    final player = _Player();
    final service = AudioService.forTesting(player);
    for (var i = 0; i < 5; i++) {
      await service.playUrl('source-$i');
    }
    expect(service.isPlaying, true);
    expect(player.counted.listeners, 1);
    player.events.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(service.isPlaying, false);
    await service.dispose();
  });
  test('Stop during pending start prevents stale playing state', () async {
    final player = _Player(), gate = Completer<void>();
    player.playGate = gate;
    final service = AudioService.forTesting(player);
    final start = service.playUrl('old');
    await player.started.future;
    final stop = service.stop();
    expect(service.isPlaying, false);
    gate.complete();
    await Future.wait([start, stop]);
    expect(service.isPlaying, false);
    expect(player.calls.last, 'stop');
    await service.dispose();
  });
  test('Newest source supersedes pending earlier source', () async {
    final player = _Player(), gate = Completer<void>();
    player.playGate = gate;
    final service = AudioService.forTesting(player);
    final old = service.playUrl('old');
    await player.started.future;
    final current = service.playUrl('current');
    gate.complete();
    await Future.wait([old, current]);
    expect(service.isPlaying, true);
    expect((player.lastSource! as UrlSource).url, 'current');
    await service.dispose();
  });
  test('Disposal during pending playback is idempotent', () async {
    final player = _Player(), gate = Completer<void>();
    player.playGate = gate;
    final service = AudioService.forTesting(player);
    final start = service.playUrl('old');
    await player.started.future;
    final disposal = service.dispose();
    gate.complete();
    await Future.wait([start, disposal]);
    await service.dispose();
    expect(service.isPlaying, false);
    expect(player.disposals, 1);
  });
  test(
    'Native playback failure leaves recoverable non-playing state',
    () async {
      final player = _Player()..failPlay = true;
      final service = AudioService.forTesting(player);
      await service.playUrl('failed');
      expect(service.isPlaying, false);
      player.failPlay = false;
      await service.playUrl('working');
      expect(service.isPlaying, true);
      await service.dispose();
    },
  );
}
