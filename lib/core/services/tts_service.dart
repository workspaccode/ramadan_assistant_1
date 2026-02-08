import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  /// Initialize TTS engine with default settings for Arabic
  Future<void> initialize() async {
    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(0.4); // Slow and clear
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  /// Announce Iqama with standard phrase
  Future<void> announceIqama() async {
    await _tts.setLanguage("ar-SA");
    await _tts.speak("حان الآن وقت إقامة الصلاة");
  }

  /// Announce Iqama with extended greeting
  Future<void> announceIqamaLong() async {
    await _tts.setLanguage("ar-SA");
    await _tts.speak("السلام عليكم، حان الآن وقت إقامة الصلاة");
  }

  /// Announce specific text
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
