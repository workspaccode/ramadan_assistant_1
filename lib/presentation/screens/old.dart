import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:easy_localization/easy_localization.dart';
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
  String?
  _lastTriggeredPrayer; // Track which prayer we already triggered adhan for

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

    // When countdown reaches zero (within 2 seconds window), show adhan screen
    // Only trigger if just crossed zero, not if it's been negative for a long time
    if (timeUntilNext.inSeconds <= 0 && timeUntilNext.inSeconds > -30) {
      // Don't trigger again for the same prayer
      if (_lastTriggeredPrayer == prayerKey) return;
      _lastTriggeredPrayer = prayerKey;
      _showAdhanScreen(prayerKey);
    } else if (timeUntilNext.inSeconds > 0) {
      // Reset the trigger when we're counting down to a new prayer
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

    return Column(
      children: [
        Container(
          height: 360,
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
                          '${'next_prayer'.tr()}: ${(nextPrayerInfo['key'] as String).tr()}',
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
        Expanded(
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

  /// Returns a map with 'time' (DateTime) and 'key' (String) for the next prayer.
  /// When all prayers have passed for today, it returns tomorrow's Fajr.
  Map<String, dynamic> _getNextPrayerInfo(PrayerTimes times) {
    final next = times.nextPrayer();
    DateTime prayerTime;
    String prayerKey;

    switch (next) {
      case Prayer.fajr:
        prayerTime = times.fajr.toLocal();
        prayerKey = 'fajr';
        break;
      case Prayer.sunrise:
        prayerTime = times.sunrise.toLocal();
        prayerKey = 'sunrise';
        break;
      case Prayer.dhuhr:
        prayerTime = times.dhuhr.toLocal();
        prayerKey = 'dhuhr';
        break;
      case Prayer.asr:
        prayerTime = times.asr.toLocal();
        prayerKey = 'asr';
        break;
      case Prayer.maghrib:
        prayerTime = times.maghrib.toLocal();
        prayerKey = 'maghrib';
        break;
      case Prayer.isha:
        prayerTime = times.isha.toLocal();
        prayerKey = 'isha';
        break;
      default:
        // All prayers have passed — next is tomorrow's Fajr
        prayerTime = times.fajr.toLocal().add(const Duration(days: 1));
        prayerKey = 'fajr';
        break;
    }

    // Safety check: if the resolved prayer time is still in the past,
    // it means all today's prayers passed, so target tomorrow's Fajr
    if (prayerTime.isBefore(_currentTime)) {
      prayerTime = times.fajr.toLocal().add(const Duration(days: 1));
      prayerKey = 'fajr';
    }

    return {'time': prayerTime, 'key': prayerKey};
  }

  // Keep these for backward compatibility with _checkAndShowAdhan
  DateTime _getNextPrayerTime(PrayerTimes times, Prayer next) {
    final info = _getNextPrayerInfo(times);
    return info['time'] as DateTime;
  }

  String _getNextPrayerKey(PrayerTimes times) {
    final info = _getNextPrayerInfo(times);
    return info['key'] as String;
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
            if (isUpcoming)
              Text(
                _formatCountdown(remaining),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              )
            else
              Text(
                time,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  //color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
