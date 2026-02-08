import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String calculationMethod;
  final String madhab;
  final int iqamaDelayMinutes;
  final String iqamaSystem;
  final String iqamaPreset;

  const SettingsLoaded({
    required this.calculationMethod,
    required this.madhab,
    required this.iqamaDelayMinutes,
    required this.iqamaSystem,
    required this.iqamaPreset,
  });

  @override
  List<Object?> get props => [
    calculationMethod,
    madhab,
    iqamaDelayMinutes,
    iqamaSystem,
    iqamaPreset,
  ];

  SettingsLoaded copyWith({
    String? calculationMethod,
    String? madhab,
    int? iqamaDelayMinutes,
    String? iqamaSystem,
    String? iqamaPreset,
  }) {
    return SettingsLoaded(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      iqamaDelayMinutes: iqamaDelayMinutes ?? this.iqamaDelayMinutes,
      iqamaSystem: iqamaSystem ?? this.iqamaSystem,
      iqamaPreset: iqamaPreset ?? this.iqamaPreset,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
