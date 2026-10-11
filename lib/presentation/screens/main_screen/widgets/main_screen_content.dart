import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/services/occasion_service.dart';
import 'package:ramadan_assistant/core/services/preferences_service.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/normal_home_content.dart';
import 'package:ramadan_assistant/presentation/widgets/occasion_greeting_dialog.dart';

/// Seasonal home shares the same accessible layout as the rest of the year.
class MainScreenContent extends StatefulWidget {
  const MainScreenContent({super.key});

  @override
  State<MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends State<MainScreenContent> {
  @override
  void initState() {
    super.initState();
    _checkOccasions();
  }

  Future<void> _checkOccasions() async {
    try {
      final prefs = await PreferencesService.getInstance();
      final occasionService = OccasionService(prefs);
      final activeOccasion = occasionService.getActiveOccasion();

      if (activeOccasion != null) {
        final shouldShow = await occasionService.shouldShowGreeting();
        if (shouldShow) {
          if (mounted) {
            // Need a slight delay to ensure context is ready for dialog
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      OccasionGreetingDialog(occasion: activeOccasion),
                );
              }
            });
            occasionService.markGreetingAsShown(activeOccasion);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking occasions: $e');
    }
  }

  @override
  Widget build(BuildContext context) =>
      const NormalHomeContent(isRamadan: true);
}
