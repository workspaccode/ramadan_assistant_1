import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';
import 'package:table_calendar/table_calendar.dart';

class WirdHistoryView extends StatefulWidget {
  const WirdHistoryView({super.key});

  @override
  State<WirdHistoryView> createState() => _WirdHistoryViewState();
}

class _WirdHistoryViewState extends State<WirdHistoryView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    context.read<WirdBloc>().add(LoadWirdHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return BlocListener<WirdBloc, WirdState>(
      listener: (context, state) {
        if (state is WirdPlanActive) {
          if (!isSameDay(_selectedDay, state.activeDate)) {
            setState(() {
              _selectedDay = state.activeDate;
              _focusedDay = state.activeDate;
            });
          }
        }
      },
      child: BlocBuilder<WirdBloc, WirdState>(
        builder: (context, state) {
          if (state is WirdLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WirdHistoryLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(context, theme, state),
                  const SizedBox(height: 24),
                  _buildCalendar(context, theme, state),
                  const SizedBox(height: 24),
                  _buildDayDetails(context, theme, state),
                  const SizedBox(height: 24),
                  _buildChartSection(context, theme, state),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'wird_error_loading_history'.tr(),
              style: TextStyle(color: theme.error),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    RamadanThemeExtension theme,
    WirdHistoryLoaded state,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            icon: Icons.local_fire_department,
            label: 'wird_streak'.tr(),
            value: '${state.currentStreak}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            icon: Icons.auto_stories,
            label: 'wird_total_pages'.tr(),
            value: '${state.totalPagesRead}',
            color: theme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            icon: Icons.analytics,
            label: 'wird_avg_per_day'.tr(),
            value: state.averagePagesPerDay.toStringAsFixed(1),
            color: theme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    RamadanThemeExtension theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    RamadanThemeExtension theme,
    WirdHistoryLoaded state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          context.read<WirdBloc>().add(ChangeSelectedDate(selectedDay));
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.primary,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(color: theme.textPrimary),
          weekendTextStyle: TextStyle(color: theme.textPrimary),
          outsideTextStyle: TextStyle(color: theme.textDim),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: theme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: theme.textPrimary),
          rightChevronIcon: Icon(Icons.chevron_right, color: theme.textPrimary),
        ),
        eventLoader: (day) {
          // Check if we have reading data for this day
          final normalizedDay = DateTime(day.year, day.month, day.day);
          if (state.readingDays.containsKey(normalizedDay)) {
            return [
              state.readingDays[normalizedDay],
            ]; // Return list to show marker
          }
          return [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.success, // Green dot for reading
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDayDetails(
    BuildContext context,
    RamadanThemeExtension theme,
    WirdHistoryLoaded state,
  ) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final normalizedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    // Find the log for this day
    final log = state.historyLogs.firstWhere(
      (l) =>
          l.date.year == normalizedDay.year &&
          l.date.month == normalizedDay.month &&
          l.date.day == normalizedDay.day,
      orElse: () => WirdDailyLog(
        id: -1,
        date: normalizedDay,
        fajrPages: 0,
        dhuhrPages: 0,
        asrPages: 0,
        maghribPages: 0,
        ishaPages: 0,
        otherPages: 0,
      ),
    );

    final totalDay =
        log.fajrPages +
        log.dhuhrPages +
        log.asrPages +
        log.maghribPages +
        log.ishaPages +
        log.otherPages;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'wird_details_for'.tr(
                  args: [DateFormat.yMMMd().format(log.date)],
                ),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (totalDay > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalDay ${'pages'.tr()}',
                    style: TextStyle(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (totalDay == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'wird_no_data_day'.tr(),
                style: TextStyle(color: theme.textDim, fontSize: 13),
              ),
            )
          else
            Column(
              children: [
                _buildPrayerDetailRow(theme, 'fajr', log.fajrPages),
                _buildPrayerDetailRow(theme, 'dhuhr', log.dhuhrPages),
                _buildPrayerDetailRow(theme, 'asr', log.asrPages),
                _buildPrayerDetailRow(theme, 'maghrib', log.maghribPages),
                _buildPrayerDetailRow(theme, 'isha', log.ishaPages),
                _buildPrayerDetailRow(theme, 'other', log.otherPages),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerDetailRow(
    RamadanThemeExtension theme,
    String label,
    int pages,
  ) {
    if (pages == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_getPrayerIcon(label), size: 16, color: theme.textSecondary),
              const SizedBox(width: 8),
              Text(
                label.tr(),
                style: TextStyle(color: theme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          Text(
            '$pages',
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
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

  Widget _buildChartSection(
    BuildContext context,
    RamadanThemeExtension theme,
    WirdHistoryLoaded state,
  ) {
    // Generate data for last 7 days from historyLogs
    // This requires some processing to ensure 0-values for missing days
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final dayData = state.readingDays[date] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i, // 0 to 6
          barRods: [
            BarChartRodData(
              toY: dayData.toDouble(),
              color: theme.primary,
              width: 12,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 20, // Max scale approx
                color: theme.primary.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wird_weekly_activity'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Simple M T W T F S S labels
                        // Calculate day name based on index relative to today
                        final index = value.toInt();
                        final date = now.subtract(Duration(days: 6 - index));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat.E().format(
                              date,
                            )[0], // First letter of day
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
