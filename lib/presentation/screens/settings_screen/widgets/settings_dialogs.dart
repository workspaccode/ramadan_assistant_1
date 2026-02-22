import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';

class SettingsDialogs {
  static void showLanguageDialog(
    BuildContext context, {
    required String currentLang,
    required Function(String) onSelected,
  }) {
    final theme = context.ramadanTheme;
    final langNames = {'ar': 'العربية', 'en': 'English', 'ur': 'اردو'};
    final langFlags = {'ar': '🇸🇦', 'en': '🇺🇸', 'ur': '🇵🇰'};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'language'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langNames.entries.map((entry) {
            final isSelected = currentLang == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () {
                  onSelected(entry.key);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? theme.primary : theme.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        langFlags[entry.key]!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? theme.primary : theme.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.primary,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static void showColorPaletteDialog(
    BuildContext context, {
    required String currentPalette,
    required Function(String) onSelected,
  }) {
    final theme = context.ramadanTheme;
    final palettes = [
      {
        'id': 'emerald',
        'name': 'Emerald Gold',
        'color': const Color(0xFF06402B),
      },
      {
        'id': 'midnight',
        'name': 'Midnight Royal',
        'color': const Color(0xFF001F3F),
      },
      {'id': 'desert', 'name': 'Desert Rose', 'color': const Color(0xFF800000)},
      {'id': 'ocean', 'name': 'Ocean Calm', 'color': const Color(0xFF0D4F6B)},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'color_palette'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: palettes.map((palette) {
            final isSelected = currentPalette == palette['id'];
            final color = palette['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  onSelected(palette['id'] as String);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : theme.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        (palette['id'] as String).tr(),
                        style: TextStyle(
                          color: isSelected ? color : theme.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
