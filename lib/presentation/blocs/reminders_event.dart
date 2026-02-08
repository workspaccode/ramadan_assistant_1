import 'package:equatable/equatable.dart';

abstract class RemindersEvent extends Equatable {
  const RemindersEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends RemindersEvent {}

class ToggleReminder extends RemindersEvent {
  final int id;
  final bool isActive;

  const ToggleReminder(this.id, this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}

class UpdateReminderInterval extends RemindersEvent {
  final int id;
  final int intervalMinutes;

  const UpdateReminderInterval(this.id, this.intervalMinutes);

  @override
  List<Object?> get props => [id, intervalMinutes];
}

class UpdateReminderRepeatCount extends RemindersEvent {
  final int id;
  final int repeatCount;

  const UpdateReminderRepeatCount(this.id, this.repeatCount);

  @override
  List<Object?> get props => [id, repeatCount];
}

class AddReminder extends RemindersEvent {
  final List<String> reminderTypes;
  final List<String> offsets;
  final List<String> audioPaths;
  final int intervalMinutes;
  final int repeatCount;

  const AddReminder({
    required this.reminderTypes,
    required this.offsets,
    required this.audioPaths,
    required this.intervalMinutes,
    required this.repeatCount,
  });

  @override
  List<Object?> get props => [
    reminderTypes,
    offsets,
    audioPaths,
    intervalMinutes,
    repeatCount,
  ];
}

class DeleteReminder extends RemindersEvent {
  final int id;

  const DeleteReminder(this.id);

  @override
  List<Object?> get props => [id];
}
