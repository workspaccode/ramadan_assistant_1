import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/models/islamic_occasion.dart';
import '../../core/theme/ramadan_theme_extension.dart';

class OccasionGreetingDialog extends StatelessWidget {
  final IslamicOccasion occasion;

  const OccasionGreetingDialog({
    super.key,
    required this.occasion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RamadanThemeExtension>();
    final primaryColor = ext?.primary ?? const Color(0xFF06402B);
    final accentColor = ext?.accent ?? const Color(0xFFD4AF37);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: ext?.background2 ?? Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Pattern/Header
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative patterns could go here
                    Icon(
                      Icons.star_rounded,
                      size: 60,
                      color: accentColor.withValues(alpha: 0.5),
                    ),
                    Icon(
                      Icons.mosque_rounded,
                      size: 50,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      occasion.titleKey.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      occasion.messageKey.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ext?.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('got_it'.tr()),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
