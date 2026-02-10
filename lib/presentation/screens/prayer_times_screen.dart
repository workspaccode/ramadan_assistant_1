import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/blocs/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/prayer_times_state.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen.dart';
import 'package:ramadan_assistant/presentation/screens/qibla_screen.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  bool _isAdhanScreenShowing = false;
  String? _lastTriggeredPrayer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _checkAndShowAdhan();
      }
    });
  }

  void _checkAndShowAdhan() {
    if (_isAdhanScreenShowing) return;

    final state = context.read<PrayerTimesBloc>().state;
    if (state is! PrayerTimesLoaded) return;

    final times = state.prayerTimes;
    final nextPrayer = times.nextPrayer();
    final nextPrayerTime = _getNextPrayerTime(times, nextPrayer);
    final timeUntilNext = nextPrayerTime.difference(_currentTime);
    final prayerKey = _getNextPrayerKey(times);

    if (timeUntilNext.inSeconds <= 0 && timeUntilNext.inSeconds > -30) {
      if (_lastTriggeredPrayer == prayerKey) return;
      _lastTriggeredPrayer = prayerKey;
      _showAdhanScreen(prayerKey);
    } else if (timeUntilNext.inSeconds > 0) {
      if (_lastTriggeredPrayer != prayerKey) {
        _lastTriggeredPrayer = null;
      }
    }
  }

  void _showAdhanScreen(String prayerKey) {
    if (_isAdhanScreenShowing) return;
    _isAdhanScreenShowing = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdhanScreen(prayerName: prayerKey),
        fullscreenDialog: true,
      ),
    ).then((_) {
      _isAdhanScreenShowing = false;
    });
  }

  // Calculate Duha prayer time (10:30 AM to 30 minutes before Dhuhr)
  DateTime? _getDuhaTime(PrayerTimes times) {
    final now = DateTime.now();
    final dhuhrTime = times.dhuhr;

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
          'time': times.fajr,
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
          'time': times.dhuhr,
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
          'time': times.asr,
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
          'time': times.maghrib,
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
          'time': times.isha,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Card(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      prayerName.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatTimeRemaining(prayerInfo['time']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Time remaining
                        _buildInfoCard(
                          context,
                          'time_remaining'.tr(),
                          _formatTimeRemaining(prayerInfo['time']),
                          CupertinoIcons.clock,
                          isDark,
                        ),

                        const SizedBox(height: 16),

                        // Rakats
                        _buildRakatsCard(context, prayerInfo['rakats'], isDark),

                        const SizedBox(height: 16),

                        // Sunnah status
                        _buildInfoCard(
                          context,
                          'sunnah_status'.tr(),
                          prayerInfo['isSunnah']
                              ? 'sunnah_prayer'.tr()
                              : 'fard_prayer'.tr(),
                          prayerInfo['isSunnah']
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.star_fill,
                          isDark,
                        ),

                        const SizedBox(height: 16),

                        // Preferred duas
                        if (prayerInfo['preferredDuas'].isNotEmpty) ...[
                          Text(
                            'preferred_duas'.tr(),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...prayerInfo['preferredDuas'].map<Widget>(
                            (dua) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dua,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(20),
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  color: AppTheme.primaryColor,
                  child: Text(
                    'close'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRakatsCard(
    BuildContext context,
    Map<String, dynamic> rakats,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'rakats'.tr(),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (rakats.containsKey('fard'))
            _buildRakatRow('fard'.tr(), rakats['fard'], isDark),
          if (rakats.containsKey('sunnah'))
            _buildSunnahRow(rakats['sunnah'], isDark),
          if (rakats.containsKey('witr'))
            _buildRakatRow('witr'.tr(), rakats['witr'], isDark),
        ],
      ),
    );
  }

  Widget _buildRakatRow(String label, int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          Text(
            '$count ${'rakats'.tr()}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahRow(Map<String, dynamic> sunnah, bool isDark) {
    return Column(
      children: [
        Text(
          'sunnah'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        if (sunnah.containsKey('before'))
          _buildRakatRow('before_prayer'.tr(), sunnah['before'], isDark),
        if (sunnah.containsKey('after'))
          _buildRakatRow('after_prayer'.tr(), sunnah['after'], isDark),
        if (sunnah.containsKey('min'))
          _buildRakatRow('minimum'.tr(), sunnah['min'], isDark),
        if (sunnah.containsKey('max'))
          _buildRakatRow('maximum'.tr(), sunnah['max'], isDark),
      ],
    );
  }

  String _formatTimeRemaining(DateTime prayerTime) {
    final now = _currentTime;
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
    return Scaffold(
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          if (state is PrayerTimesInitial || state is PrayerTimesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrayerTimesLoaded) {
            return _buildContent(context, state);
          } else if (state is PrayerTimesError) {
            return Center(
              child: Text('error_prefix'.tr(args: [state.message])),
            );
          }
          return Center(child: Text('something_went_wrong'.tr()));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrayerTimesLoaded state) {
    final times = state.prayerTimes;
    final formatter = DateFormat.jm();
    final nextPrayerInfo = _getNextPrayerInfo(times);
    final nextPrayerTime = nextPrayerInfo['time'] as DateTime;
    final timeUntilNext = nextPrayerTime.difference(_currentTime);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header with iOS design
        Container(
          height: 360,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            CupertinoIcons.location,
                            color: AppTheme.secondaryColor,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.locationName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QiblaScreen(),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.compass,
                              color: Colors.white,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Current time
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat('HH:mm:ss').format(_currentTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Next prayer countdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'next_prayer'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextPrayerInfo['name'].toString().tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(nextPrayerTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Countdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    _formatDuration(timeUntilNext),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Prayer times list with iOS design
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Date info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(_currentTime),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            HijriCalendar.now().toFormat('dd MMMM yyyy'),
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Add Duha prayer button
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        onPressed: () =>
                            _showPrayerDetailModal(context, 'duha', times),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.sun_max,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'duha'.tr(),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Prayer times list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final prayers = [
                        {
                          'name': 'fajr',
                          'time': times.fajr.toLocal(),
                          'icon': CupertinoIcons.sunrise,
                        },
                        {
                          'name': 'dhuhr',
                          'time': times.dhuhr.toLocal(),
                          'icon': CupertinoIcons.sun_max,
                        },
                        {
                          'name': 'asr',
                          'time': times.asr.toLocal(),
                          'icon': CupertinoIcons.cloud_sun,
                        },
                        {
                          'name': 'maghrib',
                          'time': times.maghrib.toLocal(),
                          'icon': CupertinoIcons.sunset,
                        },
                        {
                          'name': 'isha',
                          'time': times.isha.toLocal(),
                          'icon': CupertinoIcons.moon,
                        },
                        {
                          'name': 'duha',
                          'time': _getDuhaTime(times),
                          'icon': CupertinoIcons.sun_max_fill,
                        },
                      ];

                      final prayer = prayers[index];
                      final isNext = prayer['name'] == nextPrayerInfo['name'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isNext
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey[50]),
                          borderRadius: BorderRadius.circular(16),
                          border: isNext
                              ? Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 1,
                                )
                              : null,
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(16),
                          onPressed: () => _showPrayerDetailModal(
                            context,
                            prayer['name'] as String,
                            times,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isNext
                                      ? AppTheme.primaryColor
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  prayer['icon'] as IconData,
                                  color: isNext
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      prayer['name'].toString().tr(),
                                      style: TextStyle(
                                        color: isNext
                                            ? AppTheme.primaryColor
                                            : (isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (prayer['time'] != null)
                                      Text(
                                        formatter.format(
                                          prayer['time'] as DateTime,
                                        ),
                                        style: TextStyle(
                                          color: isNext
                                              ? AppTheme.primaryColor
                                              : (isDark
                                                    ? Colors.white70
                                                    : Colors.grey[600]),
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isNext)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'next'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
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
    final now = _currentTime;
    final prayers = [
      {'name': 'fajr', 'time': times.fajr.toLocal()},
      {'name': 'dhuhr', 'time': times.dhuhr.toLocal()},
      {'name': 'asr', 'time': times.asr.toLocal()},
      {'name': 'maghrib', 'time': times.maghrib.toLocal()},
      {'name': 'isha', 'time': times.isha.toLocal()},
    ];

    for (final prayer in prayers) {
      if (now.isBefore(prayer['time'] as DateTime)) {
        return prayer;
      }
    }

    // If all prayers have passed, return tomorrow's Fajr
    final tomorrowFajr = prayers.first['time'] as DateTime;
    return {'name': 'fajr', 'time': tomorrowFajr.add(const Duration(days: 1))};
  }

  DateTime _getNextPrayerTime(PrayerTimes times, Prayer nextPrayer) {
    switch (nextPrayer) {
      case Prayer.fajr:
        return times.fajr.toLocal();
      case Prayer.dhuhr:
        return times.dhuhr.toLocal();
      case Prayer.asr:
        return times.asr.toLocal();
      case Prayer.maghrib:
        return times.maghrib.toLocal();
      case Prayer.isha:
        return times.isha.toLocal();
      default:
        return times.fajr.toLocal();
    }
  }

  String _getNextPrayerKey(PrayerTimes times) {
    final now = _currentTime;
    final prayers = [
      {'name': 'fajr', 'time': times.fajr.toLocal()},
      {'name': 'dhuhr', 'time': times.dhuhr.toLocal()},
      {'name': 'asr', 'time': times.asr.toLocal()},
      {'name': 'maghrib', 'time': times.maghrib.toLocal()},
      {'name': 'isha', 'time': times.isha.toLocal()},
    ];

    for (final prayer in prayers) {
      if (now.isBefore(prayer['time'] as DateTime)) {
        return prayer['name'] as String;
      }
    }

    return 'fajr';
  }
}
