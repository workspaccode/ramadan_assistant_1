import 'package:equatable/equatable.dart';

abstract class TasbihEvent extends Equatable {
  const TasbihEvent();

  @override
  List<Object> get props => [];
}

class IncrementCounter extends TasbihEvent {}

class ResetCounter extends TasbihEvent {}

class ChangeDhikr extends TasbihEvent {
  final String dhikr;
  final int target;

  const ChangeDhikr(this.dhikr, this.target);

  @override
  List<Object> get props => [dhikr, target];
}
