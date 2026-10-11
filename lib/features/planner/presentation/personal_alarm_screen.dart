import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class PersonalAlarmScreen extends StatefulWidget {
  const PersonalAlarmScreen({super.key, required this.alarmId, required this.title,
    required this.onStop});
  final int alarmId;
  final String title;
  final Future<bool> Function(int) onStop;
  @override
  State<PersonalAlarmScreen> createState() => _PersonalAlarmScreenState();
}

class _PersonalAlarmScreenState extends State<PersonalAlarmScreen> {
  bool _stopping = false, _stopped = false, _failed = false;
  Future<void> _stop() async {
    if (_stopping || _stopped) return;
    setState(() { _stopping = true; _failed = false; });
    var stopped = false;
    try { stopped = await widget.onStop(widget.alarmId); } catch (_) { /* Keep retry visible. */ }
    if (!mounted) return;
    if (!stopped) {
      setState(() { _stopping = false; _failed = true; });
      return;
    }
    setState(() { _stopped = true; _stopping = false; });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    if (!_stopped) unawaited(_stopAfterRemoval());
    super.dispose();
  }
  Future<void> _stopAfterRemoval() async {
    try { await widget.onStop(widget.alarmId); } catch (_) { /* Service can restore an active alarm route. */ }
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _stopped,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) unawaited(_stop());
    },
    child: Scaffold(
      appBar: AppBar(title: Text(context.loc.planner_personal_alarm)),
      bottomNavigationBar: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: FilledButton.icon(onPressed: _stopping ? null : _stop,
          icon: _stopping ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.stop_rounded),
          label: Text(context.loc.planner_alarm_stop, textAlign: TextAlign.center),
          style: FilledButton.styleFrom(minimumSize: const Size(48, 56))),
      )),
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24), child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SakinaCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.alarm_rounded, size: 64, color: context.primaryColor),
            const SizedBox(height: 24),
            Text(widget.title, textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(context.loc.planner_alarm_description, textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge),
            if (_failed) ...[const SizedBox(height: 16),
              Semantics(liveRegion: true, child: Text(context.loc.planner_alarm_stop_failed,
                textAlign: TextAlign.center, style: TextStyle(color: context.errorColor)))],
          ])),
        ),
      ))),
    ),
  );
}
