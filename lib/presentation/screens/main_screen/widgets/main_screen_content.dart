import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/bloc/main_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/prayer_times_screen.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/reminders_screen.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/tasbih_screen.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/umrah_guide_screen.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/wird_screen.dart';

class MainScreenContent extends StatelessWidget {
  const MainScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenBloc, MainScreenState>(
      builder: (context, state) {
        final selectedIndex = state is MainScreenLoaded
            ? state.selectedIndex
            : 0;

        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: Stack(
            children: [
              _buildAnimatedBackground(true),
              SafeArea(
                child: Column(
                  children: [
                    //   _buildRamadanHeader(context, true),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: const [
                          PrayerTimesScreen(),
                          TasbihScreen(),
                          WirdScreen(),
                          RemindersScreen(),
                          UmrahGuideScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildRamadanBottomNavBar(
            context,
            selectedIndex,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isRamadan) {
    if (!isRamadan) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/animations/ramadan_moon.json',
                width: 200,
                height: 200,
                repeat: true,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/animations/ramadan_lantern.json',
                width: 150,
                height: 150,
                repeat: true,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -20,
            child: Opacity(
              opacity: 0.2,
              child: Lottie.asset(
                'assets/animations/ramadan_lantern.json',
                width: 100,
                height: 100,
                repeat: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRamadanHeader(BuildContext context, bool isRamadan) {
    final today = HijriCalendar.now();
    final isRamadan = today.hMonth == 9;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isRamadan ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
            isRamadan ? const Color(0xFF4CAF50) : const Color(0xFF42A5F5),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nights_stay, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                'app_name'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.nights_stay, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRamadan
                ? '${today.hDay} ${today.hMonth} ${today.hYear} هـ - ${today.hDay} ${_getRamadanDay(today.hDay)} رمضان'
                : '${today.hDay} ${today.hMonth} ${today.hYear} هـ',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (isRamadan) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'شهر الخير والبركة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRamadanDay(int day) {
    final ordinals = [
      'الأول',
      'الثاني',
      'الثالث',
      'الرابع',
      'الخامس',
      'السادس',
      'السابع',
      'الثامن',
      'التاسع',
      'العاشر',
      'الحادي عشر',
      'الثاني عشر',
      'الثالث عشر',
      'الرابع عشر',
      'الخامس عشر',
      'السادس عشر',
      'السابع عشر',
      'الثامن عشر',
      'التاسع عشر',
      'العشرون',
      'الحادي والعشرون',
      'الثاني والعشرون',
      'الثالث والعشرون',
      'الرابع والعشرون',
      'الخامس والعشرون',
      'السادس والعشرون',
      'السابع والعشرون',
      'الثامن والعشرون',
      'التاسع والعشرون',
      'الثلاثون',
    ];
    return day <= ordinals.length ? ordinals[day - 1] : day.toString();
  }

  Widget _buildRamadanBottomNavBar(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => context.read<MainScreenBloc>().add(ChangeTab(index)),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedIndex == 0
                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 24,
              ),
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedIndex == 1
                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.fingerprint, size: 24),
            ),
            label: 'tasbih'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedIndex == 2
                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selectedIndex == 2
                    ? Icons.auto_stories
                    : Icons.auto_stories_outlined,
                size: 24,
              ),
            ),
            label: 'wird_title'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedIndex == 3
                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selectedIndex == 3
                    ? Icons.notifications
                    : Icons.notifications_outlined,
                size: 24,
              ),
            ),
            label: 'reminders'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedIndex == 4
                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selectedIndex == 4 ? Icons.map : Icons.map_outlined,
                size: 24,
              ),
            ),
            label: 'umrah'.tr(),
          ),
        ],
      ),
    );
  }
}
