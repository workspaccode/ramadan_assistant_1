import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('reminders_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<RemindersBloc, RemindersState>(
        builder: (context, state) {
          if (state is RemindersInitial || state is RemindersLoading) {
            return const Center(child: CircularProgressIndicator());
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
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'no_reminders'.tr(),
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            'tap_add_dhikr'.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAddReminderDialog(context),
            icon: const Icon(Icons.add),
            label: Text('add_reminder'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(BuildContext context, List<Reminder> reminders) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final reminderTypes = reminder.reminderTypes.split(',');
        final offsets =
            reminder.offsets?.split(',').map((e) => int.parse(e)).toList() ??
            [];
        final audioPaths = reminder.audioPaths?.split(',') ?? [];

        return Dismissible(
          key: Key(reminder.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            context.read<RemindersBloc>().add(DeleteReminder(reminder.id));
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show all selected dhikr
                            ...reminderTypes.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final type = entry.value;
                              final dhikr = DhikrPresets.dhikrList.firstWhere(
                                (d) => d['id'] == type,
                                orElse: () => {
                                  'arabic': type,
                                  'translation': '',
                                },
                              );
                              final offset =
                                  offsets.isNotEmpty && idx < offsets.length
                                  ? offsets[idx]
                                  : 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    if (offset > 0)
                                      Text(
                                        '+$offset\' ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        DhikrPresets.getTranslation(
                                          Map<String, String>.from(dhikr),
                                          context.locale.languageCode,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Amiri',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (reminderTypes.length > 1)
                              Text(
                                '${'interval'.tr()}: ${_localizeInterval(reminder.intervalMinutes)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminder.isActive,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          context.read<RemindersBloc>().add(
                            ToggleReminder(reminder.id, value),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.timer,
                        _localizeInterval(reminder.intervalMinutes),
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        Icons.repeat,
                        _localizeRepeat(reminder.repeatCount ?? 0),
                      ),
                    ],
                  ),
                  if (reminder.isActive) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIntervalSelector(context, reminder),
                        _buildRepeatSelector(context, reminder),
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

  String _localizeInterval(int minutes) {
    if (minutes < 60) return '$minutes ${'minute'.tr()}';
    int hours = minutes ~/ 60;
    return '$hours ${'hour'.tr()}';
  }

  String _localizeRepeat(int count) {
    if (count == 0) return 'continuous'.tr();
    return '$count ${'times'.tr()}';
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector(BuildContext context, Reminder reminder) {
    return Column(
      children: [
        Text(
          'interval'.tr(),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppTheme.secondaryColor,
              onPressed: () {
                final currentIndex = DhikrPresets.intervalOptions.indexOf(
                  reminder.intervalMinutes,
                );
                if (currentIndex > 0) {
                  context.read<RemindersBloc>().add(
                    UpdateReminderInterval(
                      reminder.id,
                      DhikrPresets.intervalOptions[currentIndex - 1],
                    ),
                  );
                }
              },
            ),
            Text(
              _localizeInterval(reminder.intervalMinutes),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.secondaryColor,
              onPressed: () {
                final currentIndex = DhikrPresets.intervalOptions.indexOf(
                  reminder.intervalMinutes,
                );
                if (currentIndex < DhikrPresets.intervalOptions.length - 1) {
                  context.read<RemindersBloc>().add(
                    UpdateReminderInterval(
                      reminder.id,
                      DhikrPresets.intervalOptions[currentIndex + 1],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatSelector(BuildContext context, Reminder reminder) {
    return Column(
      children: [
        Text(
          'repeat'.tr(),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        DropdownButton<int>(
          value: reminder.repeatCount ?? 0,
          items: DhikrPresets.repeatCountOptions
              .map(
                (count) => DropdownMenuItem(
                  value: count,
                  child: Text(_localizeRepeat(count)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<RemindersBloc>().add(
                UpdateReminderRepeatCount(reminder.id, value),
              );
            }
          },
        ),
      ],
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
  int _selectedInterval = 30;
  int _selectedRepeat = 0;
  final TextEditingController _customIntervalController =
      TextEditingController();

  @override
  void dispose() {
    _customIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'add_reminder'.tr(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Dhikr Selection with Multi-select
          Text(
            'select_dhikr_prompt'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            'select_multiple'.tr(),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: DhikrPresets.dhikrList.length,
              itemBuilder: (context, index) {
                final dhikr = DhikrPresets.dhikrList[index];
                final isSelected = _selectedDhikrs.contains(dhikr['id']);
                final offset = _dhikrOffsets[dhikr['id']] ?? 0;

                return Card(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          DhikrPresets.getTranslation(
                            Map<String, String>.from(dhikr),
                            context.locale.languageCode,
                          ),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          dhikr['translation']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.secondaryColor
                                : AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            dhikr['category']!.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDhikrs.remove(dhikr['id']);
                              _dhikrOffsets.remove(dhikr['id']);
                            } else {
                              _selectedDhikrs.add(dhikr['id']!);
                              // Auto-assign offset based on order
                              _dhikrOffsets[dhikr['id']!] =
                                  _selectedDhikrs.length * 5;
                            }
                          });
                        },
                      ),
                      // Offset configuration for multi-select
                      if (isSelected && _selectedDhikrs.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'offset_seconds'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white54
                                          : Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: (isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : Colors.grey[100]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _dhikrOffsets[dhikr['id']!] =
                                          int.tryParse(value) ?? 0;
                                    }
                                  },
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'seconds_after'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),

          // Interval Selection (Dropdown + Custom)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'interval'.tr()}:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    DropdownButton<int>(
                      value: _selectedInterval,
                      isExpanded: true,
                      items: [
                        ...DhikrPresets.intervalOptions.map(
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(_localizeInterval(i)),
                          ),
                        ),
                        DropdownMenuItem(value: -1, child: Text('custom'.tr())),
                      ],
                      onChanged: (v) {
                        if (v == -1) {
                          _showCustomIntervalDialog(context);
                        } else {
                          setState(() => _selectedInterval = v!);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'repeat'.tr()}:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    DropdownButton<int>(
                      value: _selectedRepeat,
                      isExpanded: true,
                      items: DhikrPresets.repeatCountOptions
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(_localizeRepeat(c)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRepeat = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom interval display
          if (_selectedInterval <= 0)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${'custom_interval'.tr()}: ${_customIntervalController.text} ${'minutes'.tr()}',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedDhikrs.isEmpty
                  ? null
                  : () {
                      final reminderTypes = _selectedDhikrs.toList();
                      final offsets = reminderTypes
                          .map((id) => _dhikrOffsets[id] ?? 0)
                          .toList();
                      final audioPaths = reminderTypes.map((id) {
                        final dhikr = DhikrPresets.dhikrList.firstWhere(
                          (d) => d['id'] == id,
                          orElse: () => {'audioFile': ''},
                        );
                        return dhikr['audioFile'] ?? '';
                      }).toList();

                      widget.parentContext.read<RemindersBloc>().add(
                        AddReminder(
                          reminderTypes: reminderTypes,
                          offsets: offsets.map((e) => e.toString()).toList(),
                          audioPaths: audioPaths,
                          intervalMinutes: _selectedInterval <= 0
                              ? (int.tryParse(_customIntervalController.text) ??
                                    30)
                              : _selectedInterval,
                          repeatCount: _selectedRepeat,
                        ),
                      );
                      Navigator.pop(context);
                    },
              child: Text('add_reminder'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomIntervalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('custom_interval'.tr()),
        content: TextField(
          controller: _customIntervalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'minutes'.tr(),
            hintText: '30',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedInterval =
                    int.tryParse(_customIntervalController.text) ?? 30;
              });
              Navigator.pop(ctx);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }

  String _localizeInterval(int minutes) {
    if (minutes < 60) return '$minutes ${'minute'.tr()}';
    int hours = minutes ~/ 60;
    return '$hours ${'hour'.tr()}';
  }

  String _localizeRepeat(int count) {
    if (count == 0) return 'continuous'.tr();
    return '$count ${'times'.tr()}';
  }
}
