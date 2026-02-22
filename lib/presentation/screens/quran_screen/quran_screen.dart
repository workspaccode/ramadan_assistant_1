import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return Scaffold(
      body: QuranLibraryScreen(
        parentContext: context,
        isDark: Theme.of(context).brightness == Brightness.dark,
        appLanguageCode: context.locale.languageCode,
        backgroundColor: theme.background,
        textColor: theme.textPrimary,
        ayahIconColor: theme.primary,
        ayahSelectedBackgroundColor: theme.primary.withOpacity(0.2),
      ),
    );
  }
}
