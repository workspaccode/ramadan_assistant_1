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

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

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

    return Stack(
      children: [
        Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
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
                const SizedBox(height: 20),
                Text(
                  formatter.format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${'next_prayer'.tr()}: ${_getNextPrayerKey(times).tr()}',
                  style: const TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                _buildHijriDate(context),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 280),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildPrayerCard(
                'fajr'.tr(),
                formatter.format(times.fajr.toLocal()),
                Icons.wb_twilight,
              ),
              _buildPrayerCard(
                'sunrise'.tr(),
                formatter.format(times.sunrise.toLocal()),
                Icons.wb_sunny_outlined,
              ),
              _buildPrayerCard(
                'dhuhr'.tr(),
                formatter.format(times.dhuhr.toLocal()),
                Icons.wb_sunny,
              ),
              _buildPrayerCard(
                'asr'.tr(),
                formatter.format(times.asr.toLocal()),
                Icons.cloud_outlined,
              ),
              _buildPrayerCard(
                'maghrib'.tr(),
                formatter.format(times.maghrib.toLocal()),
                Icons.nightlight_round,
              ),
              _buildPrayerCard(
                'isha'.tr(),
                formatter.format(times.isha.toLocal()),
                Icons.nights_stay,
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _buildPrayerCard(String name, String time, IconData icon) {
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
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              time,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
