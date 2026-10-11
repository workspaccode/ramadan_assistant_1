import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../presentation/widgets/sakina_ui.dart';
import '../domain/worship_models.dart';
import 'worship_cubit.dart';
import 'worship_strings.dart';

int? parseWorshipNumber(String value) {
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var normalized = value.trim().replaceAll('−', '-');
  for (var digit = 0; digit < 10; digit++) {
    normalized = normalized
        .replaceAll(eastern[digit], '$digit')
        .replaceAll(persian[digit], '$digit');
  }
  return RegExp(r'^[+-]?\d+$').hasMatch(normalized)
      ? int.tryParse(normalized)
      : null;
}

class WorshipScreen extends StatefulWidget {
  const WorshipScreen({super.key, required this.cubit});
  final WorshipCubit cubit;
  @override
  State<WorshipScreen> createState() => _WorshipScreenState();
}

class _WorshipScreenState extends State<WorshipScreen>
    with WidgetsBindingObserver {
  Timer? _rollover;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.cubit.load();
    _rollover = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted &&
          widget.cubit.followsToday &&
          widget.cubit.state.snapshot?.day !=
              worshipDay(widget.cubit.repository.clock())) {
        widget.cubit.load();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.cubit.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rollover?.cancel();
    super.dispose();
  }

  void _sheet(Widget child) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => child,
  );
  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: widget.cubit,
    child: BlocConsumer<WorshipCubit, WorshipState>(
      listener: (context, state) {
        final message = state.errorKey ?? state.noticeKey;
        if (!state.busy && message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(worshipText(context, message)),
              action:
                  message == 'worship_refresh_failed' ||
                      message == 'worship_load_failed'
                  ? SnackBarAction(
                      label: worshipText(context, 'worship_retry'),
                      onPressed: widget.cubit.load,
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(title: Text(worshipText(context, 'worship_title'))),
          body: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: worshipText(context, 'worship_today')),
                  Tab(text: worshipText(context, 'worship_wird')),
                  Tab(text: worshipText(context, 'worship_nawafil')),
                  Tab(text: worshipText(context, 'worship_qada')),
                ],
              ),
              if (state.snapshot != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.snapshot!.day,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: worshipText(context, 'worship_choose_date'),
                        onPressed: state.busy
                            ? null
                            : () async {
                                final today = DateUtils.dateOnly(
                                  widget.cubit.repository.clock(),
                                );
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.parse(
                                    state.snapshot!.day,
                                  ),
                                  firstDate: DateTime(1),
                                  lastDate: today,
                                );
                                if (mounted && selected != null) {
                                  await widget.cubit.load(
                                    day: worshipDay(selected),
                                  );
                                }
                              },
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ],
                  ),
                ),

              if (state.busy) const LinearProgressIndicator(),
              Expanded(
                child: state.snapshot == null
                    ? Center(
                        child: state.busy
                            ? const CircularProgressIndicator()
                            : Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      worshipText(
                                        context,
                                        'worship_load_failed',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: widget.cubit.load,
                                      icon: const Icon(Icons.refresh),
                                      label: Text(
                                        worshipText(context, 'worship_retry'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      )
                    : TabBarView(
                        children: [
                          _today(state),
                          _wird(state),
                          _voluntary(state),
                          _ledger(state),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _list(List<Widget> children) => ListView(
    padding: const EdgeInsets.all(16),
    children: children
        .expand((child) => [child, const SizedBox(height: 16)])
        .toList(),
  );

  Widget _today(WorshipState state) {
    final snapshot = state.snapshot!;
    return _list([
      SakinaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              worshipText(
                context,
                'worship_today_progress',
                args: {'count': snapshot.completedPrayers},
              ),
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: snapshot.completedPrayers / 5,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      for (final prayer in ObligatoryPrayer.values)
        SakinaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                worshipText(context, 'worship_${prayer.name}'),
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in PrayerStatus.values)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: ChoiceChip(
                        label: Text(
                          worshipText(context, 'worship_${status.name}'),
                        ),
                        selected: snapshot.status(prayer) == status,
                        selectedColor: context.primaryColor,
                        labelStyle: TextStyle(
                          color: snapshot.status(prayer) == status
                              ? context.onPrimaryColor
                              : context.primaryColor,
                        ),
                        onSelected: state.busy
                            ? null
                            : (_) => widget.cubit.recordPrayer(prayer, status),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      Text(
        worshipText(context, 'worship_manual_hint'),
        style: context.textTheme.bodySmall,
      ),
    ]);
  }

  Widget _wird(WorshipState state) {
    final snapshot = state.snapshot!;
    final plan = snapshot.plan;
    final completion = snapshot.completion;
    final start = completion?.startPage ?? plan?.nextPage;
    final end = completion?.endPage ?? plan?.endPage;
    final range = start == null || end == null
        ? null
        : end < start
        ? worshipText(
            context,
            'worship_pages_wrap_range',
            args: {
              'first': '\u2066${start == 604 ? '604' : '$start–604'}\u2069',
              'second': '\u2066${end == 1 ? '1' : '1–$end'}\u2069',
            },
          )
        : worshipText(
            context,
            'worship_pages_range',
            args: {'start': '\u2066$start', 'end': '$end\u2069'},
          );
    return _list([
      SakinaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 40,
              color: context.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              plan == null
                  ? worshipText(context, 'worship_plan_empty')
                  : range!,
              style: context.textTheme.headlineSmall,
            ),
            if (start != null && end != null && end < start) ...[
              const SizedBox(height: 8),
              Text(worshipText(context, 'worship_wrap_hint')),
            ],
            if (plan != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed:
                    state.busy ||
                        completion != null ||
                        snapshot.day !=
                            worshipDay(widget.cubit.repository.clock())
                    ? null
                    : widget.cubit.completeWird,
                icon: Icon(
                  completion != null ? Icons.check_circle : Icons.check_rounded,
                ),
                label: Text(
                  worshipText(
                    context,
                    completion != null
                        ? 'worship_completed'
                        : 'worship_confirm_reading',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.busy ? null : widget.cubit.openReader,
                icon: const Icon(Icons.open_in_new),
                label: Text(worshipText(context, 'worship_open_reader')),
              ),
              if (plan.reminderMinute != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${worshipText(context, 'worship_reminder')}: ${TimeOfDay(hour: plan.reminderMinute! ~/ 60, minute: plan.reminderMinute! % 60).format(context)}',
                ),
              ],
            ],
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: state.busy
                  ? null
                  : () => _sheet(_PlanSheet(cubit: widget.cubit)),
              icon: const Icon(Icons.tune),
              label: Text(worshipText(context, 'worship_edit_plan')),
            ),
          ],
        ),
      ),
      Text(
        worshipText(context, 'worship_manual_hint'),
        style: context.textTheme.bodySmall,
      ),
    ]);
  }

  Widget _voluntary(WorshipState state) => _list([
    FilledButton.icon(
      onPressed: state.busy
          ? null
          : () => _sheet(_VoluntarySheet(cubit: widget.cubit)),
      icon: const Icon(Icons.add),
      label: Text(worshipText(context, 'worship_add_voluntary')),
    ),
    if (state.snapshot!.voluntary.isEmpty)
      SakinaCard(child: Text(worshipText(context, 'worship_no_logs'))),
    for (final log in state.snapshot!.voluntary)
      SakinaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              worshipText(context, 'worship_${log.kind.name}'),
              style: context.textTheme.titleMedium,
            ),
            if (log.kind != VoluntaryWorship.fasting)
              Text(
                worshipText(
                  context,
                  'worship_units_value',
                  args: {'count': log.units},
                ),
              ),
            Text(log.day, style: context.textTheme.bodySmall),
            if (log.note.isNotEmpty) Text(log.note),
          ],
        ),
      ),
  ]);

  Widget _ledger(WorshipState state) {
    final snapshot = state.snapshot!;
    return _list([
      SakinaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worshipText(context, 'worship_qada_hint')),
            const SizedBox(height: 16),
            if (!snapshot.ledgerInitialized)
              FilledButton.icon(
                onPressed: state.busy
                    ? null
                    : () => _sheet(_OpeningSheet(cubit: widget.cubit)),
                icon: const Icon(Icons.edit_note),
                label: Text(worshipText(context, 'worship_opening')),
              )
            else
              Text(
                worshipText(
                  context,
                  'worship_remaining',
                  args: {'count': snapshot.totalRemaining},
                ),
                style: context.textTheme.headlineSmall,
              ),
          ],
        ),
      ),
      if (snapshot.ledgerInitialized)
        for (final prayer in ObligatoryPrayer.values)
          SakinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worshipText(context, 'worship_${prayer.name}'),
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  worshipText(
                    context,
                    'worship_remaining',
                    args: {'count': snapshot.remaining(prayer)},
                  ),
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: state.busy || snapshot.remaining(prayer) == 0
                          ? null
                          : () => _sheet(
                              _LedgerSheet(
                                cubit: widget.cubit,
                                prayer: prayer,
                                adjustment: false,
                              ),
                            ),
                      icon: const Icon(Icons.done),
                      label: Text(worshipText(context, 'worship_pay')),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.busy
                          ? null
                          : () => _sheet(
                              _LedgerSheet(
                                cubit: widget.cubit,
                                prayer: prayer,
                                adjustment: true,
                              ),
                            ),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(worshipText(context, 'worship_adjust')),
                    ),
                  ],
                ),
              ],
            ),
          ),
      if (snapshot.ledger.isNotEmpty)
        Text(
          worshipText(context, 'worship_history'),
          style: context.textTheme.titleLarge,
        ),
      for (final event in snapshot.ledger)
        SakinaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${worshipText(context, 'worship_${event.prayer.name}')} · ${worshipText(context, switch (event.kind) {
                  LedgerKind.opening => 'worship_opening_event',
                  LedgerKind.payment => 'worship_payment',
                  LedgerKind.adjustment => 'worship_adjustment',
                })}',
                style: context.textTheme.titleMedium,
              ),
              Text(
                '${event.delta > 0 ? '+' : ''}${event.delta} · ${worshipDay(event.createdAt.toLocal())}',
              ),
              if (event.note.isNotEmpty) Text(event.note),
            ],
          ),
        ),
    ]);
  }
}

abstract class _EditorState<T extends StatefulWidget> extends State<T> {
  bool saving = false;
  String? error;
  Future<void> submit(
    Future<bool> Function() action,
    WorshipCubit cubit,
  ) async {
    if (saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    final saved = await action();
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() {
        saving = false;
        error = cubit.state.errorKey ?? 'worship_save_failed';
      });
    }
  }

  Widget editor(String title, List<Widget> fields, VoidCallback save) =>
      Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          24,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                worshipText(context, title),
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...fields.expand((field) => [field, const SizedBox(height: 16)]),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    worshipText(context, error!),
                    style: TextStyle(color: context.errorColor),
                  ),
                ),
              FilledButton(
                onPressed: saving ? null : save,
                child: Text(worshipText(context, 'worship_save')),
              ),
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: Text(worshipText(context, 'worship_cancel')),
              ),
            ],
          ),
        ),
      );
  Widget numberField(
    TextEditingController controller,
    String key, {
    bool signed = false,
  }) => TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(signed: signed),
    decoration: InputDecoration(labelText: worshipText(context, key)),
    enabled: !saving,
  );
}

class _PlanSheet extends StatefulWidget {
  const _PlanSheet({required this.cubit});
  final WorshipCubit cubit;
  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends _EditorState<_PlanSheet> {
  late final TextEditingController pages = TextEditingController(
    text: '${widget.cubit.state.snapshot?.plan?.dailyPages ?? 2}',
  );
  late final TextEditingController start = TextEditingController(
    text: '${widget.cubit.state.snapshot?.plan?.nextPage ?? 1}',
  );
  TimeOfDay? reminder;
  String? appId;
  @override
  void initState() {
    super.initState();
    final plan = widget.cubit.state.snapshot?.plan;
    if (plan?.reminderMinute != null) {
      reminder = TimeOfDay(
        hour: plan!.reminderMinute! ~/ 60,
        minute: plan.reminderMinute! % 60,
      );
    }
    final apps = widget.cubit.state.readerApps;
    appId = apps.any((app) => app.id == plan?.readerAppId)
        ? plan?.readerAppId
        : apps.firstOrNull?.id;
  }

  @override
  void dispose() {
    pages.dispose();
    start.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => editor(
    'worship_edit_plan',
    [
      numberField(pages, 'worship_daily_pages'),
      numberField(start, 'worship_start_page'),
      DropdownButtonFormField<String>(
        initialValue: appId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: worshipText(context, 'worship_reader'),
          helperText: widget.cubit.state.readerApps.isEmpty
              ? worshipText(context, 'worship_no_reader')
              : null,
        ),
        items: widget.cubit.state.readerApps
            .map(
              (app) => DropdownMenuItem(
                value: app.id,
                child: Text(app.label, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: saving ? null : (value) => setState(() => appId = value),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(worshipText(context, 'worship_reminder')),
        value: reminder != null,
        onChanged: saving
            ? null
            : (enabled) async {
                if (!enabled) {
                  setState(() => reminder = null);
                  return;
                }
                final selected = await showTimePicker(
                  context: context,
                  initialTime: reminder ?? const TimeOfDay(hour: 20, minute: 0),
                );
                if (mounted && selected != null) {
                  setState(() => reminder = selected);
                }
              },
      ),
      if (reminder != null)
        OutlinedButton(
          onPressed: saving
              ? null
              : () async {
                  final selected = await showTimePicker(
                    context: context,
                    initialTime: reminder!,
                  );
                  if (mounted && selected != null) {
                    setState(() => reminder = selected);
                  }
                },
          child: Text(reminder!.format(context)),
        ),
    ],
    () {
      final count = parseWorshipNumber(pages.text);
      final next = parseWorshipNumber(start.text);
      if (count == null || next == null) {
        setState(() => error = 'worship_invalid_plan');
        return;
      }
      submit(
        () => widget.cubit.savePlan(
          WirdPlan(
            dailyPages: count,
            nextPage: next,
            readerAppId: appId,
            reminderMinute: reminder == null
                ? null
                : reminder!.hour * 60 + reminder!.minute,
          ),
          reminderTitle: worshipText(context, 'worship_wird'),
          reminderBody: worshipText(context, 'worship_reminder_body'),
        ),
        widget.cubit,
      );
    },
  );
}

class _OpeningSheet extends StatefulWidget {
  const _OpeningSheet({required this.cubit});
  final WorshipCubit cubit;
  @override
  State<_OpeningSheet> createState() => _OpeningSheetState();
}

class _OpeningSheetState extends _EditorState<_OpeningSheet> {
  final counts = {
    for (final prayer in ObligatoryPrayer.values)
      prayer: TextEditingController(text: '0'),
  };
  @override
  void dispose() {
    for (final controller in counts.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => editor(
    'worship_opening',
    [
      Text(worshipText(context, 'worship_opening_hint')),
      for (final prayer in ObligatoryPrayer.values)
        numberField(counts[prayer]!, 'worship_${prayer.name}'),
    ],
    () {
      final parsed = <ObligatoryPrayer, int>{};
      for (final entry in counts.entries) {
        final value = parseWorshipNumber(entry.value.text);
        if (value == null) {
          setState(() => error = 'worship_invalid_count');
          return;
        }
        parsed[entry.key] = value;
      }
      submit(() => widget.cubit.initializeLedger(parsed), widget.cubit);
    },
  );
}

class _LedgerSheet extends StatefulWidget {
  const _LedgerSheet({
    required this.cubit,
    required this.prayer,
    required this.adjustment,
  });
  final WorshipCubit cubit;
  final ObligatoryPrayer prayer;
  final bool adjustment;
  @override
  State<_LedgerSheet> createState() => _LedgerSheetState();
}

class _LedgerSheetState extends _EditorState<_LedgerSheet> {
  final count = TextEditingController(text: '1');
  final note = TextEditingController();
  @override
  void dispose() {
    count.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => editor(
    widget.adjustment ? 'worship_adjust' : 'worship_pay',
    [
      Text(
        worshipText(context, 'worship_${widget.prayer.name}'),
        style: context.textTheme.titleLarge,
      ),
      numberField(
        count,
        widget.adjustment ? 'worship_adjust_delta' : 'worship_count',
        signed: widget.adjustment,
      ),
      TextField(
        controller: note,
        maxLength: 500,
        minLines: 1,
        maxLines: 3,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: worshipText(
            context,
            widget.adjustment ? 'worship_reason' : 'worship_note',
          ),
        ),
      ),
    ],
    () {
      final value = parseWorshipNumber(count.text);
      if (value == null) {
        setState(() => error = 'worship_invalid_count');
        return;
      }
      submit(
        () => widget.adjustment
            ? widget.cubit.adjustLedger(widget.prayer, value, note: note.text)
            : widget.cubit.payQada(widget.prayer, value, note: note.text),
        widget.cubit,
      );
    },
  );
}

class _VoluntarySheet extends StatefulWidget {
  const _VoluntarySheet({required this.cubit});
  final WorshipCubit cubit;
  @override
  State<_VoluntarySheet> createState() => _VoluntarySheetState();
}

class _VoluntarySheetState extends _EditorState<_VoluntarySheet> {
  VoluntaryWorship kind = VoluntaryWorship.duha;
  final units = TextEditingController(text: '2');
  final note = TextEditingController();
  @override
  void dispose() {
    units.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => editor(
    'worship_add_voluntary',
    [
      DropdownButtonFormField<VoluntaryWorship>(
        initialValue: kind,
        isExpanded: true,
        items: VoluntaryWorship.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(worshipText(context, 'worship_${value.name}')),
              ),
            )
            .toList(),
        onChanged: saving
            ? null
            : (value) => setState(() {
                kind = value!;
                units.text = kind == VoluntaryWorship.fasting ? '1' : '2';
              }),
      ),
      if (kind != VoluntaryWorship.fasting) numberField(units, 'worship_units'),
      TextField(
        controller: note,
        maxLength: 500,
        minLines: 1,
        maxLines: 3,
        enabled: !saving,
        decoration: InputDecoration(
          labelText: worshipText(context, 'worship_note'),
        ),
      ),
    ],
    () {
      final count = parseWorshipNumber(units.text);
      if (count == null) {
        setState(() => error = 'worship_invalid_units');
        return;
      }
      submit(
        () => widget.cubit.addVoluntary(kind, count, note: note.text),
        widget.cubit,
      );
    },
  );
}
