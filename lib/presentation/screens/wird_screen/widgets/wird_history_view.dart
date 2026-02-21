import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
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
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    context.read<WirdBloc>().add(LoadWirdHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return BlocBuilder<WirdBloc, WirdState>(
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
            color: Colors.black.withOpacity(0.02),
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
              color: color.withOpacity(0.1),
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
            color: Colors.black.withOpacity(0.02),
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
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.primary.withOpacity(0.3),
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
                color: theme.primary.withOpacity(0.05),
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
