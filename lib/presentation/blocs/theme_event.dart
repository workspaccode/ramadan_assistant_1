abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ToggleDarkMode extends ThemeEvent {
  final bool isDarkMode;
  ToggleDarkMode(this.isDarkMode);
}

class UpdateFontSizeMultiplier extends ThemeEvent {
  final double multiplier;
  UpdateFontSizeMultiplier(this.multiplier);
}

class UpdateColorPalette extends ThemeEvent {
  final String paletteId;
  UpdateColorPalette(this.paletteId);
}
