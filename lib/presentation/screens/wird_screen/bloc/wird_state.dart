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
  final int lastReadPage;
  final DateTime lastUpdated;
  final Map<String, int> todayPrayerPages;

  const WirdPlanActive({
    required this.plan,
    required this.completedPages,
    required this.lastReadPage,
    required this.lastUpdated,
    this.todayPrayerPages = const {},
  });

  double get progress => completedPages / plan.totalTargetPages;

  @override
  List<Object?> get props => [
    plan,
    completedPages,
    lastReadPage,
    lastUpdated,
    todayPrayerPages,
  ];
}

class WirdError extends WirdState {
  final String message;
  const WirdError(this.message);

  @override
  List<Object?> get props => [message];
}
