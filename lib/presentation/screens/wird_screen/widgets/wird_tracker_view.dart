import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';

class WirdTrackerView extends StatelessWidget {
  final WirdPlanActive state;

  const WirdTrackerView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(context, theme),
          const SizedBox(height: 24),
          _buildCurrentReadingCard(context, theme),
          const SizedBox(height: 24),
          Text(
            'wird_daily_log'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDailyLogGrid(context, theme),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickDateAndLog(context),
                  icon: const Icon(Icons.history_edu),
                  label: Text('wird_log_past_day'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary.withOpacity(0.1),
                    foregroundColor: theme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.primary, width: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _showResetDialog(context),
                  icon: Icon(
                    Icons.settings_backup_restore,
                    color: theme.textDim,
                  ),
                  label: Text(
                    'wird_change_plan'.tr(),
                    style: TextStyle(color: theme.textDim),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, RamadanThemeExtension theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'wird_total_progress'.tr(),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(state.progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 10,
              backgroundColor: theme.textDim.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${state.completedPages}',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / ${state.plan.totalTargetPages}',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentReadingCard(
    BuildContext context,
    RamadanThemeExtension theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'wird_last_read_page'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'wird_page_of'.tr(args: ['${state.lastReadPage}', '604']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _showPagePicker(context, theme),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'wird_continue_reading'.tr(),
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLogGrid(BuildContext context, RamadanThemeExtension theme) {
    final prayers = [
      {'id': 'fajr', 'icon': Icons.wb_twilight},
      {'id': 'dhuhr', 'icon': Icons.wb_sunny},
      {'id': 'asr', 'icon': Icons.wb_sunny_outlined},
      {'id': 'maghrib', 'icon': Icons.nightlight_round},
      {'id': 'isha', 'icon': Icons.bedtime},
      {'id': 'other', 'icon': Icons.more_horiz},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        final id = prayer['id'] as String;
        final pagesRead = state.todayPrayerPages[id] ?? 0;
        final target = state.plan.pagesPerPrayerTarget;

        return _buildPrayerLogCard(context, theme, prayer, pagesRead, target);
      },
    );
  }

  Widget _buildPrayerLogCard(
    BuildContext context,
    RamadanThemeExtension theme,
    Map<String, dynamic> prayer,
    int pagesRead,
    int target,
  ) {
    final id = prayer['id'] as String;
    final icon = prayer['icon'] as IconData;
    final isDone = target > 0 && pagesRead >= target;

    return InkWell(
      onTap: () => _showLogDialog(context, id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone ? theme.primary : theme.borderColor,
            width: isDone ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isDone ? theme.primary : theme.textSecondary,
                  size: 20,
                ),
                if (isDone)
                  Icon(Icons.check_circle, color: theme.primary, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id.tr(),
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  target > 0 ? '$pagesRead / $target' : '$pagesRead',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPagePicker(BuildContext context, RamadanThemeExtension theme) {
    final bloc = context.read<WirdBloc>();
    final controller = TextEditingController(
      text: state.lastReadPage.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('wird_last_read_page'.tr()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: '1-604',
            filled: true,
            fillColor: theme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page > 0 && page <= 604) {
                bloc.add(SetLastReadPage(page));
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, String prayerId, {DateTime? date}) {
    final theme = context.ramadanTheme;
    final bloc = context.read<WirdBloc>();
    // Get current value from the state only if today, otherwise it's 0 for simplicity in this dialog
    int currentValue = 0;
    final isToday = date == null || isSameDay(date, DateTime.now());

    if (isToday && state.todayPrayerPages.containsKey(prayerId)) {
      currentValue = state.todayPrayerPages[prayerId]!;
    }

    // Default target
    final target = state.plan.pagesPerPrayerTarget;
    int selectedValue = currentValue > 0
        ? currentValue
        : (target > 0 ? target : 1);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: theme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            date != null
                ? '${prayerId.tr()} (${DateFormat.yMMMd().format(date)})'
                : prayerId.tr(),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'wird_add_pages'.tr(),
                style: TextStyle(color: theme.textSecondary),
              ),
              if (target > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'wird_prayer_target'.tr(args: ['$target']),
                    style: TextStyle(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCounterButton(
                    theme,
                    icon: Icons.remove,
                    onTap: () {
                      if (selectedValue > 0) {
                        setState(() => selectedValue--);
                      }
                    },
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Text(
                      '$selectedValue',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  _buildCounterButton(
                    theme,
                    icon: Icons.add,
                    onTap: () {
                      setState(() => selectedValue++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'cancel'.tr(),
                style: TextStyle(color: theme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(
                  UpdatePrayerProgress(prayerId, selectedValue, date: date),
                );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDateAndLog(BuildContext context) async {
    final theme = context.ramadanTheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return child!;
      },
    );

    if (picked != null) {
      if (context.mounted) {
        _showPrayerSelectionDialog(context, picked);
      }
    }
  }

  void _showPrayerSelectionDialog(BuildContext context, DateTime date) {
    final theme = context.ramadanTheme;
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'other'];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('wird_select_date'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: prayers.length,
            itemBuilder: (context, index) {
              final id = prayers[index];
              return ListTile(
                leading: Icon(_getPrayerIcon(id), color: theme.primary),
                title: Text(id.tr()),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showLogDialog(context, id, date: date);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String id) {
    switch (id) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.nightlight_round;
      case 'isha':
        return Icons.bedtime;
      default:
        return Icons.more_horiz;
    }
  }

  Widget _buildCounterButton(
    RamadanThemeExtension theme, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.primary),
        onPressed: onTap,
        iconSize: 28,
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final theme = context.ramadanTheme;
    final bloc = context.read<WirdBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('wird_reset_title'.tr()),
        content: Text(
          'wird_reset_desc'.tr(),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'wird_keep_plan'.tr(),
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              bloc.add(ResetWirdProgress());
              Navigator.pop(dialogContext);
            },
            child: Text(
              'wird_reset_confirm'.tr(),
              style: TextStyle(color: theme.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
