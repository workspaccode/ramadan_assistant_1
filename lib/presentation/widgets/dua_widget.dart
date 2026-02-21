import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/blocs/tts_bloc.dart';

class DuaWidget extends StatelessWidget {
  final String arabicText;
  final String translation;
  final String? transliteration;
  final String? source;

  const DuaWidget({
    super.key,
    required this.arabicText,
    required this.translation,
    this.transliteration,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TTSBloc(),
      child: _DuaContent(
        arabicText: arabicText,
        translation: translation,
        transliteration: transliteration,
        source: source,
      ),
    );
  }
}

class _DuaContent extends StatelessWidget {
  final String arabicText;
  final String translation;
  final String? transliteration;
  final String? source;

  const _DuaContent({
    required this.arabicText,
    required this.translation,
    this.transliteration,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(
            //   color: isDark
            //       ? Colors.white.withValues(alpha: 0.12)
            //       : primaryColor.withValues(alpha: 0.15),
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                arabicText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  height: 1.8,
                  //  color: isDark ? secondaryColor : primaryColor,
                ),
              ),
              if (transliteration != null) ...[
                const SizedBox(height: 10),
                Text(
                  transliteration!,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (translation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(translation, style: context.textTheme.bodyMedium),
              ],
              if (source != null && source!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.push_pin_rounded,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        source!,
                        style: context.textTheme.labelSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildIconButton(
                    context,
                    icon: Icons.volume_up_rounded,
                    color: null,
                    onPressed: () =>
                        context.read<TTSBloc>().add(SpeakText(arabicText)),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    context,
                    icon: Icons.stop_rounded,
                    color: null,
                    onPressed: () =>
                        context.read<TTSBloc>().add(StopSpeaking()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required Color? color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
