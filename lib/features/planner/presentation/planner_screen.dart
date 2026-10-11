import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import '../data/planner_platform_adapters.dart';
import '../domain/planner_event.dart';
import '../domain/planner_ports.dart';
import 'planner_cubit.dart';
import 'planner_event_form.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({
    super.key,
    required this.repository,
    required this.reminders,
    required this.calendar,
    this.links = const UrlMeetingLinkPort(),
  });
  final PlannerRepository repository;
  final PlannerReminderPort reminders;
  final DeviceCalendarPort calendar;
  final MeetingLinkPort links;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => PlannerCubit(
      repository: repository,
      reminders: reminders,
      calendar: calendar,
      links: links,
    )..load(),
    child: const _PlannerView(),
  );
}

String plannerIssueText(
  BuildContext context,
  PlannerIssue issue,
) => switch (issue) {
  PlannerIssue.load => context.loc.planner_load_failed,
  PlannerIssue.save => context.loc.planner_save_failed,
  PlannerIssue.delete => context.loc.planner_delete_failed,
  PlannerIssue.reminderPermission => context.loc.planner_permission_denied,
  PlannerIssue.reminderExpired => context.loc.planner_reminder_expired,
  PlannerIssue.reminderSchedule => context.loc.planner_reminder_failed,
  PlannerIssue.calendarPermission => context.loc.planner_calendar_permission,
  PlannerIssue.calendarUnavailable => context.loc.planner_calendar_unavailable,
  PlannerIssue.calendarOperation => context.loc.planner_calendar_failed,
  PlannerIssue.calendarReadOnly => context.loc.planner_calendar_read_only,
  PlannerIssue.link => context.loc.planner_meet_failed,
  PlannerIssue.title => context.loc.planner_invalid_title,
  PlannerIssue.dates => context.loc.planner_invalid_dates,
  PlannerIssue.meetingLink => context.loc.planner_invalid_meet,
};

class _PlannerView extends StatefulWidget {
  const _PlannerView();
  @override
  State<_PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<_PlannerView> {
  late DateTime _day;
  late DateTime _month;
  bool _calendarView = true;
  @override
  void initState() {
    super.initState();
    final now = context.read<PlannerCubit>().clock();
    _day = DateTime(now.year, now.month, now.day);
    _month = DateTime(now.year, now.month);
  }

  Future<void> _edit([PlannerEvent? event]) async {
    final cubit = context.read<PlannerCubit>();
    final saved = await Navigator.of(context).push<PlannerEvent>(
      MaterialPageRoute<PlannerEvent>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: PlannerEventForm(event: event, day: _day),
        ),
      ),
    );
    if (saved != null && mounted) {
      final local = saved.startUtc.toLocal();
      setState(() {
        _day = DateTime(local.year, local.month, local.day);
        _month = DateTime(local.year, local.month);
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<PlannerCubit, PlannerState>(
    listenWhen: (before, after) =>
        before.notice != after.notice && after.notice != null,
    listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (state.notice!) {
          PlannerNotice.saved => context.loc.planner_event_saved,
          PlannerNotice.deleted => context.loc.planner_event_deleted,
          PlannerNotice.calendarSaved => context.loc.planner_calendar_saved,
        }),
      ),
    ),
    builder: (context, state) {
      final endDay = DateTime(_day.year, _day.month, _day.day + 1);
      final events = _calendarView
          ? state.events
                .where(
                  (event) =>
                      event.startUtc.toLocal().isBefore(endDay) &&
                      event.endUtc.toLocal().isAfter(_day),
                )
                .toList()
          : state.events;
      return Scaffold(
        appBar: AppBar(title: Text(context.loc.planner_title)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: state.busy ? null : _edit,
          icon: const Icon(Icons.add_rounded),
          label: Text(context.loc.planner_add_event),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.list(
                  children: [
                    SakinaCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: context.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.loc.planner_title,
                                  style: context.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(context.loc.planner_local_hint),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(context.loc.planner_calendar_view),
                          selected: _calendarView,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: _calendarView
                                ? context.onPrimaryColor
                                : context.ramadanTheme.textPrimary,
                          ),
                          onSelected: (_) =>
                              setState(() => _calendarView = true),
                        ),
                        ChoiceChip(
                          label: Text(context.loc.planner_list_view),
                          selected: !_calendarView,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: !_calendarView
                                ? context.onPrimaryColor
                                : context.ramadanTheme.textPrimary,
                          ),
                          onSelected: (_) =>
                              setState(() => _calendarView = false),
                        ),
                      ],
                    ),
                    if (_calendarView) ...[
                      const SizedBox(height: 16),
                      SakinaCard(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CalendarDatePicker(
                          key: ValueKey(_day),
                          initialDate: _day,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100, 12, 31),
                          onDateChanged: (day) => setState(() => _day = day),
                          onDisplayedMonthChanged: (month) {
                            _month = month;
                            if (state.selectedCalendar != null) {
                              context.read<PlannerCubit>().selectCalendar(
                                state.selectedCalendar!,
                                month,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SakinaSectionTitle(
                      _calendarView
                          ? DateFormat.yMMMMd(
                              context.locale.languageCode,
                            ).format(_day)
                          : context.loc.planner_list_view,
                      icon: Icons.event_note_rounded,
                    ),
                    if (state.loading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (state.issue != null) ...[
                      const SizedBox(height: 16),
                      SakinaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              plannerIssueText(context, state.issue!),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.errorColor,
                              ),
                              semanticsLabel: plannerIssueText(
                                context,
                                state.issue!,
                              ),
                            ),
                            if (state.reminderRetryId != null)
                              TextButton.icon(
                                onPressed: state.busy
                                    ? null
                                    : () => context
                                          .read<PlannerCubit>()
                                          .retryReminder(
                                            state.reminderRetryId!,
                                          ),
                                icon: const Icon(
                                  Icons.notifications_active_outlined,
                                ),
                                label: Text(context.loc.planner_reminder_retry),
                              ),
                            if (state.issue == PlannerIssue.load)
                              TextButton(
                                onPressed: state.busy
                                    ? null
                                    : context.read<PlannerCubit>().load,
                                child: Text(context.loc.planner_retry),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (!state.loading && events.isEmpty) ...[
                      const SizedBox(height: 16),
                      SakinaCard(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              size: 48,
                              color: context.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.loc.planner_empty_title,
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.loc.planner_empty_body,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: state.busy ? null : _edit,
                              icon: const Icon(Icons.add),
                              label: Text(context.loc.planner_add_event),
                            ),
                          ],
                        ),
                      ),
                    ],
                    for (final event in events) ...[
                      const SizedBox(height: 12),
                      _EventCard(
                        event: event,
                        state: state,
                        onEdit: () => _edit(event),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _DeviceCalendarCard(state: state, month: _month),
                    const SizedBox(height: 112),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.state,
    required this.onEdit,
  });
  final PlannerEvent event;
  final PlannerState state;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMMd(context.locale.languageCode).add_jm();
    final cubit = context.read<PlannerCubit>();
    return SakinaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(event.title, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${format.format(event.startUtc.toLocal())} – ${format.format(event.endUtc.toLocal())}',
          ),
          if (event.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(event.notes),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SakinaBadge(
                context.loc.planner_local_event,
                icon: Icons.phone_android,
              ),
              if (event.reminderMinutes != null)
                SakinaBadge(
                  reminderText(context, event.reminderMinutes),
                  gold: true,
                  icon: event.ringUntilStopped ? Icons.alarm_rounded : Icons.notifications_outlined,
                ),
              if (event.ringUntilStopped)
                SakinaBadge(context.loc.planner_alarm_until_stopped, icon: Icons.repeat_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: state.busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.loc.planner_edit),
              ),
              if (event.meetUrl != null)
                TextButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => cubit.openMeet(event.meetUrl),
                  icon: const Icon(Icons.videocam_outlined),
                  label: Text(context.loc.planner_meet_open),
                ),
              if (event.reminderMinutes != null)
                TextButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => cubit.retryReminder(event.id),
                  icon: const Icon(Icons.notification_add_outlined),
                  label: Text(context.loc.planner_reminder_retry),
                ),
              if (state.selectedCalendar?.writable == true)
                TextButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => cubit.exportEvent(event, state.selectedCalendar!),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(context.loc.planner_calendar_export),
                ),
              TextButton.icon(
                onPressed: state.busy
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(context.loc.planner_delete),
                            content: Text(context.loc.planner_delete_confirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(context.loc.planner_cancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(context.loc.planner_delete),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) await cubit.delete(event);
                      },
                icon: const Icon(Icons.delete_outline),
                label: Text(context.loc.planner_delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceCalendarCard extends StatelessWidget {
  const _DeviceCalendarCard({required this.state, required this.month});
  final PlannerState state;
  final DateTime month;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlannerCubit>();
    return SakinaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SakinaSectionTitle(
            context.loc.planner_calendar_connect,
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 8),
          Text(context.loc.planner_calendar_hint),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: state.busy ? null : cubit.connectCalendar,
            icon: const Icon(Icons.link),
            label: Text(context.loc.planner_calendar_connect),
          ),
          if (state.calendarConnected && state.calendars.isEmpty) ...[
            const SizedBox(height: 16),
            Text(context.loc.planner_calendar_no_accounts),
          ],
          if (state.calendars.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: state.selectedCalendar?.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.loc.planner_calendar_account,
              ),
              items: state.calendars
                  .map(
                    (calendar) => DropdownMenuItem(
                      value: calendar.id,
                      child: Text(
                        '${calendar.name} · ${calendar.account}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: state.busy
                  ? null
                  : (id) {
                      if (id != null) {
                        cubit.selectCalendar(
                          state.calendars.firstWhere((item) => item.id == id),
                          month,
                        );
                      }
                    },
            ),
          ],
          if (state.selectedCalendar != null && state.deviceEvents.isEmpty) ...[
            const SizedBox(height: 16),
            Text(context.loc.planner_calendar_empty),
          ],
          for (final event in state.deviceEvents) ...[
            const Divider(height: 32),
            Text(event.title, style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd(
                context.locale.languageCode,
              ).add_jm().format(event.startUtc.toLocal()),
            ),
            TextButton.icon(
              onPressed: state.busy ? null : () => cubit.importEvent(event),
              icon: const Icon(Icons.download_outlined),
              label: Text(context.loc.planner_calendar_import),
            ),
          ],
        ],
      ),
    );
  }
}
