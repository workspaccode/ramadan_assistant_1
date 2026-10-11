import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import '../domain/planner_event.dart';
import 'planner_cubit.dart';
import 'planner_screen.dart' show plannerIssueText;

String reminderText(BuildContext context, int? minutes) => switch (minutes) {
  null => context.loc.planner_no_reminder,
  0 => context.loc.planner_at_start,
  5 => context.loc.planner_five_minutes,
  10 => context.loc.planner_ten_minutes,
  30 => context.loc.planner_thirty_minutes,
  60 => context.loc.planner_hour_before,
  1440 => context.loc.planner_day_before,
  _ => context.loc.planner_reminder_label,
};

class PlannerEventForm extends StatefulWidget {
  const PlannerEventForm({super.key, this.event, required this.day});
  final PlannerEvent? event;
  final DateTime day;
  @override
  State<PlannerEventForm> createState() => _PlannerEventFormState();
}

class _PlannerEventFormState extends State<PlannerEventForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _meet;
  late final String _id;
  late DateTime _start;
  late DateTime _end;
  int? _reminder;
  bool _ringUntilStopped = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _title = TextEditingController(text: event?.title ?? '');
    _notes = TextEditingController(text: event?.notes ?? '');
    _meet = TextEditingController(text: event?.meetUrl ?? '');
    _id = event?.id ?? context.read<PlannerCubit>().idGenerator();
    final now = context.read<PlannerCubit>().clock();
    final selectedToday = DateUtils.isSameDay(widget.day, now);
    _start =
        event?.startUtc.toLocal() ??
        (selectedToday
            ? DateTime(now.year, now.month, now.day, now.hour + 1)
            : DateTime(widget.day.year, widget.day.month, widget.day.day, 9));
    _end = event?.endUtc.toLocal() ?? _start.add(const Duration(hours: 1));
    _reminder = event?.reminderMinutes;
    _ringUntilStopped = event?.ringUntilStopped ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _meet.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool start) async {
    final value = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null || !mounted) return;
    setState(() {
      final selected = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (start) {
        final duration = _end.difference(_start);
        _start = selected;
        _end = selected.add(
          duration.isNegative ? const Duration(hours: 1) : duration,
        );
      } else {
        _end = selected;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    if (!_end.isAfter(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.planner_invalid_dates)),
      );
      return;
    }
    setState(() => _saving = true);
    final cubit = context.read<PlannerCubit>();
    final original = widget.event;
    final saved = await cubit.save(
      PlannerEvent(
        id: _id,
        title: _title.text.trim(),
        startUtc: _start.toUtc(),
        endUtc: _end.toUtc(),
        notes: _notes.text,
        reminderMinutes: _reminder,
        ringUntilStopped: _ringUntilStopped,
        meetUrl: _meet.text.trim().isEmpty ? null : _meet.text.trim(),
        notificationId: original?.notificationId ?? 0,
        revision: original?.revision ?? 0,
        deviceCalendarId: original?.deviceCalendarId,
        deviceEventId: original?.deviceEventId,
      ),
    );
    if (!mounted) return;
    if (saved) {
      Navigator.of(
        context,
      ).pop(cubit.state.events.firstWhere((event) => event.id == _id));
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PlannerCubit, PlannerState>(
    builder: (context, state) {
      final format = DateFormat.yMMMd(context.locale.languageCode).add_jm();
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.event == null
                ? context.loc.planner_add_event
                : context.loc.planner_edit,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: [
                SakinaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _title,
                        enabled: !_saving,
                        maxLength: 160,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: context.loc.planner_title_label,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.loc.planner_invalid_title
                            : null,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : () => _pickTime(true),
                        icon: const Icon(Icons.schedule),
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.loc.planner_start_label),
                            Text(format.format(_start)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : () => _pickTime(false),
                        icon: const Icon(Icons.schedule_outlined),
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.loc.planner_end_label),
                            Text(format.format(_end)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        key: ValueKey('planner-reminder-$_reminder'),
                        initialValue: _reminder ?? -1,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.loc.planner_reminder_label,
                        ),
                        items: [-1, 0, 5, 10, 30, 60, 1440]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  reminderText(
                                    context,
                                    value == -1 ? null : value,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _reminder = value == -1 ? null : value;
                                if (_reminder == null) _ringUntilStopped = false;
                              }),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.loc.planner_alarm_until_stopped),
                        subtitle: Text(context.loc.planner_alarm_description),
                        value: _ringUntilStopped,
                        onChanged: _saving ? null : (value) => setState(() {
                          _ringUntilStopped = value;
                          if (value) _reminder ??= 0;
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notes,
                        enabled: !_saving,
                        minLines: 2,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: context.loc.planner_notes_label,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SakinaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SakinaSectionTitle(
                        context.loc.planner_meet_label,
                        icon: Icons.videocam_outlined,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _meet,
                        enabled: !_saving,
                        keyboardType: TextInputType.url,
                        textDirection: ui.TextDirection.ltr,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: context.loc.planner_meet_label,
                          hintText: 'https://meet.google.com/abc-defg-hij',
                        ),
                        validator: (value) =>
                            value != null &&
                                value.trim().isNotEmpty &&
                                !isGoogleMeetLink(value)
                            ? context.loc.planner_invalid_meet
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(context.loc.planner_meet_manual_hint),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _saving
                            ? null
                            : () => context.read<PlannerCubit>().openMeet(null),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(context.loc.planner_meet_new),
                      ),
                    ],
                  ),
                ),
                if (state.issue != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      plannerIssueText(context, state.issue!),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.errorColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(context.loc.planner_save),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    },
  );
}
