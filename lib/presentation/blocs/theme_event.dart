abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ToggleDarkMode extends ThemeEvent {
  final bool isDarkMode;
  ToggleDarkMode(this.isDarkMode);
}
