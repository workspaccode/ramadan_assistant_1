import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/blocs/tts_bloc.dart';

class DuaWidget extends StatelessWidget {
  final String arabicText;
  final String translation;
  final String? transliteration;

  const DuaWidget({
    super.key,
    required this.arabicText,
    required this.translation,
    this.transliteration,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TTSBloc(),
      child: _DuaContent(
        arabicText: arabicText,
        translation: translation,
        transliteration: transliteration,
      ),
    );
  }
}

class _DuaContent extends StatelessWidget {
  final String arabicText;
  final String translation;
  final String? transliteration;

  const _DuaContent({
    required this.arabicText,
    required this.translation,
    this.transliteration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            arabicText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.secondaryColor
                  : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          if (transliteration != null)
            Text(
              transliteration!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          if (translation.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(translation),
          ],
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () =>
                    context.read<TTSBloc>().add(SpeakText(arabicText)),
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.grey),
                onPressed: () => context.read<TTSBloc>().add(StopSpeaking()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
