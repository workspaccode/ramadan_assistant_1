import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/models/wird_plan.dart';

abstract class WirdState extends Equatable {
  const WirdState();

  @override
  List<Object?> get props => [];
}

class WirdInitial extends WirdState {}

class WirdLoading extends WirdState {}

class WirdNoPlan extends WirdState {}

class WirdPlanActive extends WirdState {
  final WirdPlan plan;
  final int completedPages;
  final DateTime lastUpdated;

  const WirdPlanActive({
    required this.plan,
    required this.completedPages,
    required this.lastUpdated,
  });

  double get progress => completedPages / plan.totalTargetPages;

  @override
  List<Object?> get props => [plan, completedPages, lastUpdated];
}

class WirdError extends WirdState {
  final String message;
  const WirdError(this.message);

  @override
  List<Object?> get props => [message];
}
