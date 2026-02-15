import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  final double fontSizeMultiplier;
  final String? colorPaletteId;

  const ThemeLoaded({
    required this.isDarkMode,
    this.fontSizeMultiplier = 1.0,
    this.colorPaletteId,
  });

  @override
  List<Object?> get props => [isDarkMode, fontSizeMultiplier, colorPaletteId];
}
