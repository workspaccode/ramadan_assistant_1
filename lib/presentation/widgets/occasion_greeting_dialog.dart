
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/models/islamic_occasion.dart';

class OccasionGreetingDialog extends StatelessWidget {
  final IslamicOccasion occasion;

  const OccasionGreetingDialog({
    super.key,
    required this.occasion,
  });

  static Future<void> show(BuildContext context, IslamicOccasion occasion) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => OccasionGreetingDialog(occasion: occasion),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  occasion.titleKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  occasion.messageKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text('close'.tr()),
                ),
              ],
            ),
          ),
          Positioned(
            top: -50,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.background, width: 4),
              ),
              child: Center(
                child: occasion.assetPath != null && occasion.assetPath!.contains('.json')
                    ? Lottie.asset(occasion.assetPath!, height: 60)
                    : Icon(
                        Icons.celebration_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
              ),
            ),
          ),
          // Confetti or decorative elements could be added here
        ],
      ),
    );
  }
}
