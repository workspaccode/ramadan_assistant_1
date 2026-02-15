import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/bloc/main_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/prayer_times_screen.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/reminders_screen.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/tasbih_screen.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/umrah_guide_screen.dart';

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
          // appBar: AppBar(
          //   title: Text(
          //     _getTabTitle(selectedIndex),
          //     style: const TextStyle(fontWeight: FontWeight.bold),
          //   ),
          //   elevation: 0,
          //   backgroundColor: context.backgroundColor,
          //   actions: [
          //     IconButton(
          //       icon: const Icon(Icons.explore_outlined),
          //       onPressed: () => Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const QiblaScreen()),
          //       ),
          //     ),
          //     IconButton(
          //       icon: const Icon(Icons.settings_outlined),
          //       onPressed: () => Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const SettingsScreen()),
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //   ],
          // ),
          body: IndexedStack(
            index: selectedIndex,
            children: const [
              PrayerTimesScreen(),
              TasbihScreen(),
              RemindersScreen(),
              UmrahGuideScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) =>
                context.read<MainScreenBloc>().add(ChangeTab(index)),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: context.primaryColor,
            unselectedItemColor: Colors.grey,
            backgroundColor: context.backgroundColor,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: 'home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fingerprint),
                activeIcon: const Icon(Icons.fingerprint),
                label: 'tasbih'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_outlined),
                activeIcon: const Icon(Icons.notifications),
                label: 'reminders'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined),
                activeIcon: const Icon(Icons.map),
                label: 'umrah'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'prayer_times'.tr();
      case 1:
        return 'tasbih'.tr();
      case 2:
        return 'reminders'.tr();
      case 3:
        return 'umrah_guide'.tr();
      default:
        return '';
    }
  }
}
