import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

abstract class RemindersState extends Equatable {
  const RemindersState();

  @override
  List<Object> get props => [];
}

class RemindersInitial extends RemindersState {}

class RemindersLoading extends RemindersState {}

class RemindersLoaded extends RemindersState {
  final List<Reminder> reminders;

  const RemindersLoaded(this.reminders);

  @override
  List<Object> get props => [reminders];
}

class RemindersError extends RemindersState {
  final String message;

  const RemindersError(this.message);

  @override
  List<Object> get props => [message];
}
