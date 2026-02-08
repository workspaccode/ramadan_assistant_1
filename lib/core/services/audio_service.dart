import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing Islamic audio files (Adhan, Iqama, Dhikr)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Play Adhan audio
  Future<void> playAdhan({bool isFajr = false}) async {
    final fileName = isFajr ? 'azanfajr.mp3' : 'azan8.mp3';
    await _playAsset(fileName);
  }

  /// Play Iqama reminder sound
  Future<void> playIqamaReminder() async {
    await _playAsset('iqama_reminder.mp3');
  }

  /// Play Tasbih click sound
  Future<void> playTasbihClick() async {
    await _playAsset('tasbih_click.mp3');
  }

  /// Play Tasbih complete sound (when goal reached)
  Future<void> playTasbihComplete() async {
    await _playAsset('tasbih_complete.mp3');
  }

  /// Play Dhikr audio by file name
  Future<void> playDhikr(String audioFileName) async {
    await _playAsset(audioFileName);
  }

  /// Play asset file
  Future<void> _playAsset(String fileName) async {
    try {
      await stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      _isPlaying = true;

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      debugPrint('Error playing audio $fileName: $e');
      _isPlaying = false;
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  /// Pause current playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
