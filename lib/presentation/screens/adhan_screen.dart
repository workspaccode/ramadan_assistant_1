import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';

class AdhanScreen extends StatefulWidget {
  final String prayerName;
  final int iqamaDelayMinutes;

  const AdhanScreen({
    super.key,
    required this.prayerName,
    this.iqamaDelayMinutes = 10,
  });

  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AudioService _audioService = AudioService();
  Timer? _iqamaTimer;
  int _iqamaCountdown = 0;
  bool _showIqamaReminder = false;

  @override
  void initState() {
    super.initState();
    _iqamaCountdown = widget.iqamaDelayMinutes * 60;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    _playAdhan();
    _startIqamaTimer();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _playAdhan() async {
    final isFajr = widget.prayerName.toLowerCase() == 'fajr';
    await _audioService.playAdhan(isFajr: isFajr);
  }

  void _startIqamaTimer() {
    _iqamaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_iqamaCountdown > 0) {
          _iqamaCountdown--;
        } else {
          _showIqamaReminder = true;
          timer.cancel();
          _playIqamaReminder();
        }
      });
    });
  }

  void _playIqamaReminder() async {
    await _audioService.playIqamaReminder();
  }

  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _iqamaTimer?.cancel();
    _audioService.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D4F30), // Deep Islamic green
              Color(0xFF06402B), // Primary color
              Color(0xFF032819), // Darker green
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildContent(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Close button
        Align(
          alignment:
              context.locale.languageCode == 'ar' ||
                  context.locale.languageCode == 'ur'
              ? Alignment.topLeft
              : Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        const Spacer(),

        // Islamic decorative pattern
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.secondaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.mosque,
            color: AppTheme.secondaryColor,
            size: 80,
          ),
        ),

        const SizedBox(height: 40),

        // "حان وقت الصلاة" (Prayer Time)
        Text(
          'adhan_call_to_prayer'.tr(),
          style: const TextStyle(
            color: AppTheme.secondaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
          ),
        ),

        const SizedBox(height: 20),

        // Prayer Name
        Text(
          widget.prayerName.toLowerCase().tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),

        // Iqama Countdown or Reminder
        if (_showIqamaReminder)
          _buildIqamaReminder()
        else
          _buildIqamaCountdown(),

        const Spacer(),

        // Stop Adhan button
        Padding(
          padding: const EdgeInsets.all(30),
          child: ElevatedButton.icon(
            onPressed: () {
              _audioService.stop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.volume_off),
            label: Text(
              'stop_adhan'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIqamaCountdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'iqama_in'.tr(),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            _formatCountdown(_iqamaCountdown),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIqamaReminder() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.access_alarm,
            color: AppTheme.primaryColor,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            'time_for_iqama'.tr(),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
          if (context.locale.languageCode !=
              'ar') // Show Arabic if not in Arabic for beauty
            const Text(
              'حان وقت الإقامة',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontFamily: 'Amiri',
              ),
            ),
        ],
      ),
    );
  }
}
