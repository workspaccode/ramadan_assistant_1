import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

abstract class UmrahGuideState extends Equatable {
  const UmrahGuideState();

  @override
  List<Object> get props => [];
}

class UmrahGuideInitial extends UmrahGuideState {}

class UmrahGuideLoading extends UmrahGuideState {}

class UmrahGuideLoaded extends UmrahGuideState {
  final List<UmrahProgressData> progress;

  const UmrahGuideLoaded(this.progress);

  @override
  List<Object> get props => [progress];
}

class UmrahGuideError extends UmrahGuideState {
  final String message;

  const UmrahGuideError(this.message);

  @override
  List<Object> get props => [message];
}
