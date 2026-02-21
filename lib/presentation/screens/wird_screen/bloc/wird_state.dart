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
  final DateTime? selectedDate;
  final Map<String, int> selectedDayPrayerPages;

  const WirdPlanActive({
    required this.plan,
    required this.completedPages,
    required this.lastReadPage,
    required this.lastUpdated,
    this.todayPrayerPages = const {},
    this.selectedDate,
    this.selectedDayPrayerPages = const {},
  });

  DateTime get activeDate => selectedDate ?? DateTime.now();

  double get progress => completedPages / plan.totalTargetPages;

  @override
  List<Object?> get props => [
    plan,
    completedPages,
    lastReadPage,
    lastUpdated,
    todayPrayerPages,
    selectedDate,
    selectedDayPrayerPages,
  ];
}

class WirdHistoryLoaded extends WirdPlanActive {
  final List<dynamic> historyLogs;
  final int currentStreak;
  final int totalPagesRead;
  final double averagePagesPerDay;
  final Map<DateTime, int> readingDays;

  const WirdHistoryLoaded({
    required super.plan,
    required super.completedPages,
    required super.lastReadPage,
    required super.lastUpdated,
    super.todayPrayerPages,
    super.selectedDate,
    super.selectedDayPrayerPages,
    required this.historyLogs,
    required this.currentStreak,
    required this.totalPagesRead,
    required this.averagePagesPerDay,
    required this.readingDays,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    historyLogs,
    currentStreak,
    totalPagesRead,
    averagePagesPerDay,
    readingDays,
  ];
}

class WirdError extends WirdState {
  final String message;
  const WirdError(this.message);

  @override
  List<Object?> get props => [message];
}
