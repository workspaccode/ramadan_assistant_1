import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/models/wird_plan.dart';

abstract class WirdEvent extends Equatable {
  const WirdEvent();

  @override
  List<Object?> get props => [];
}

class LoadWirdProgress extends WirdEvent {}

class LoadWirdHistory extends WirdEvent {}

class SetWirdPlan extends WirdEvent {
  final WirdPlan plan;
  const SetWirdPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

class UpdateWirdProgress extends WirdEvent {
  final int pagesRead;
  const UpdateWirdProgress(this.pagesRead);

  @override
  List<Object?> get props => [pagesRead];
}

class UpdatePrayerProgress extends WirdEvent {
  final String prayerName;
  final int pagesRead;
  const UpdatePrayerProgress(this.prayerName, this.pagesRead);

  @override
  List<Object?> get props => [prayerName, pagesRead];
}

class SetLastReadPage extends WirdEvent {
  final int page;
  const SetLastReadPage(this.page);

  @override
  List<Object?> get props => [page];
}

class ResetWirdProgress extends WirdEvent {}
