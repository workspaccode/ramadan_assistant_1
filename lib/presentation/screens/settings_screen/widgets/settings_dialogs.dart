
import 'package:flutter/cupertino.dart';
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey3.resolveFrom(context),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'language'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
              const Divider(height: 1),
              // Language options
              ...langNames.entries.map((entry) {
                final isSelected = currentLang == entry.key;
                return CupertinoListTile(
                  leading: Text(
                    langFlags[entry.key]!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.primary
                          : CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          CupertinoIcons.checkmark_alt_circle_fill,
                          color: theme.primary,
                          size: 24,
                        )
                      : null,
                  onTap: () {
                    onSelected(entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static void showColorPaletteDialog(
    BuildContext context, {
    required String currentPalette,
    required Function(String) onSelected,
  }) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey3.resolveFrom(context),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'color_palette'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
              const Divider(height: 1),
              // Palette options
              ...palettes.map((palette) {
                final isSelected = currentPalette == palette['id'];
                final color = palette['color'] as Color;
                return CupertinoListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    (palette['id'] as String).tr(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? color
                          : CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          CupertinoIcons.checkmark_alt_circle_fill,
                          color: color,
                          size: 24,
                        )
                      : null,
                  onTap: () {
                    onSelected(palette['id'] as String);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
