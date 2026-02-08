import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/services/tts_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';

/// Full-screen Iqama reminder - different style from Adhan
class IqamaScreen extends StatefulWidget {
  final String prayerName;

  const IqamaScreen({super.key, required this.prayerName});

  @override
  State<IqamaScreen> createState() => _IqamaScreenState();
}

class _IqamaScreenState extends State<IqamaScreen>
    with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ttsService.announceIqama();

    // Auto-dismiss after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.secondaryColor,
              AppTheme.secondaryColor.withValues(alpha: 0.8),
              AppTheme.primaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing alarm icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.access_alarm,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Iqama text
              Text(
                'time_for_iqama'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '${'iqama_time'.tr()} - ${widget.prayerName.toLowerCase().tr()}',
                style: const TextStyle(color: Colors.white70, fontSize: 20),
              ),

              const SizedBox(height: 20),

              // Arabic prayer phrase
              Text(
                'prayer_about_to_begin'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Amiri',
                ),
              ),

              if (context.locale.languageCode != 'ar')
                const Text(
                  'قَدْ قَامَتِ الصَّلَاةُ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Amiri',
                  ),
                ),

              const SizedBox(height: 60),

              // Dismiss button
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: Text(
                  'got_it'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
