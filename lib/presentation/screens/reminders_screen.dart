import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/core/utils/date_time_picker.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/data/models/dhikr_presets.dart';
import 'package:ramadan_assistant/presentation/blocs/reminders_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/reminders_event.dart';
import 'package:ramadan_assistant/presentation/blocs/reminders_state.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RemindersBloc(context.read<AppDatabase>())..add(LoadReminders()),
      child: const RemindersView(),
    );
  }
}

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
        elevation: 0,
        title: Text(
          'reminders_title'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
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
            print('Error: ${state.message}');
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
          // Example usage of DateTimePicker
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppTheme.primaryColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.clock, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'schedule_reminder'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            onPressed: () async {
              final selectedDate = await showIosDateTimePicker(
                context,
                initialDateTime: DateTime.now(),
              );

              if (selectedDate != null) {
                // Use the selected date for scheduling
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${selectedDate.toString()}'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              }
            },
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  // Header row with icon, dhikr names, and switch
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: reminder.isActive
                              ? AppTheme.primaryColor.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          color: reminder.isActive
                              ? AppTheme.primaryColor
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
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Amiri',
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      CupertinoSwitch(
                        value: reminder.isActive,
                        activeTrackColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          context.read<RemindersBloc>().add(
                            ToggleReminder(reminder.id, value),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info chips row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildIOSChip(
                        CupertinoIcons.timer,
                        _localizeInterval(reminder.intervalMinutes),
                        isDark,
                      ),
                      _buildIOSChip(
                        CupertinoIcons.repeat,
                        _localizeRepeat(reminder.repeatCount ?? 0),
                        isDark,
                      ),
                      if (audioPaths.isNotEmpty && audioPaths.first.isNotEmpty)
                        _buildIOSChip(
                          CupertinoIcons.speaker_2_fill,
                          'audio'.tr(),
                          isDark,
                          isActive: true,
                        ),
                    ],
                  ),
                  // Interval & Repeat selectors when active
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
    IconData icon,
    String label,
    bool isDark, {
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor.withValues(alpha: 0.15)
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
                ? AppTheme.primaryColor
                : (isDark ? Colors.white60 : Colors.grey[600]),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppTheme.primaryColor
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // Header
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
            // Picker
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(minutes: selectedMinutes),
                minuteInterval: 1,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Generate repeat options: 0 (continuous), 1-100
    final List<int> repeatOptions = [0, ...List.generate(100, (i) => i + 1)];
    int initialIndex = repeatOptions.indexOf(selectedRepeat);
    if (initialIndex < 0) initialIndex = 0;

    final controller = FixedExtentScrollController(initialItem: initialIndex);

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
            // Header
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
            // Picker
            Expanded(
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedRepeat = repeatOptions[index];
                },
                children: repeatOptions.map((count) {
                  return Center(
                    child: Text(
                      _localizeRepeat(count),
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
  final Map<String, int> _dhikrOffsets = {};
  Duration _selectedInterval = const Duration(minutes: 30);
  int _selectedRepeat = 0;
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
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

          // Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Section: Select Dhikr
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

                // Section: Interval
                _buildSectionHeader('interval'.tr(), isDark: isDark),
                const SizedBox(height: 10),
                _buildIntervalPicker(isDark),

                const SizedBox(height: 24),

                // Section: Repeat
                _buildSectionHeader('repeat'.tr(), isDark: isDark),
                const SizedBox(height: 10),
                _buildRepeatPicker(isDark),

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
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDhikrTile(
    Map<String, String> dhikr,
    bool isSelected,
    bool isDark,
  ) {
    final hasAudio = dhikr['audioFile']?.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor
            : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF2F2F7)),
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? null
            : Border.all(
                color: isDark
                    ? Colors.white12
                    : (Colors.grey[300] ?? Colors.grey),
                width: 0.5,
              ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected
                    ? CupertinoIcons.checkmark_alt
                    : CupertinoIcons.circle,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              DhikrPresets.getTranslation(
                Map<String, String>.from(dhikr),
                context.locale.languageCode,
              ),
              style: TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            subtitle: Text(
              dhikr['translation'] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? Colors.white70
                    : (isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasAudio)
                  CupertinoButton(
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(0, 0),
                    child: Icon(
                      CupertinoIcons.play_circle_fill,
                      color: isSelected
                          ? Colors.white70
                          : AppTheme.primaryColor,
                      size: 28,
                    ),
                    onPressed: () {
                      final audioFile = dhikr['audioFile'];
                      if (audioFile != null && audioFile.isNotEmpty) {
                        _audioService.playDhikr(audioFile);
                      }
                    },
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dhikr['category']?.tr() ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  final id = dhikr['id'];
                  if (id != null) {
                    _selectedDhikrs.remove(id);
                    _dhikrOffsets.remove(id);
                  }
                } else {
                  final id = dhikr['id'];
                  if (id != null) {
                    _selectedDhikrs.add(id);
                    _dhikrOffsets[id] = _selectedDhikrs.length * 5;
                  }
                }
              });
            },
          ),
          // Offset config for multi-select
          if (isSelected && _selectedDhikrs.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    'offset_seconds'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 32,
                    child: CupertinoTextField(
                      keyboardType: TextInputType.number,
                      placeholder: '0',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final id = dhikr['id'];
                          if (id != null) {
                            _dhikrOffsets[id] = int.tryParse(value) ?? 0;
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'seconds_after'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIntervalPicker(bool isDark) {
    return GestureDetector(
      onTap: () => _showCupertinoTimerPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : (Colors.grey[300] ?? Colors.grey),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.timer,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDuration(_selectedInterval),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatPicker(bool isDark) {
    return GestureDetector(
      onTap: () => _showCupertinoRepeatPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : (Colors.grey[300] ?? Colors.grey),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.repeat,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  _localizeRepeat(_selectedRepeat),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoTimerPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'save'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.copyWith(
                      bodyLarge: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      bodyMedium: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                        height: 1.1,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: _selectedInterval,
                    minuteInterval: 1,
                    backgroundColor: isDark
                        ? const Color(0xFF1C1C1E)
                        : Colors.white,
                    itemExtent: 45,
                    onTimerDurationChanged: (Duration duration) {
                      setState(() {
                        _selectedInterval = duration.inMinutes < 1
                            ? const Duration(minutes: 1)
                            : duration;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCupertinoRepeatPicker() {
    final List<int> repeatOptions = [0, ...List.generate(100, (i) => i + 1)];
    int initialIndex = repeatOptions.indexOf(_selectedRepeat);
    if (initialIndex < 0) initialIndex = 0;
    final controller = FixedExtentScrollController(initialItem: initialIndex);

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'save'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: controller,
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedRepeat = repeatOptions[index];
                    });
                  },
                  children: repeatOptions.map((count) {
                    return Center(
                      child: Text(
                        _localizeRepeat(count),
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
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '$hours ${'hour'.tr()} $minutes ${'minute'.tr()}';
    } else if (hours > 0) {
      return '$hours ${'hour'.tr()}';
    }
    return '$minutes ${'minute'.tr()}';
  }

  String _localizeRepeat(int count) {
    if (count == 0) return 'continuous'.tr();
    return '$count ${'times'.tr()}';
  }

  void _addReminder() {
    final reminderTypes = _selectedDhikrs.toList();
    final offsets = reminderTypes.map((id) => _dhikrOffsets[id] ?? 0).toList();
    final audioPaths = reminderTypes.map((id) {
      final dhikr = DhikrPresets.dhikrList.firstWhere(
        (d) => d['id'] == id,
        orElse: () => {'audioFile': ''},
      );
      return dhikr['audioFile'] ?? '';
    }).toList();

    final intervalMinutes = _selectedInterval.inMinutes < 1
        ? 1
        : _selectedInterval.inMinutes;

    widget.parentContext.read<RemindersBloc>().add(
      AddReminder(
        reminderTypes: reminderTypes,
        offsets: offsets.map((e) => e.toString()).toList(),
        audioPaths: audioPaths,
        intervalMinutes: intervalMinutes,
        repeatCount: _selectedRepeat,
      ),
    );
    Navigator.pop(context);
  }
}
