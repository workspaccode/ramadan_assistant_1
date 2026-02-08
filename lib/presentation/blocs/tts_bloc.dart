import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Supported languages for TTS
class TTSLanguages {
  static const String arabic = 'ar';
  static const String english = 'en-US';
  static const String urdu = 'ur-PK';

  static String getLanguageCode(String langCode) {
    switch (langCode) {
      case 'ar':
        return arabic;
      case 'ur':
        return urdu;
      case 'en':
      default:
        return english;
    }
  }
}

abstract class TTSEvent extends Equatable {
  const TTSEvent();
  @override
  List<Object?> get props => [];
}

class SpeakText extends TTSEvent {
  final String text;
  final String language;

  const SpeakText(this.text, {this.language = 'ar'});

  @override
  List<Object?> get props => [text, language];
}

class SpeakUrdu extends TTSEvent {
  final String text;
  const SpeakUrdu(this.text);
  @override
  List<Object?> get props => [text];
}

class SpeakArabic extends TTSEvent {
  final String text;
  const SpeakArabic(this.text);
  @override
  List<Object?> get props => [text];
}

class StopSpeaking extends TTSEvent {}

class SetLanguage extends TTSEvent {
  final String language;
  const SetLanguage(this.language);
  @override
  List<Object?> get props => [language];
}

abstract class TTSState extends Equatable {
  const TTSState();
  @override
  List<Object?> get props => [];
}

class TTSInitial extends TTSState {}

class TTSSpeaking extends TTSState {
  final String language;
  const TTSSpeaking({this.language = 'ar'});
  @override
  List<Object?> get props => [language];
}

class TTSStopped extends TTSState {}

class TTSBloc extends Bloc<TTSEvent, TTSState> {
  final FlutterTts _flutterTts = FlutterTts();
  String _currentLanguage = TTSLanguages.arabic;

  TTSBloc() : super(TTSInitial()) {
    on<SpeakText>(_onSpeakText);
    on<SpeakUrdu>(_onSpeakUrdu);
    on<SpeakArabic>(_onSpeakArabic);
    on<StopSpeaking>(_onStopSpeaking);
    on<SetLanguage>(_onSetLanguage);

    _initialize();
  }

  Future<void> _initialize() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4); // Slower for clarity
    await _flutterTts.setPitch(1.0);

    // Listen for completion
    _flutterTts.setCompletionHandler(() {
      add(StopSpeaking());
    });
  }

  Future<void> _onSpeakText(SpeakText event, Emitter<TTSState> emit) async {
    emit(TTSSpeaking(language: event.language));
    final langCode = TTSLanguages.getLanguageCode(event.language);
    await _flutterTts.setLanguage(langCode);
    await _flutterTts.speak(event.text);
  }

  Future<void> _onSpeakUrdu(SpeakUrdu event, Emitter<TTSState> emit) async {
    emit(const TTSSpeaking(language: 'ur'));
    await _flutterTts.setLanguage(TTSLanguages.urdu);
    await _flutterTts.speak(event.text);
  }

  Future<void> _onSpeakArabic(SpeakArabic event, Emitter<TTSState> emit) async {
    emit(const TTSSpeaking(language: 'ar'));
    await _flutterTts.setLanguage(TTSLanguages.arabic);
    await _flutterTts.speak(event.text);
  }

  Future<void> _onStopSpeaking(
    StopSpeaking event,
    Emitter<TTSState> emit,
  ) async {
    await _flutterTts.stop();
    emit(TTSStopped());
  }

  Future<void> _onSetLanguage(SetLanguage event, Emitter<TTSState> emit) async {
    _currentLanguage = TTSLanguages.getLanguageCode(event.language);
    await _flutterTts.setLanguage(_currentLanguage);
  }

  @override
  Future<void> close() {
    _flutterTts.stop();
    return super.close();
  }
}
