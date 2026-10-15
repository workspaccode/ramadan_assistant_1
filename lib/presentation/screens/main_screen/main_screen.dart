import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/platform/feature_platform.dart';
import 'package:ramadan_assistant/core/navigation/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/bloc/main_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/widgets/main_screen_content.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/normal_home_content.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/prayer_times_screen.dart';
import 'package:ramadan_assistant/presentation/screens/dhikr_screen/dhikr_screen.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/tasbih_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

bool get isCurrentlyRamadan {
  final today = HijriCalendar.now();
  return today.hMonth == 9;
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Map<int, Widget> _visitedPages = {};
  StreamSubscription<AppShortcut>? _shortcuts;

  @override
  void initState() {
    super.initState();
    FeatureNavigation.pending.addListener(_consumeDestination);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _consumeDestination();
      if (sl.isRegistered<FeaturePlatform>()) {
        final platform = sl<FeaturePlatform>();
        _shortcuts = platform.shortcuts.listen(FeatureNavigation.request);
        final initial = await platform.initialize();
        if (mounted && initial != null) FeatureNavigation.request(initial);
      }
    });
  }

  void _consumeDestination() {
    final destination = FeatureNavigation.pending.value;
    if (destination == null || !mounted) return;
    FeatureNavigation.pending.value = null;
    unawaited(_openDestination(destination));
  }

  Future<void> _openDestination(AppShortcut destination) async {
    try {
      await FeatureRoutes.openShortcut(context, destination);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.loc.features_action_failed)),
        );
      }
    }
  }

  @override
  void dispose() {
    FeatureNavigation.pending.removeListener(_consumeDestination);
    unawaited(_shortcuts?.cancel());
    super.dispose();
  }

  Widget _page(int index) => _visitedPages.putIfAbsent(
    index,
    () => switch (index) {
      1 => const PrayerTimesScreen(),
      2 => const DhikrScreen(),
      3 => const TasbihScreen(),
      _ =>
        isCurrentlyRamadan
            ? const MainScreenContent()
            : const NormalHomeContent(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenBloc(),
      child: ValueListenableBuilder<int>(
        valueListenable: AppTabNavigation.index,
        builder: (context, index, _) {
          _page(index);
          return Scaffold(
            body: AppShellScope(
              activeTab: index,
              child: IndexedStack(
                index: index,
                children: List.generate(
                  4,
                  (i) => TickerMode(
                    enabled: i == index,
                    child: _visitedPages[i] ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SakinaBottomBar(
              selectedIndex: index,
              onSelected: (value) => AppTabNavigation.index.value = value,
            ),
          );
        },
      ),
    );
  }
}
