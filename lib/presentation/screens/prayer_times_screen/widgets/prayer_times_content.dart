import 'dart:async';
import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/adhan_screen.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';

class PrayerTimesContent extends StatefulWidget {
  final PrayerTimesLoaded state;

  const PrayerTimesContent({super.key, required this.state});

  @override
  State<PrayerTimesContent> createState() => _PrayerTimesContentState();
}

class _PrayerTimesContentState extends State<PrayerTimesContent> {
  bool _isAdhanScreenShowing = false;
  String? _lastTriggeredPrayer;
  late DateTime _localCurrentTime;
  Timer? _localTimer;

  @override
  void initState() {
    super.initState();
    _localCurrentTime = DateTime.now();
    _startLocalTimer();
    // Defer the adhan check to after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndShowAdhan();
      }
    });
  }

  void _startLocalTimer() {
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _localCurrentTime = DateTime.now();
        });
        _checkAndShowAdhan();
      }
    });
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }

  void _checkAndShowAdhan() {
    if (_isAdhanScreenShowing) return;

    final times = widget.state.prayerTimes;
    final nextPrayer = times.nextPrayer();
    final nextPrayerTime = _getNextPrayerTime(times, nextPrayer);
    final timeUntilNext = nextPrayerTime.difference(_localCurrentTime);
    final prayerKey = _getNextPrayerKey(times);

    // Trigger adhan exactly at prayer time (within 2 second window for reliability)
    if (timeUntilNext.inSeconds >= 0 && timeUntilNext.inSeconds <= 2) {
      // Prevent multiple triggers for same prayer
      if (_lastTriggeredPrayer == prayerKey) return;

      _lastTriggeredPrayer = prayerKey;
      _showAdhanScreen(prayerKey);
    }
    // Reset trigger when counting down to next prayer
    else if (timeUntilNext.inSeconds > 2) {
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
                          DateFormat.jm().format(prayerInfo['time']),
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
    final times = state.prayerTimes;
    final formatter = DateFormat.jm();
    final nextPrayerInfo = _getNextPrayerInfo(times);
    final nextPrayerTime = nextPrayerInfo['time'] as DateTime;
    final timeUntilNext = nextPrayerTime.difference(_localCurrentTime);
    final theme = context.ramadanTheme;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Parallax Header with Luxury Pattern
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: context.primaryColor,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Icon(Icons.arrow_back, color: theme.textPrimary),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Base
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          context.primaryColor,
                          context.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  // Luxury Pattern Overlay
                  Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/image/islamic_pattern_premium_gold_1771758633652.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Animated Content
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Location Info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.location_solid,
                                color: context.secondaryColor.withValues(
                                  alpha: 0.9,
                                ),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.locationName,
                                style: TextStyle(
                                  color: context.secondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Big Time
                        Text(
                          DateFormat('hh:mm').format(_localCurrentTime),
                          style: TextStyle(
                            color: context.secondaryColor,
                            fontSize: 72,
                            fontWeight: FontWeight.w100,
                            letterSpacing: -2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('ss').format(_localCurrentTime),
                              style: TextStyle(
                                color: context.secondaryColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('a').format(_localCurrentTime),
                              style: TextStyle(
                                color: context.secondaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),

          // Floating Next Prayer Card
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.background.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'next_prayer'.tr().toUpperCase(),
                                  style: TextStyle(
                                    color: theme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextPrayerInfo['name'].toString().tr(),
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDuration(timeUntilNext),
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'time_remaining'.tr(),
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Date & Duha Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'EEEE, d MMMM',
                          context.locale.languageCode,
                        ).format(_localCurrentTime),
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLocalizedHijriDate(context),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Premium Duha Button
                  GestureDetector(
                    onTap: () => _showPrayerDetailModal(context, 'duha', times),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.secondary,
                            theme.secondary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: theme.secondary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.sun_max_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'duha'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prayer Times List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final prayers = [
                  {
                    'name': 'fajr',
                    'time': times.fajr.toLocal(),
                    'icon': Icons.wb_twilight_rounded,
                    'color': const Color(0xFF64B5F6),
                  },
                  {
                    'name': 'dhuhr',
                    'time': times.dhuhr.toLocal(),
                    'icon': Icons.wb_sunny_rounded,
                    'color': const Color(0xFFFFB74D),
                  },
                  {
                    'name': 'asr',
                    'time': times.asr.toLocal(),
                    'icon': Icons.wb_sunny_outlined,
                    'color': const Color(0xFF9575CD),
                  },
                  {
                    'name': 'maghrib',
                    'time': times.maghrib.toLocal(),
                    'icon': Icons.nightlight_round,
                    'color': const Color(0xFFE57373),
                  },
                  {
                    'name': 'isha',
                    'time': times.isha.toLocal(),
                    'icon': Icons.bedtime_rounded,
                    'color': const Color(0xFF7986CB),
                  },
                ];

                final prayer = prayers[index];
                final isNext = prayer['name'] == nextPrayerInfo['name'];
                final prayerColor = prayer['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isNext
                        ? prayerColor.withValues(alpha: 0.08)
                        : theme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isNext
                          ? prayerColor
                          : theme.borderColor.withValues(alpha: 0.05),
                      width: isNext ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showPrayerDetailModal(
                      context,
                      prayer['name'] as String,
                      times,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: prayerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              prayer['icon'] as IconData,
                              color: prayerColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prayer['name'].toString().tr(),
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: isNext
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatter.format(prayer['time'] as DateTime),
                                  style: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isNext)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: prayerColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'next'.tr().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.chevron_right_rounded,
                              color: theme.textDim,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: 5),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
    final now = _localCurrentTime;
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
    final now = _localCurrentTime;
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

  String _getLocalizedHijriDate(BuildContext context) {
    final now = HijriCalendar.now();
    // The hijri package uses setLocal to change language globally for the calendar
    HijriCalendar.setLocal(context.locale.languageCode);
    return now.toFormat('dd MMMM yyyy');
  }
}
