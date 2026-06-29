import 'dart:async';


import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/data/models/hadith_presets.dart';

class RotatingHadithCard extends StatefulWidget {
  const RotatingHadithCard({super.key});

  @override
  State<RotatingHadithCard> createState() => _RotatingHadithCardState();
}

class _RotatingHadithCardState extends State<RotatingHadithCard> {
  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = DateTime.now().minute % HadithPresets.hadithList.length;
    _startRotation();
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % HadithPresets.hadithList.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    final hadith = HadithPresets.hadithList[_currentIndex];
    final lang = context.locale.languageCode;

    String content;
    switch (lang) {
      case 'ar':
        content = hadith.arabic;
        break;
      case 'ur':
        content = hadith.urdu;
        break;
      default:
        content = hadith.translation;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.format_quote_rounded, color: theme.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'daily_hadith'.tr(),
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: lang == 'ar' ? 20 : 16,
              height: 1.6,
              fontWeight: lang == 'ar' ? FontWeight.w500 : FontWeight.normal,
              fontFamily: lang == 'ar' ? 'Amiri' : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hadith.source,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
