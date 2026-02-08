import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/blocs/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/prayer_times_state.dart';
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
      }
    });
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
    final nextPrayer = times.nextPrayer();
    final nextPrayerTime = _getNextPrayerTime(times, nextPrayer);
    final timeUntilNext = nextPrayerTime.difference(_currentTime);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/image/background1.jpg', fit: BoxFit.cover),
        ),
        Container(
          height: 320,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.only(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.secondaryColor,
                            size: 20,
                          ),
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
                          IconButton(
                            icon: const Icon(
                              Icons.explore,
                              color: Colors.white,
                            ),
                            tooltip: 'qibla'.tr(),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QiblaScreen(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Current time - updates every second
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatTime(_currentTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Next prayer with countdown
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${'next_prayer'.tr()}: ${_getNextPrayerKey(times).tr()}',
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Countdown in minutes and seconds
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatCountdown(timeUntilNext),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildHijriDate(context),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 300),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildPrayerCard(
                'fajr'.tr(),
                formatter.format(times.fajr.toLocal()),
                Icons.wb_twilight,
                _getPrayerStatus(times.fajr),
                times.fajr.toLocal(),
              ),
              _buildPrayerCard(
                'sunrise'.tr(),
                formatter.format(times.sunrise.toLocal()),
                Icons.wb_sunny_outlined,
                _getPrayerStatus(times.sunrise),
                times.sunrise.toLocal(),
              ),
              _buildPrayerCard(
                'dhuhr'.tr(),
                formatter.format(times.dhuhr.toLocal()),
                Icons.wb_sunny,
                _getPrayerStatus(times.dhuhr),
                times.dhuhr.toLocal(),
              ),
              _buildPrayerCard(
                'asr'.tr(),
                formatter.format(times.asr.toLocal()),
                Icons.cloud_outlined,
                _getPrayerStatus(times.asr),
                times.asr.toLocal(),
              ),
              _buildPrayerCard(
                'maghrib'.tr(),
                formatter.format(times.maghrib.toLocal()),
                Icons.nightlight_round,
                _getPrayerStatus(times.maghrib),
                times.maghrib.toLocal(),
              ),
              _buildPrayerCard(
                'isha'.tr(),
                formatter.format(times.isha.toLocal()),
                Icons.nights_stay,
                _getPrayerStatus(times.isha),
                times.isha.toLocal(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  String _formatCountdown(Duration duration) {
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

  DateTime _getNextPrayerTime(PrayerTimes times, Prayer next) {
    switch (next) {
      case Prayer.fajr:
        return times.fajr.toLocal();
      case Prayer.sunrise:
        return times.sunrise.toLocal();
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
    final next = times.nextPrayer();
    switch (next) {
      case Prayer.fajr:
        return 'fajr';
      case Prayer.sunrise:
        return 'sunrise';
      case Prayer.dhuhr:
        return 'dhuhr';
      case Prayer.asr:
        return 'asr';
      case Prayer.maghrib:
        return 'maghrib';
      case Prayer.isha:
        return 'isha';
      default:
        return 'fajr';
    }
  }

  String _getPrayerStatus(DateTime prayerTime) {
    final localPrayerTime = prayerTime.toLocal();
    if (localPrayerTime.isBefore(_currentTime)) {
      // Already passed
      return 'passed';
    }
    // Check if within 10 minutes of prayer time (currently praying)
    if (localPrayerTime.difference(_currentTime).inMinutes <= 10) {
      return 'now';
    }
    return 'upcoming';
  }

  Widget _buildHijriDate(BuildContext context) {
    final hijri = HijriCalendar.now();
    final monthKey = 'hijri_${hijri.hMonth}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month,
            color: AppTheme.secondaryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '${hijri.hDay} ${monthKey.tr()} ${hijri.hYear} ${'hijri_suffix'.tr()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(
    String name,
    String time,
    IconData icon,
    String status,
    DateTime prayerTime,
  ) {
    final isPassed = status == 'passed';
    final isNow = status == 'now';
    final isUpcoming = status == 'upcoming';
    final remaining = prayerTime.difference(_currentTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isNow
                    ? AppTheme.secondaryColor.withValues(alpha: 0.3)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isNow ? AppTheme.secondaryColor : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isNow)
                    Text(
                      'now'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isUpcoming)
                    Text(
                      _formatCountdown(remaining),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.grey : AppTheme.primaryColor,
                decoration: isPassed ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
