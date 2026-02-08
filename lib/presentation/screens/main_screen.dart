import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    PrayerTimesScreen(),
    const TasbihScreen(),
    const RemindersScreen(),
    const UmrahGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: 'tab_prayers'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fingerprint),
            label: 'tab_tasbih'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_active),
            label: 'tab_reminders'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            label: 'tab_umrah'.tr(),
          ),
        ],
      ),
    );
  }
}
