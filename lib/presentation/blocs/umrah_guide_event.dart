import 'package:equatable/equatable.dart';

abstract class UmrahGuideEvent extends Equatable {
  const UmrahGuideEvent();

  @override
  List<Object> get props => [];
}

class LoadUmrahProgress extends UmrahGuideEvent {}

class RetryUmrahCounterSave extends UmrahGuideEvent {}

class CompleteUmrahStep extends UmrahGuideEvent {
  final int id;

  const CompleteUmrahStep(this.id);

  @override
  List<Object> get props => [id];
}

class ResetUmrahProgress extends UmrahGuideEvent {}

class UpdateTawafCircuits extends UmrahGuideEvent {
  final int circuits;
  const UpdateTawafCircuits(this.circuits);

  @override
  List<Object> get props => [circuits];
}

class UpdateSaiLaps extends UmrahGuideEvent {
  final int laps;
  const UpdateSaiLaps(this.laps);

  @override
  List<Object> get props => [laps];
}

class UpdateMaqamToggle extends UmrahGuideEvent {
  final bool isPrayed;
  const UpdateMaqamToggle(this.isPrayed);

  @override
  List<Object> get props => [isPrayed];
}

class UpdateZamzamToggle extends UmrahGuideEvent {
  final bool isDrunk;
  const UpdateZamzamToggle(this.isDrunk);

  @override
  List<Object> get props => [isDrunk];
}

class UpdateAutoTracking extends UmrahGuideEvent {
  final bool enabled;
  const UpdateAutoTracking(this.enabled);

  @override
  List<Object> get props => [enabled];
}
