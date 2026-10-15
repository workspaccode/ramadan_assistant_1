import 'package:intl/intl.dart';
import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/settings_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';

typedef PrayerEntry = ({String name, DateTime time});

List<PrayerEntry> obligatoryPrayers(PrayerTimes times) => [
  (name: 'fajr', time: times.fajr.toLocal()),
  (name: 'dhuhr', time: times.dhuhr.toLocal()),
  (name: 'asr', time: times.asr.toLocal()),
  (name: 'maghrib', time: times.maghrib.toLocal()),
  (name: 'isha', time: times.isha.toLocal()),
];

PrayerEntry nextObligatoryPrayer(PrayerTimes times, DateTime now) =>
    obligatoryPrayers(times).firstWhere(
      (prayer) => prayer.time.isAfter(now),
      orElse: () => (name: 'fajr', time: times.fajrAfter.toLocal()),
    );

class PrayerTimesContent extends StatefulWidget {
  final PrayerTimesLoaded state;

  const PrayerTimesContent({super.key, required this.state});

  @override
  State<PrayerTimesContent> createState() => _PrayerTimesContentState();
}

class _PrayerTimesContentState extends State<PrayerTimesContent>
    with WidgetsBindingObserver {
  late DateTime _localCurrentTime;
  Timer? _localTimer;
  PrayerTimes? _dailyTimes;

  PrayerTimes get _times {
    final source = widget.state.prayerTimes;
    final today = DateUtils.dateOnly(_localCurrentTime);
    if (DateUtils.isSameDay(source.date, today)) return source;
    if (_dailyTimes == null || !DateUtils.isSameDay(_dailyTimes!.date, today)) {
      _dailyTimes = PrayerTimes(
        date: today,
        coordinates: source.coordinates,
        calculationParameters: source.calculationParameters,
      );
    }
    return _dailyTimes!;
  }

  @override
  void didUpdateWidget(PrayerTimesContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.prayerTimes != widget.state.prayerTimes) {
      _dailyTimes = null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localCurrentTime = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localCurrentTime = DateTime.now();
    _syncLocalTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      setState(() => _localCurrentTime = DateTime.now());
    }
    _syncLocalTimer();
  }

  void _syncLocalTimer() {
    _localTimer?.cancel();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (AppShellScope.isActive(context, 1) &&
        (lifecycle == null || lifecycle == AppLifecycleState.resumed)) {
      _startLocalTimer();
    }
  }

  void _startLocalTimer() {
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _localCurrentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Calculate Duha prayer time (10:30 AM to 30 minutes before Dhuhr)
  DateTime? _getDuhaTime(PrayerTimes times) {
    final now = DateTime.now();
    final dhuhrTime = times.dhuhr.toLocal();

    final duhaStart = DateTime(now.year, now.month, now.day, 10, 30);
    final duhaEnd = dhuhrTime.subtract(const Duration(minutes: 30));

    if (now.isAfter(duhaStart) && now.isBefore(duhaEnd)) {
      return now;
    }
    return duhaStart;
  }

  // Get prayer information for detailed modal
  Map<String, dynamic> _getPrayerInfo(String prayerName, PrayerTimes times) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return {
          'name': 'fajr',
          'time': times.fajr.toLocal(),
          'rakats': {
            'fard': 2,
            'sunnah': {'before': 2, 'after': 0},
          },
          'isSunnah': true,
          'preferredDuas': ['fajr_dua_1'.tr(), 'fajr_dua_2'.tr()],
        };
      case 'dhuhr':
        return {
          'name': 'dhuhr',
          'time': times.dhuhr.toLocal(),
          'rakats': {
            'fard': 4,
            'sunnah': {'before': 4, 'after': 2},
          },
          'isSunnah': true,
          'preferredDuas': ['dhuhr_dua_1'.tr(), 'dhuhr_dua_2'.tr()],
        };
      case 'asr':
        return {
          'name': 'asr',
          'time': times.asr.toLocal(),
          'rakats': {
            'fard': 4,
            'sunnah': {'before': 0, 'after': 0},
          },
          'isSunnah': false,
          'preferredDuas': ['asr_dua_1'.tr(), 'asr_dua_2'.tr()],
        };
      case 'maghrib':
        return {
          'name': 'maghrib',
          'time': times.maghrib.toLocal(),
          'rakats': {
            'fard': 3,
            'sunnah': {'before': 0, 'after': 2},
          },
          'isSunnah': true,
          'preferredDuas': ['maghrib_dua_1'.tr(), 'maghrib_dua_2'.tr()],
        };
      case 'isha':
        return {
          'name': 'isha',
          'time': times.isha.toLocal(),
          'rakats': {
            'fard': 4,
            'sunnah': {'before': 0, 'after': 2, 'witr': 3},
          },
          'isSunnah': true,
          'preferredDuas': ['isha_dua_1'.tr(), 'isha_dua_2'.tr()],
        };
      case 'duha':
        final duhaTime = _getDuhaTime(times);
        return {
          'name': 'duha',
          'time': duhaTime ?? DateTime.now(),
          'rakats': {
            'sunnah': {'min': 2, 'max': 8},
          },
          'isSunnah': true,
          'preferredDuas': ['duha_dua_1'.tr(), 'duha_dua_2'.tr()],
        };
      default:
        return {
          'name': prayerName,
          'time': DateTime.now(),
          'rakats': {'fard': 0},
          'isSunnah': false,
          'preferredDuas': [],
        };
    }
  }

  // Show prayer detail modal
  void _showPrayerDetailModal(
    BuildContext context,
    String prayerName,
    PrayerTimes times,
  ) {
    final prayerInfo = _getPrayerInfo(prayerName, times);
    final theme = context.ramadanTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Text(
                    prayerName.tr(),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatTimeRemaining(prayerInfo['time']),
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Info Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalStatCard(
                          context,
                          'sunnah_status'.tr(),
                          prayerInfo['isSunnah']
                              ? 'sunnah_prayer'.tr()
                              : 'fard_prayer'.tr(),
                          prayerInfo['isSunnah']
                              ? Icons.favorite_rounded
                              : Icons.star_rounded,
                          theme.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModalStatCard(
                          context,
                          'prayer_time'.tr(),
                          DateFormat.jm(
                            context.locale.languageCode,
                          ).format(prayerInfo['time']),
                          Icons.access_time_filled_rounded,
                          theme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rakats Section
                  _buildRakatsSection(context, prayerInfo['rakats']),

                  const SizedBox(height: 24),

                  // Preferred Duas Section
                  if (prayerInfo['preferredDuas'].isNotEmpty) ...[
                    Text(
                      'preferred_duas'.tr(),
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...prayerInfo['preferredDuas'].map<Widget>(
                      (dua) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.borderColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          dua,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 18,
                            height: 1.6,
                            fontFamily: 'traditional_arabic',
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = context.ramadanTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRakatsSection(
    BuildContext context,
    Map<String, dynamic> rakats,
  ) {
    final theme = context.ramadanTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered_rounded, color: theme.primary),
              const SizedBox(width: 12),
              Text(
                'rakats'.tr(),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (rakats.containsKey('fard'))
            _buildRakatRow(
              context,
              'fard'.tr(),
              rakats['fard'] as int,
              theme.primary,
            ),
          if (rakats.containsKey('sunnah')) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _buildSunnahRows(
              context: context,
              sunnah: rakats['sunnah'] as Map<String, dynamic>,
              color: theme.secondary,
            ),
          ],
          if (rakats.containsKey('witr')) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _buildRakatRow(
              context,
              'witr'.tr(),
              rakats['witr'] as int,
              theme.accent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRakatRow(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    final theme = context.ramadanTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count ${'rakats'.tr()}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahRows({
    required BuildContext context,
    required Map<String, dynamic> sunnah,
    required Color color,
  }) {
    return Column(
      children: [
        if (sunnah.containsKey('before'))
          _buildRakatRow(
            context,
            'before_prayer'.tr(),
            sunnah['before'] as int,
            color,
          ),
        if (sunnah.containsKey('after'))
          _buildRakatRow(
            context,
            'after_prayer'.tr(),
            sunnah['after'] as int,
            color,
          ),
        if (sunnah.containsKey('min'))
          _buildRakatRow(context, 'minimum'.tr(), sunnah['min'] as int, color),
        if (sunnah.containsKey('max'))
          _buildRakatRow(context, 'maximum'.tr(), sunnah['max'] as int, color),
      ],
    );
  }

  String _formatTimeRemaining(DateTime prayerTime) {
    final now = _localCurrentTime;
    final difference = prayerTime.difference(now);

    if (difference.isNegative) {
      return 'passed'.tr();
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours ${'hours'.tr()} $minutes ${'minutes'.tr()}';
    } else {
      return '$minutes ${'minutes'.tr()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final times = _times;
    final formatter = DateFormat.jm(context.locale.languageCode);
    final nextPrayerInfo = _getNextPrayerInfo(times);
    final nextPrayerTime = nextPrayerInfo['time'] as DateTime;
    final theme = context.ramadanTheme;
    final prayers = [
      (
        name: 'fajr',
        time: times.fajr.toLocal(),
        icon: Icons.wb_twilight_rounded,
      ),
      (
        name: 'dhuhr',
        time: times.dhuhr.toLocal(),
        icon: Icons.wb_sunny_outlined,
      ),
      (name: 'asr', time: times.asr.toLocal(), icon: Icons.wb_sunny_rounded),
      (
        name: 'maghrib',
        time: times.maghrib.toLocal(),
        icon: Icons.nightlight_outlined,
      ),
      (name: 'isha', time: times.isha.toLocal(), icon: Icons.bedtime_outlined),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('prayer_times'.tr()),
        automaticallyImplyLeading: !AppShellScope.contains(context),
        actions: [
          IconButton(
            tooltip: 'settings_title'.tr(),
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: context.primaryColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.locationName,
                  style: context.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SakinaCard(
            color: SakinaColors.hero(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'next_prayer'.tr(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFCEE8DC),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      (nextPrayerInfo['name'] as String).tr(),
                      style: context.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatter.format(nextPrayerTime),
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withValues(alpha: .15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      context.loc.ui_remaining,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFCEE8DC),
                      ),
                    ),
                    Text(
                      _formatDuration(
                        nextPrayerTime.difference(_localCurrentTime),
                      ),
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: theme.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getLocalizedHijriDate(context),
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SakinaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SakinaSectionTitle('today'.tr(), icon: Icons.mosque_outlined),
                const SizedBox(height: 16),
                ...prayers.map((prayer) {
                  final isNext = prayer.name == nextPrayerInfo['name'];
                  final passed = prayer.time.isBefore(_localCurrentTime);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isNext
                          ? SakinaColors.mint(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () =>
                            _showPrayerDetailModal(context, prayer.name, times),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                prayer.icon,
                                color: isNext
                                    ? context.primaryColor
                                    : theme.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayer.name.tr(),
                                      style: context.textTheme.titleMedium,
                                    ),
                                    Text(
                                      isNext
                                          ? 'next_prayer'.tr()
                                          : passed
                                          ? 'passed'.tr()
                                          : 'upcoming'.tr(),
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatter.format(prayer.time),
                                style: context.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: Icon(Icons.wb_sunny_outlined, color: theme.secondary),
            label: Text('duha'.tr()),
            onPressed: () => _showPrayerDetailModal(context, 'duha', times),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _getNextPrayerInfo(PrayerTimes times) {
    final next = nextObligatoryPrayer(times, _localCurrentTime);
    return {'name': next.name, 'time': next.time};
  }

  String _getLocalizedHijriDate(BuildContext context) {
    final now = HijriCalendar.now();
    // The hijri package uses setLocal to change language globally for the calendar
    final previousLanguage = HijriCalendar.language;
    try {
      HijriCalendar.setLocal(context.locale.languageCode == 'en' ? 'en' : 'ar');
      return now.toFormat('dd MMMM yyyy');
    } finally {
      HijriCalendar.setLocal(previousLanguage);
    }
  }
}
