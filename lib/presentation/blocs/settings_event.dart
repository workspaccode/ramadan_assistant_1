import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateCalculationMethod extends SettingsEvent {
  final String method;
  const UpdateCalculationMethod(this.method);
  @override
  List<Object?> get props => [method];
}

class UpdateMadhab extends SettingsEvent {
  final String madhab;
  const UpdateMadhab(this.madhab);
  @override
  List<Object?> get props => [madhab];
}

class UpdateIqamaDelay extends SettingsEvent {
  final int delayMinutes;
  const UpdateIqamaDelay(this.delayMinutes);
  @override
  List<Object?> get props => [delayMinutes];
}

class UpdateIqamaSystem extends SettingsEvent {
  final String system; // 'manual' or 'preset'
  const UpdateIqamaSystem(this.system);
  @override
  List<Object?> get props => [system];
}

class UpdateIqamaPreset extends SettingsEvent {
  final String preset; // 'saudi' or 'egypt'
  const UpdateIqamaPreset(this.preset);
  @override
  List<Object?> get props => [preset];
}
