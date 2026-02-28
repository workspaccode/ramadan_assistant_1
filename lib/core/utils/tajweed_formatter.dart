import 'package:flutter/material.dart';

class TajweedFormatter {
  static const Color madd6Color = Color(
    0xFFB11226,
  ); // Dark Red (مَدّ ٦ حركات لزوماً)
  static const Color madd45Color = Color(
    0xFFFC5355,
  ); // Red (مَدّ واجب ٤ او ٥ حركات)
  static const Color madd246Color = Color(
    0xFFF39237,
  ); // Orange (مَدّ ٢ أو ٤ أو ٦ جوازاً)
  static const Color madd2Color = Color(0xFFC7A252); // Gold (مَدّ حركتان)
  static const Color ghunnahColor = Color(
    0xFF538C5F,
  ); // Green (إخفاء ، ومواقع الغُنَّة)
  static const Color idghamColor = Color(
    0xFF9E9E9C,
  ); // Gray (إدغام ، ومالا يُلْفَظ)
  static const Color qalqalahColor = Color(0xFF3886BC); // Light Blue (قلقلة)
  static const Color tafkheemColor = Color(
    0xFF36607B,
  ); // Dark Blue (تفخيم الراء)

  /// Parses Uthmani Arabic text and returns a list of TextSpans with Tajweed colors.
  static List<TextSpan> getTajweedSpans({
    required String text,
    required TextStyle baseStyle,
    bool isTajweedEnabled = true,
  }) {
    if (!isTajweedEnabled || text.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    // We will build a basic Tajweed tokenizer based on Uthmani script standards.

    // 1. Tafkheem (Heavy Ra letters) - Dark Blue (#36607B)
    // Ra with Fatha (رَ), Ra with Damma (رُ), Ra with Shadda Fatha (رَّ), Ra with Shadda Damma (رُّ)
    final tafkheemRegex = RegExp(
      r'ر[\u064E\u064F\u064B\u064C]|ر\u0651[\u064E\u064F\u064B\u064C]',
    );

    // 2. Heavy Madd (6 Harakat لزوماً) - Dark Red (#B11226)
    // Followed by Shadda or Sukoon
    final madd6Regex = RegExp(
      r'.\u0653[\u064B-\u0652\u0670]*(?=\s*.\u0651|\s*.\u0652)',
    );

    // 3. Normal Madd (4/5 Harakat واجب) - Red (#FC5355)
    // General Madd marker \u0653 not followed by Shadda
    final madd45Regex = RegExp(r'.\u0653');

    // 4. Ghunnah/Ikhfa (Noon/Meem with Shadda or specific marks) - Green (#538C5F)
    final ghunnahRegex = RegExp(r'[نم][\u064B-\u065F]*\u0651[\u064B-\u065F]*');

    // 5. Qalqalah (Qaf, Taa, Baa, Jeem, Daal with Sukoon) - Light Blue (#3886BC)
    final qalqalahRegex = RegExp(r'[قطبجد][\u064B-\u0652\u0670]*\u0652');

    // 6. Idgham/Silent Letters - Gray (#9E9E9C)
    // Letters without vowels or with specialized silent markers in Uthmani script
    final idghamRegex = RegExp(
      r'[اوي](?![^\s])|[\u06DF\u06E0\u06E1]',
    ); // Small silent circle markers

    // Combine them into a single tokenizer string in priority order
    final combinedRegex = RegExp(
      '(${tafkheemRegex.pattern})|(${madd6Regex.pattern})|(${madd45Regex.pattern})|(${ghunnahRegex.pattern})|(${qalqalahRegex.pattern})|(${idghamRegex.pattern})',
    );

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in combinedRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        // Unstyled text
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: baseStyle,
          ),
        );
      }

      final matchText = match.group(0)!;
      Color? highlightColor;

      if (tafkheemRegex.hasMatch(matchText)) {
        highlightColor = tafkheemColor;
      } else if (madd6Regex.hasMatch(matchText)) {
        highlightColor = madd6Color;
      } else if (madd45Regex.hasMatch(matchText)) {
        highlightColor = madd45Color;
      } else if (ghunnahRegex.hasMatch(matchText)) {
        highlightColor = ghunnahColor;
      } else if (qalqalahRegex.hasMatch(matchText)) {
        highlightColor = qalqalahColor;
      } else if (idghamRegex.hasMatch(matchText)) {
        highlightColor = idghamColor;
      }

      spans.add(
        TextSpan(
          text: matchText,
          style: baseStyle.copyWith(color: highlightColor),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }

    return spans;
  }
}
