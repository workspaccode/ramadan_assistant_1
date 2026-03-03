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

  /// Parses Uthmani Arabic text containing custom tags from AlQuran Cloud and returns a list of TextSpans with Tajweed colors.
  static List<TextSpan> getTajweedSpans({
    required String text,
    required TextStyle baseStyle,
    bool isTajweedEnabled = true,
  }) {
    if (text.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    // AlQuran Cloud Tajweed format: [rule[text]
    final regex = RegExp(r'\[([a-zA-Z0-9:]+)\[([^\]]+)\]');

    if (!isTajweedEnabled) {
      // Strip out all tags if Tajweed is disabled, leaving only the Arabic text
      final cleanText = text.replaceAllMapped(
        regex,
        (match) => match.group(2)!,
      );
      return [TextSpan(text: cleanText, style: baseStyle)];
    }

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        // Text before the tag
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: baseStyle,
          ),
        );
      }

      final ruleCode = match.group(1)!;
      final matchText = match.group(2)!;
      final highlightColor = _getColorForClass(ruleCode);

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

  static Color? _getColorForClass(String ruleCode) {
    // Drop the colon suffix if any (e.g., "h:1" -> "h")
    final rootRule = ruleCode.split(':').first;

    switch (rootRule) {
      case 'm': // madda-necessary, 6 harakat
        return madd6Color; // Dark Red
      case 'o': // madda-obligatory, 4/5 harakat
        return madd45Color; // Red
      case 'p': // madda-permissible, 2/4/6 harakat
        return madd246Color; // Orange
      case 'n': // madda-normal, 2 harakat
        return madd2Color; // Gold
      case 'g': // ghunnah
      case 'f': // ikhafa
      case 'c': // ikhafa-shafawi
      case 'i': // iqlab
      case 'w': // idgham-shafawi
      case 'a': // idgham-with-ghunnah
        return ghunnahColor; // Green
      case 'h': // hamza-wasl
      case 's': // silent
      case 'l': // laam-shamsiyah
      case 'u': // idgham-without-ghunnah
      case 'd': // idgham-mutajanisayn
      case 'b': // idgham-mutaqaribayn
        return idghamColor; // Gray
      case 'q': // qalaqah
        return qalqalahColor; // Light Blue
      // Since 'quran-tajweed' does NOT natively include tafkheem for Ra,
      // we leave it as null
      default:
        return null;
    }
  }
}
