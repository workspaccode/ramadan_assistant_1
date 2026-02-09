import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/reminders_event.dart';
import 'package:ramadan_assistant/presentation/blocs/reminders_state.dart';

class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  final AppDatabase _database;
  final AudioService _audioService = AudioService();

  RemindersBloc(this._database) : super(RemindersInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<ToggleReminder>(_onToggleReminder);
    on<UpdateReminderInterval>(_onUpdateReminderInterval);
    on<UpdateReminderRepeatCount>(_onUpdateReminderRepeatCount);
    on<AddReminder>(_onAddReminder);
    on<DeleteReminder>(_onDeleteReminder);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<RemindersState> emit,
  ) async {
    emit(RemindersLoading());
    try {
      final reminders = await _database.select(_database.reminders).get();

      // If none exist, seed with defaults using dhikr IDs
      if (reminders.isEmpty) {
        await _database
            .into(_database.reminders)
            .insert(
              RemindersCompanion.insert(
                reminderTypes: 'salawat',
                offsets: const Value('0'),
                audioPaths: const Value('zakr/saly-ala-mohamed.mp3'),
                intervalMinutes: 30,
                repeatCount: const Value(0),
                isActive: const Value(true),
              ),
            );
        final freshReminders = await _database
            .select(_database.reminders)
            .get();
        emit(RemindersLoaded(freshReminders));
      } else {
        emit(RemindersLoaded(reminders));
      }
    } catch (e) {
      emit(RemindersError(e.toString()));
    }
  }

  Future<void> _onToggleReminder(
    ToggleReminder event,
    Emitter<RemindersState> emit,
  ) async {
    try {
      // Update database
      await (_database.update(_database.reminders)
            ..where((t) => t.id.equals(event.id)))
          .write(RemindersCompanion(isActive: Value(event.isActive)));

      // Get the reminder to schedule/cancel notification
      final reminders = await (_database.select(
        _database.reminders,
      )..where((t) => t.id.equals(event.id))).get();

      if (reminders.isNotEmpty) {
        final reminder = reminders.first;
        if (event.isActive) {
          // Schedule the notification
          await NotificationService.scheduleDhikrReminder(
            id: reminder.id,
            dhikrText: reminder.reminderTypes
                .split(',')
                .firstWhere((s) => s.isNotEmpty, orElse: () => ''),
            intervalMinutes: reminder.intervalMinutes,
            audioPath: reminder.audioPaths
                ?.split(',')
                .firstWhere((s) => s.isNotEmpty, orElse: () => ''),
          );

          // Play audio preview when activating
          final audioPaths = reminder.audioPaths?.split(',') ?? [];
          if (audioPaths.isNotEmpty &&
              audioPaths
                  .firstWhere((s) => s.isNotEmpty, orElse: () => '')
                  .isNotEmpty) {
            await _audioService.playDhikr(
              audioPaths.firstWhere((s) => s.isNotEmpty, orElse: () => ''),
            );
          }
        } else {
          // Cancel the notification and stop audio
          await NotificationService.cancelNotification(reminder.id);
          await _audioService.stop();
        }
      }

      add(LoadReminders());
    } catch (e) {
      emit(RemindersError(e.toString()));
    }
  }

  Future<void> _onUpdateReminderInterval(
    UpdateReminderInterval event,
    Emitter<RemindersState> emit,
  ) async {
    try {
      // Update database
      await (_database.update(
        _database.reminders,
      )..where((t) => t.id.equals(event.id))).write(
        RemindersCompanion(intervalMinutes: Value(event.intervalMinutes)),
      );

      // Get the reminder to reschedule notification
      final reminders = await (_database.select(
        _database.reminders,
      )..where((t) => t.id.equals(event.id))).get();

      if (reminders.isNotEmpty) {
        final reminder = reminders.first;
        if (reminder.isActive) {
          // Cancel old notification and schedule new one with updated interval
          await NotificationService.cancelNotification(reminder.id);
          await NotificationService.scheduleDhikrReminder(
            id: reminder.id,
            dhikrText: reminder.reminderTypes
                .split(',')
                .firstWhere((s) => s.isNotEmpty, orElse: () => ''),
            intervalMinutes: event.intervalMinutes,
            audioPath: reminder.audioPaths
                ?.split(',')
                .firstWhere((s) => s.isNotEmpty, orElse: () => ''),
          );
        }
      }

      add(LoadReminders());
    } catch (e) {
      emit(RemindersError(e.toString()));
    }
  }

  Future<void> _onUpdateReminderRepeatCount(
    UpdateReminderRepeatCount event,
    Emitter<RemindersState> emit,
  ) async {
    try {
      await (_database.update(_database.reminders)
            ..where((t) => t.id.equals(event.id)))
          .write(RemindersCompanion(repeatCount: Value(event.repeatCount)));
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<RemindersState> emit,
  ) async {
    try {
      final id = await _database
          .into(_database.reminders)
          .insert(
            RemindersCompanion.insert(
              reminderTypes: event.reminderTypes.join(','),
              offsets: Value(event.offsets.join(',')),
              audioPaths: Value(event.audioPaths.join(',')),
              intervalMinutes: event.intervalMinutes,
              repeatCount: Value(event.repeatCount),
              isActive: const Value(true),
            ),
          );

      // Auto-schedule notification for the new reminder
      await NotificationService.scheduleDhikrReminder(
        id: id,
        dhikrText: event.reminderTypes.firstWhere(
          (s) => s.isNotEmpty,
          orElse: () => '',
        ),
        intervalMinutes: event.intervalMinutes,
        audioPath: event.audioPaths.firstWhere(
          (s) => s.isNotEmpty,
          orElse: () => '',
        ),
      );

      // Play audio preview for the first dhikr
      if (event.audioPaths.isNotEmpty &&
          event.audioPaths
              .firstWhere((s) => s.isNotEmpty, orElse: () => '')
              .isNotEmpty) {
        await _audioService.playDhikr(
          event.audioPaths.firstWhere((s) => s.isNotEmpty, orElse: () => ''),
        );
      }

      add(LoadReminders());
    } catch (e) {
      emit(RemindersError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<RemindersState> emit,
  ) async {
    try {
      // Cancel notification before deleting
      await NotificationService.cancelNotification(event.id);

      await (_database.delete(
        _database.reminders,
      )..where((t) => t.id.equals(event.id))).go();
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError(e.toString()));
    }
  }
}
