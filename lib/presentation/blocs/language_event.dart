abstract class LanguageEvent {}

class LoadLanguage extends LanguageEvent {}

class UpdateLanguage extends LanguageEvent {
  final String languageCode;
  UpdateLanguage(this.languageCode);
}
