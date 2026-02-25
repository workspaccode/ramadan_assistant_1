class Hadith {
  final dynamic id;
  final String? textAr;
  final String? textEn;
  final String? narrator;
  final String? source;
  final String? chapter;

  Hadith({
    this.id,
    this.textAr,
    this.textEn,
    this.narrator,
    this.source,
    this.chapter,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    String? enText;
    String? narratorText;

    // Handle nested english object from AhmedBaset/hadith-json
    if (json['english'] is Map) {
      enText = json['english']['text'];
      narratorText = json['english']['narrator'];
    } else {
      enText =
          json['text_en'] ??
          json['textEn'] ??
          json['english'] ??
          json['translation'];
    }

    return Hadith(
      id: json['id'],
      textAr:
          json['arabic'] ?? json['text_ar'] ?? json['textAr'] ?? json['text'],
      textEn: enText,
      narrator: narratorText ?? json['narrator'] ?? json['rawi'],
      source: json['source'] ?? json['book'],
      chapter: json['chapter'] ?? json['bab'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text_ar': textAr,
      'text_en': textEn,
      'narrator': narrator,
      'source': source,
      'chapter': chapter,
    };
  }
}
