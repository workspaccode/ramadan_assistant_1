import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/data/models/dhikr_presets.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/bloc/reminders_bloc.dart';

class RemindersContent extends StatelessWidget {
  const RemindersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        title: Text(
          'reminders_title'.tr(),
          style: context.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            onPressed: () => _showAddReminderSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<RemindersBloc, RemindersState>(
        builder: (context, state) {
          if (state is RemindersInitial || state is RemindersLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state is RemindersLoaded) {
            if (state.reminders.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildReminderList(context, state.reminders);
          } else if (state is RemindersError) {
            return Center(
              child: Text('error_prefix'.tr(args: [state.message])),
            );
          }
          return Center(child: Text('something_went_wrong'.tr()));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.bell_slash, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'no_reminders'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'tap_add_dhikr'.tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
          const SizedBox(height: 30),
          CupertinoButton.filled(
            onPressed: () => _showAddReminderSheet(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.add, size: 20),
                const SizedBox(width: 8),
                Text('add_reminder'.tr()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(BuildContext context, List<Reminder> reminders) {
    final isDark = context.isDark;
    if (reminders.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final reminderTypes = reminder.reminderTypes.split(',');
        final audioPaths = reminder.audioPaths?.split(',') ?? [];

        return Dismissible(
          key: Key(reminder.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.destructiveRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.delete,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (_) {
            context.read<RemindersBloc>().add(DeleteReminder(reminder.id));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: reminder.isActive
                              ? context.primaryColor.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          color: reminder.isActive
                              ? context.primaryColor
                              : Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: reminderTypes.map((type) {
                            if (type.isEmpty) return const SizedBox.shrink();
                            final dhikr = DhikrPresets.dhikrList.firstWhere(
                              (d) => d['id'] == type,
                              orElse: () => {'arabic': type, 'translation': ''},
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                DhikrPresets.getTranslation(
                                  Map<String, String>.from(dhikr),
                                  context.locale.languageCode,
                                ),
                                style: context.titleLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      CupertinoSwitch(
                        value: reminder.isActive,
                        activeTrackColor: context.primaryColor,
                        onChanged: (value) {
                          context.read<RemindersBloc>().add(
                            ToggleReminder(reminder.id, value),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildIOSChip(
                        context,
                        CupertinoIcons.timer,
                        _localizeInterval(reminder.intervalMinutes),
                        isDark,
                      ),
                      _buildIOSChip(
                        context,
                        CupertinoIcons.repeat,
                        _localizeRepeat(reminder.repeatCount ?? 0),
                        isDark,
                      ),
                      if (audioPaths.isNotEmpty && audioPaths.first.isNotEmpty)
                        _buildIOSChip(
                          context,
                          CupertinoIcons.speaker_2_fill,
                          'audio'.tr(),
                          isDark,
                          isActive: true,
                        ),
                    ],
                  ),
                  if (reminder.isActive) ...[
                    const SizedBox(height: 12),
                    Divider(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildIOSIntervalSelector(
                            context,
                            reminder,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildIOSRepeatSelector(
                            context,
                            reminder,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIOSChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark, {
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? context.primaryColor.withValues(alpha: 0.15)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF2F2F7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive
                ? context.primaryColor
                : (isDark ? Colors.white60 : Colors.grey[600]),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? context.primaryColor
                  : (isDark ? Colors.white60 : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSIntervalSelector(
    BuildContext context,
    Reminder reminder,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'interval'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showIntervalPicker(context, reminder),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _localizeInterval(reminder.intervalMinutes),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIOSRepeatSelector(
    BuildContext context,
    Reminder reminder,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'repeat'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showRepeatPicker(context, reminder),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _localizeRepeat(reminder.repeatCount ?? 0),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showIntervalPicker(BuildContext context, Reminder reminder) {
    int selectedMinutes = reminder.intervalMinutes;
    final isDark = context.isDark;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : (Colors.grey[200] ?? Colors.grey),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'cancel'.tr(),
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'interval'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'save'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      context.read<RemindersBloc>().add(
                        UpdateReminderInterval(reminder.id, selectedMinutes),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(minutes: selectedMinutes),
                onTimerDurationChanged: (Duration duration) {
                  selectedMinutes = duration.inMinutes;
                  if (selectedMinutes < 1) selectedMinutes = 1;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepeatPicker(BuildContext context, Reminder reminder) {
    int selectedRepeat = reminder.repeatCount ?? 0;
    final isDark = context.isDark;
    final List<int> repeatOptions = [0, ...List.generate(100, (i) => i + 1)];
    int initialIndex = repeatOptions.indexOf(selectedRepeat);
    if (initialIndex < 0) initialIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : (Colors.grey[200] ?? Colors.grey),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'cancel'.tr(),
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'repeat'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'save'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      context.read<RemindersBloc>().add(
                        UpdateReminderRepeatCount(reminder.id, selectedRepeat),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedRepeat = repeatOptions[index];
                },
                children: repeatOptions.map((count) {
                  return Center(
                    child: Text(
                      count == 0 ? 'continuous'.tr() : '$count ${'times'.tr()}',
                      style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizeInterval(int minutes) {
    if (minutes < 60) return '$minutes ${'minute'.tr()}  ';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours ${'hour'.tr()}  ';
    return '$hours ${'hour'.tr()} $remainingMinutes ${'minute'.tr()}  ';
  }

  String _localizeRepeat(int count) {
    if (count == 0) return 'continuous'.tr();
    return '$count ${'times'.tr()}';
  }

  void _showAddReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (_, scrollController) => _AddReminderSheet(
          scrollController: scrollController,
          parentContext: context,
        ),
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final ScrollController scrollController;
  final BuildContext parentContext;

  const _AddReminderSheet({
    required this.scrollController,
    required this.parentContext,
  });

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final Set<String> _selectedDhikrs = {};
  Duration _selectedInterval = const Duration(minutes: 30);
  int _selectedRepeat = 0;
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'cancel'.tr(),
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'add_reminder'.tr(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _selectedDhikrs.isEmpty ? null : _addReminder,
                  child: Text(
                    'save'.tr(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _selectedDhikrs.isEmpty
                          ? Colors.grey
                          : CupertinoColors.activeBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildSectionHeader(
                  'select_dhikr_prompt'.tr(),
                  subtitle: 'select_multiple'.tr(),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                ...DhikrPresets.dhikrList.map((dhikr) {
                  final isSelected = _selectedDhikrs.contains(dhikr['id']);
                  return _buildDhikrTile(dhikr, isSelected, isDark);
                }),
                const SizedBox(height: 24),
                _buildSectionHeader('interval'.tr(), isDark: isDark),
                const SizedBox(height: 10),
                _buildIntervalPicker(isDark),
                const SizedBox(height: 24),
                _buildSectionHeader('repeat'.tr(), isDark: isDark),
                const SizedBox(height: 10),
                _buildRepeatSelector(isDark),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDhikrTile(
    Map<String, String> dhikr,
    bool isSelected,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? context.primaryColor.withValues(alpha: 0.1)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF2F2F7)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? context.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        title: Text(
          DhikrPresets.getTranslation(dhikr, context.locale.languageCode),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dhikr['arabic'] ?? '',
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.play_circle_fill),
              onPressed: () => _audioService.playDhikr(dhikr['audio']!),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: CupertinoColors.activeBlue,
              ),
          ],
        ),
        onTap: () {
          setState(() {
            if (isSelected)
              _selectedDhikrs.remove(dhikr['id']);
            else
              _selectedDhikrs.add(dhikr['id']!);
          });
        },
      ),
    );
  }

  Widget _buildIntervalPicker(bool isDark) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.hm,
        initialTimerDuration: _selectedInterval,
        onTimerDurationChanged: (val) =>
            setState(() => _selectedInterval = val),
      ),
    );
  }

  Widget _buildRepeatSelector(bool isDark) {
    final options = [0, 1, 3, 5, 10, 33, 100];
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = _selectedRepeat == opt;
        return ChoiceChip(
          label: Text(opt == 0 ? 'continuous'.tr() : '$opt ${'times'.tr()}'),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedRepeat = opt),
        );
      }).toList(),
    );
  }

  void _addReminder() {
    widget.parentContext.read<RemindersBloc>().add(
      AddReminder(
        reminderTypes: _selectedDhikrs.toList(),
        offsets: _selectedDhikrs.map((e) => "0").toList(),
        audioPaths: _selectedDhikrs
            .map(
              (id) => DhikrPresets.dhikrList.firstWhere(
                (d) => d['id'] == id,
              )['audio']!,
            )
            .toList(),
        intervalMinutes: _selectedInterval.inMinutes,
        repeatCount: _selectedRepeat,
      ),
    );
    Navigator.pop(context);
  }
}
