
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/preferences_service.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';
import 'package:ramadan_assistant/presentation/screens/hadith_screen/hadith_screen.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/widgets/rotating_hadith_card.dart';
import 'package:ramadan_assistant/presentation/screens/notifications_screen/notifications_screen.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/prayer_times_screen.dart';
import 'package:ramadan_assistant/presentation/screens/qibla_screen/qibla_screen.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/download_quran_screen.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/quran_screen.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/bloc/reminders_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/reminders_screen.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/settings_screen.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/tasbih_screen.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/umrah_hub_screen.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/wird_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/falling_fanous_overlay.dart';
import 'package:ramadan_assistant/core/services/occasion_service.dart';
import 'package:ramadan_assistant/presentation/widgets/occasion_greeting_dialog.dart';
import 'package:vibration/vibration.dart';

class MainScreenContent extends StatefulWidget {
  const MainScreenContent({super.key});

  @override
  State<MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends State<MainScreenContent> {
  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
    _checkOccasions();
  }

  Future<void> _checkOccasions() async {
    try {
      final prefs = await PreferencesService.getInstance();
      final occasionService = OccasionService(prefs);
      final activeOccasion = occasionService.getActiveOccasion();

      if (activeOccasion != null) {
        final shouldShow = await occasionService.shouldShowGreeting();
        if (shouldShow) {
          if (mounted) {
            // Need a slight delay to ensure context is ready for dialog
             Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => OccasionGreetingDialog(occasion: activeOccasion),
                );
              }
            });
            occasionService.markGreetingAsShown(activeOccasion);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking occasions: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    try {
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        await Permission.location.request();
      }
      await NotificationService.requestPermissions();
    } catch (e) {
      debugPrint('Error loading update details: $e');
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildHeroSection(context),
                const SizedBox(height: 24),
                const RotatingHadithCard(),
                const SizedBox(height: 30),
                _buildSectionHeader(
                  context,
                  'features'.tr(),
                  Icons.grid_view_rounded,
                ),
                const SizedBox(height: 16),
                _buildFeaturesGrid(context),
                const SizedBox(height: 30),
                _buildSectionHeader(
                  context,
                  'daily_progress'.tr(),
                  Icons.analytics_rounded,
                ),
                const SizedBox(height: 16),
                _buildActivitySummary(context),
                const SizedBox(height: 30),
                _buildSectionHeader(
                  context,
                  'reminders'.tr(),
                  Icons.notifications_active_rounded,
                ),
                const SizedBox(height: 16),
                _buildRemindersSummary(context),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = context.ramadanTheme;
    final today = HijriCalendar.now();

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        FutureBuilder<int>(
          future: PreferencesService.getInstance().then(
            (p) => p.getPendingUpdateCount(),
          ),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return IconButton(
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(width: 8),
      ],
      leading: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            '${today.hDay} ${today.hMonth} ${today.hYear} هـ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      leadingWidth: 100,
      title: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          if (state is PrayerTimesLoaded) {
            final nextPrayer = _getNextPrayer(state.prayerTimes);
            return Text(
              '${nextPrayer.name.tr()}: ${DateFormat('hh:mm a').format(nextPrayer.time)}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [theme.primary, theme.secondary],
                ),
              ),
            ),
            // Luxury Pattern Overlay
            Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/image/islamic_pattern_premium_gold_1771758633652.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        FallingFanousOverlay.show(context);
                        Vibration.vibrate(duration: 50);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ramadan_kareem'.tr(),
                            style: const TextStyle(
                              // color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'tap_for_blessing'.tr(),
                            style: TextStyle(
                              //  color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${today.hDay} ${today.hMonth} ${today.hYear} هـ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = context.ramadanTheme;

    return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
      builder: (context, state) {
        if (state is PrayerTimesLoaded) {
          final nextPrayer = _getNextPrayer(state.prayerTimes);
          final progress = _calculateProgress(state.prayerTimes);

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardSurface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.borderColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'next_prayer'.tr(),
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextPrayer.name.tr(),
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        DateFormat('hh:mm a').format(nextPrayer.time),
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = context.ramadanTheme;
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _buildFeatureCard(
          context,
          'quran'.tr(),
          Icons.menu_book_rounded,
          const Color(0xFF43A047),
          () async {
            // Check if Quran DB exists, if not go to download screen
            final dbExists = await QuranDatabaseService.instance
                .isDatabaseExists();
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => dbExists
                      ? const QuranScreen()
                      : const DownloadQuranScreen(),
                ),
              );
            }
          },
        ),
        _buildFeatureCard(
          context,
          'tasbih'.tr(),
          Icons.fingerprint_rounded,
          const Color(0xFF1E88E5),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TasbihScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'wird_title'.tr(),
          Icons.auto_stories_rounded,
          const Color(0xFFD81B60),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WirdScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'prayer_times'.tr(),
          Icons.timer_rounded,
          const Color(0xFFFB8C00),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'reminders'.tr(),
          Icons.notifications_active_rounded,
          const Color(0xFF4527A0),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RemindersScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'umrah'.tr(),
          Icons.map_rounded,
          const Color(0xFF009688),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UmrahHubScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'qibla'.tr(),
          Icons.explore_rounded,
          const Color(0xFF795548),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QiblaScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'settings_title'.tr(),
          Icons.settings_suggest_rounded,
          const Color(0xFF607D8B),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        _buildFeatureCard(
          context,
          'hadith_title'.tr(),
          Icons.library_books_rounded,
          const Color(0xFF8E24AA),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HadithScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = context.ramadanTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.borderColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummary(BuildContext context) {
    final theme = context.ramadanTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.1)),
      ),
      child: BlocBuilder<WirdBloc, WirdState>(
        builder: (context, wirdState) {
          int streak = 0;
          int pages = 0;

          if (wirdState is WirdHistoryLoaded) {
            streak = wirdState.currentStreak;
            pages = wirdState.completedPages;
          } else if (wirdState is WirdPlanActive) {
            pages = wirdState.completedPages;
          }

          return BlocBuilder<TasbihBloc, TasbihState>(
            builder: (context, tasbihState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActivityStat(
                    context,
                    streak.toString(),
                    'days_streak'.tr(),
                    Icons.local_fire_department_rounded,
                  ),
                  _buildActivityStat(
                    context,
                    pages.toString(),
                    'pages_read'.tr(),
                    Icons.auto_stories,
                  ),
                  _buildActivityStat(
                    context,
                    tasbihState.count.toString(),
                    'tasbih_total'.tr(),
                    Icons.all_inclusive_rounded,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final theme = context.ramadanTheme;
    return Column(
      children: [
        Icon(icon, color: theme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildRemindersSummary(BuildContext context) {
    final theme = context.ramadanTheme;
    return BlocBuilder<RemindersBloc, RemindersState>(
      builder: (context, state) {
        if (state is RemindersLoaded && state.reminders.isNotEmpty) {
          final activeReminders = state.reminders
              .where((r) => r.isActive)
              .toList();

          if (activeReminders.isEmpty) {
            return _buildEmptyReminders(context);
          }

          return SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemCount: activeReminders.length,
              itemBuilder: (context, index) {
                final reminder = activeReminders[index];
                return Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.borderColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.secondary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: theme.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.reminderTypes
                                  .split(',')
                                  .first
                                  .toUpperCase(),
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Every ${reminder.intervalMinutes} min',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 12,
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
          );
        }
        return _buildEmptyReminders(context);
      },
    );
  }

  Widget _buildEmptyReminders(BuildContext context) {
    final theme = context.ramadanTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: theme.textDim,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'no_active_reminders'.tr(),
            style: TextStyle(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculation
  ({String name, DateTime time}) _getNextPrayer(dynamic prayerTimes) {
    final now = DateTime.now();

    final prayers = [
      {'name': 'fajr', 'time': prayerTimes.fajr.toLocal()},
      {'name': 'dhuhr', 'time': prayerTimes.dhuhr.toLocal()},
      {'name': 'asr', 'time': prayerTimes.asr.toLocal()},
      {'name': 'maghrib', 'time': prayerTimes.maghrib.toLocal()},
      {'name': 'isha', 'time': prayerTimes.isha.toLocal()},
    ];

    for (final prayer in prayers) {
      if (now.isBefore(prayer['time'] as DateTime)) {
        return (
          name: prayer['name'] as String,
          time: prayer['time'] as DateTime,
        );
      }
    }

    // If all prayers have passed, return tomorrow's Fajr
    final tomorrowFajr = (prayers.first['time'] as DateTime).add(
      const Duration(days: 1),
    );
    return (name: 'fajr', time: tomorrowFajr);
  }

  double _calculateProgress(dynamic prayerTimes) {
    final now = DateTime.now();

    // Convert all to local for accurate comparison
    final fajr = prayerTimes.fajr.toLocal();
    final dhuhr = prayerTimes.dhuhr.toLocal();
    final asr = prayerTimes.asr.toLocal();
    final maghrib = prayerTimes.maghrib.toLocal();
    final isha = prayerTimes.isha.toLocal();

    DateTime startTime;
    DateTime endTime;

    if (now.isBefore(fajr)) {
      // Before Fajr (Yesterday Isha to Today Fajr)
      startTime = isha.subtract(const Duration(days: 1));
      endTime = fajr;
    } else if (now.isBefore(dhuhr)) {
      startTime = fajr;
      endTime = dhuhr;
    } else if (now.isBefore(asr)) {
      startTime = dhuhr;
      endTime = asr;
    } else if (now.isBefore(maghrib)) {
      startTime = asr;
      endTime = maghrib;
    } else if (now.isBefore(isha)) {
      startTime = maghrib;
      endTime = isha;
    } else {
      // After Isha (Today Isha to Tomorrow Fajr)
      startTime = isha;
      endTime = fajr.add(const Duration(days: 1));
    }

    final totalDuration = endTime.difference(startTime).inSeconds;
    final elapsedDuration = now.difference(startTime).inSeconds;

    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }
}
