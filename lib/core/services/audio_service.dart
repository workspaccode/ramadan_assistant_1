import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for playing Islamic audio files (Adhan, Iqama, Dhikr)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Stream to listen when a track finishes playing
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  /// Play Adhan audio
  Future<void> playAdhan({bool isFajr = false, String? customSound}) async {
    final prefs = await SharedPreferences.getInstance();
    final fileName =
        customSound ??
        (isFajr
            ? (prefs.getString('fajr_adhan_sound') ?? 'azanfajr.mp3')
            : (prefs.getString('other_adhan_sound') ?? 'azan8.mp3'));
    await _playAsset(fileName);
  }

  /// Play Iqama reminder sound
  Future<void> playIqamaReminder({
    bool isFajr = false,
    String? customSound,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final fileName =
        customSound ??
        (isFajr
            ? (prefs.getString('fajr_iqama_sound') ?? 'MakkahIQamah.mp3')
            : (prefs.getString('other_iqama_sound') ?? 'MakkahIQamah.mp3'));
    await _playAsset(fileName);
  }

  /// Play Tasbih click sound
  Future<void> playTasbihClick() async {
    await _playAsset('tasbih_click.wav');
  }

  /// Play Tasbih complete sound (when goal reached)
  Future<void> playTasbihComplete() async {
    await _playAsset('tasbih_complete.mp3');
  }

  /// Play Dhikr audio by file name
  Future<void> playDhikr(String audioFileName) async {
    await _playAsset(audioFileName);
  }

  /// Play Dhikr audio in background (for notifications)
  @pragma('vm:entry-point')
  static Future<void> playDhikrInBackground(String audioFileName) async {
    try {
      final audioPlayer = AudioPlayer();
      await audioPlayer.play(AssetSource('audio/$audioFileName'));

      audioPlayer.onPlayerComplete.listen((_) {
        audioPlayer.dispose();
      });

      Future.delayed(const Duration(seconds: 30), () {
        audioPlayer.dispose();
      });
    } catch (e) {
      debugPrint('Error playing background audio $audioFileName: $e');
    }
  }

  /// Play Adhan audio in background (for notifications)
  @pragma('vm:entry-point')
  static Future<void> playAdhanInBackground({bool isFajr = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fileName = isFajr
          ? (prefs.getString('fajr_adhan_sound') ?? 'azanfajr.mp3')
          : (prefs.getString('other_adhan_sound') ?? 'azan8.mp3');

      final audioPlayer = AudioPlayer();
      await audioPlayer.play(AssetSource('audio/$fileName'));

      audioPlayer.onPlayerComplete.listen((_) {
        audioPlayer.dispose();
      });

      Future.delayed(const Duration(seconds: 60), () {
        audioPlayer.dispose();
      });
    } catch (e) {
      debugPrint('Error playing background adhan: $e');
    }
  }

  /// Play Iqama reminder sound in background
  @pragma('vm:entry-point')
  static Future<void> playIqamaReminderInBackground({
    bool isFajr = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fileName = isFajr
          ? (prefs.getString('fajr_iqama_sound') ?? 'MakkahIQamah.mp3')
          : (prefs.getString('other_iqama_sound') ?? 'MakkahIQamah.mp3');

      final audioPlayer = AudioPlayer();
      await audioPlayer.play(AssetSource('audio/$fileName'));

      audioPlayer.onPlayerComplete.listen((_) {
        audioPlayer.dispose();
      });

      Future.delayed(const Duration(seconds: 15), () {
        audioPlayer.dispose();
      });
    } catch (e) {
      debugPrint('Error playing background iqama reminder: $e');
    }
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

  /// Play audio from a URL
  Future<void> playUrl(String url) async {
    try {
      await stop();
      await _audioPlayer.play(UrlSource(url));
      _isPlaying = true;

      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      debugPrint('Error playing url $url: $e');
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
