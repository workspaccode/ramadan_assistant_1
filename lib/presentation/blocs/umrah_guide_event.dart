import 'package:equatable/equatable.dart';

abstract class UmrahGuideEvent extends Equatable {
  const UmrahGuideEvent();

  @override
  List<Object> get props => [];
}

class LoadUmrahProgress extends UmrahGuideEvent {}

class CompleteUmrahStep extends UmrahGuideEvent {
  final int id;

  const CompleteUmrahStep(this.id);

  @override
  List<Object> get props => [id];
}

class ResetUmrahProgress extends UmrahGuideEvent {}
