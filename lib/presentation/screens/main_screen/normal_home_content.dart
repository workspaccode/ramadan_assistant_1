import 'package:adhan_dart/adhan_dart.dart';
import 'package:ramadan_assistant/core/navigation/feature_routes.dart';
import 'package:ramadan_assistant/data/models/dhikr_presets.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/preferences_service.dart';
import 'package:ramadan_assistant/core/services/quran_database_service.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/core/utils/permission_flow.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/hadith_screen/hadith_screen.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/widgets/rotating_hadith_card.dart';
import 'package:ramadan_assistant/presentation/screens/notifications_screen/notifications_screen.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/prayer_times_screen.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/download_quran_screen.dart';
import 'package:ramadan_assistant/presentation/screens/quran_screen/quran_screen.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/bloc/reminders_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/reminders_screen.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/settings_screen.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/tasbih_screen.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/umrah_hub_screen.dart';

class NormalHomeContent extends StatefulWidget {
  const NormalHomeContent({super.key, this.isRamadan = false});

  final bool isRamadan;

  @override
  State<NormalHomeContent> createState() => _NormalHomeContentState();
}

class _NormalHomeContentState extends State<NormalHomeContent> {
  Timer? _clock;
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && AppShellScope.isActive(context, 0)) setState(() {});
    });
    // Request permissions in-context after the first frame —
    // never trigger system prompts at cold start (Play UX guidance).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_requestPermissions());
    });
  }

  Future<void> _requestPermissions() async {
    final locationGranted = await PermissionFlow.requestCorePermissions(
      context,
    );
    if (mounted && locationGranted) {
      final bloc = context.read<PrayerTimesBloc>();
      if (bloc.state is PrayerTimesInitial || bloc.state is PrayerTimesError) {
        bloc.add(LoadPrayerTimes(locale: context.locale.languageCode));
      }
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    final today = HijriCalendar.now();
    final gregorian = DateTime.now();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      bottomNavigationBar: const SakinaBottomBar(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, theme, today, gregorian),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                if (widget.isRamadan) ...[
                  Text(
                    'ramadan_kareem'.tr(),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                ],
                _buildHeroSection(context),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  context,
                  context.loc.ui_daily_tools,
                  Icons.grid_view_rounded,
                ),
                const SizedBox(height: 16),
                _buildFeaturesGrid(context),
                const SizedBox(height: 24),
                const RotatingHadithCard(),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  context,
                  'reminders'.tr(),
                  Icons.notifications_active_rounded,
                ),
                const SizedBox(height: 16),
                _buildRemindersSummary(context),
                SizedBox(height: 32 + MediaQuery.paddingOf(context).bottom),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    RamadanThemeExtension theme,
    HijriCalendar today,
    DateTime gregorian,
  ) {
    final locale = context.locale.languageCode;

    return SliverAppBar(
      floating: true,
      pinned: false,
      toolbarHeight: 56,
      centerTitle: true,
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: context.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      leading: IconButton(
        tooltip: 'location'.tr(),
        icon: const Icon(Icons.location_on_outlined),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
      ),
      title: Text(context.loc.ui_brand, style: context.textTheme.titleLarge),
      actions: [
        FutureBuilder<int>(
          future: PreferencesService.getInstance().then(
            (p) => p.getPendingUpdateCount(),
          ),
          builder: (context, snapshot) => IconButton(
            tooltip: 'notifications'.tr(),
            icon: Badge(
              isLabelVisible: (snapshot.data ?? 0) > 0,
              label: Text('${snapshot.data ?? 0}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ),
        IconButton(
          tooltip: 'settings_title'.tr(),
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(32),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  DateFormat('EEEE، d MMMM', locale).format(gregorian),
                  style: context.textTheme.bodySmall,
                ),
                Text(
                  '${today.hDay} / ${today.hMonth} / ${today.hYear}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: theme.secondary,
                  ),
                ),
              ],
            ),
          ),
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

          final remaining = nextPrayer.time.difference(DateTime.now());
          final timeLeft =
              '${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}';
          return Material(
            color: SakinaColors.hero(context),
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'next_prayer'.tr(),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCEE8DC),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.wb_twilight_rounded,
                          color: theme.accent,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          nextPrayer.name.tr(),
                          style: context.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat.jm(
                            context.locale.languageCode,
                          ).format(nextPrayer.time),
                          style: context.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFFCEE8DC),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            state.locationName,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCEE8DC),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: .12),
                        valueColor: AlwaysStoppedAnimation(theme.accent),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${context.loc.ui_remaining}  $timeLeft',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: theme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is PrayerTimesError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.background2,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('prayer_times'.tr(), style: context.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'location_error_title'.tr(),
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.read<PrayerTimesBloc>().add(
                        LoadPrayerTimes(
                          locale: context.locale.languageCode,
                          requestPermission: true,
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text('retry'.tr()),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                      child: Text('settings_title'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.background2,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('prayer_times'.tr(), style: context.textTheme.titleLarge),
              const SizedBox(height: 24),
              LinearProgressIndicator(semanticsLabel: 'prayer_times'.tr()),
            ],
          ),
        );
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
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final features = <Widget>[
      _buildFeatureCard(
        context,
        'quran'.tr(),
        Icons.menu_book_rounded,
        () async {
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
        Icons.touch_app_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasbihScreen()),
        ),
      ),
      _buildFeatureCard(
        context,
        'reminders'.tr(),
        Icons.notifications_active_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RemindersScreen()),
        ),
      ),
      _buildFeatureCard(
        context,
        context.loc.features_worship,
        Icons.bookmark_outline_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeatureRoutes.worship()),
        ),
      ),
      _buildFeatureCard(
        context,
        context.loc.features_planner,
        Icons.calendar_month_outlined,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeatureRoutes.planner()),
        ),
      ),
      _buildFeatureCard(
        context,
        'umrah'.tr(),
        Icons.map_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UmrahHubScreen()),
        ),
      ),
      _buildFeatureCard(
        context,
        'hadith_title'.tr(),
        Icons.library_books_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HadithScreen()),
        ),
      ),
      _buildFeatureCard(
        context,
        context.loc.features_library,
        Icons.auto_stories_outlined,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeatureRoutes.library()),
        ),
      ),
      _buildFeatureCard(
        context,
        context.loc.features_shortcuts,
        Icons.add_to_home_screen_outlined,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeatureRoutes.shortcuts()),
        ),
      ),
      _buildFeatureCard(
        context,
        context.loc.features_local_data,
        Icons.phone_android_outlined,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeatureRoutes.localData()),
        ),
      ),
    ];
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 310 || scale > 1.4) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  features[0],
                  const SizedBox(height: 12),
                  features[1],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: features[0]),
                const SizedBox(width: 12),
                Expanded(child: features[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        ...features.skip(2),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = context.ramadanTheme;
    final featured =
        icon == Icons.menu_book_rounded || icon == Icons.touch_app_rounded;
    if (!featured) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        minTileHeight: 64,
        leading: Icon(icon, color: theme.primary, size: 24),
        title: Text(title, style: context.textTheme.titleMedium),
        trailing: Icon(
          Icons.chevron_right,
          textDirection: Directionality.of(context),
          color: theme.textDim,
          size: 20,
        ),
        onTap: onTap,
      );
    }
    return Material(
      color: theme.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.primary, size: 28),
              const SizedBox(height: 16),
              Text(title, style: context.textTheme.titleMedium),
            ],
          ),
        ),
      ),
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
            height:
                110 +
                (MediaQuery.textScalerOf(context).scale(14) / 14 - 1).clamp(
                      0,
                      2,
                    ) *
                    36,
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
                              DhikrPresets.getTranslation(
                                DhikrPresets.dhikrList.firstWhere(
                                  (entry) =>
                                      entry['id'] ==
                                      reminder.reminderTypes.split(',').first,
                                  orElse: () => {
                                    'arabic': 'reminders'.tr(),
                                    'translation': 'reminders'.tr(),
                                  },
                                ),
                                context.locale.languageCode,
                              ),
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
                              '${'interval'.tr()}: ${reminder.intervalMinutes} ${'minutes'.tr()}',
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
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
            icon: const Icon(Icons.add),
            label: Text('add_reminder'.tr()),
          ),
        ],
      ),
    );
  }

  ({String name, DateTime time}) _getNextPrayer(PrayerTimes prayerTimes) {
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

    final tomorrowFajr = prayerTimes.fajrAfter.toLocal();
    return (name: 'fajr', time: tomorrowFajr);
  }

  double _calculateProgress(PrayerTimes prayerTimes) {
    final now = DateTime.now();

    final fajr = prayerTimes.fajr.toLocal();
    final dhuhr = prayerTimes.dhuhr.toLocal();
    final asr = prayerTimes.asr.toLocal();
    final maghrib = prayerTimes.maghrib.toLocal();
    final isha = prayerTimes.isha.toLocal();

    DateTime startTime;
    DateTime endTime;

    if (now.isBefore(fajr)) {
      startTime = prayerTimes.ishaBefore.toLocal();
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
      startTime = isha;
      endTime = prayerTimes.fajrAfter.toLocal();
    }

    final totalDuration = endTime.difference(startTime).inSeconds;
    final elapsedDuration = now.difference(startTime).inSeconds;

    if (totalDuration <= 0) {
      return 0;
    }
    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }
}
