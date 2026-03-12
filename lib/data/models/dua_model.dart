import 'package:equatable/equatable.dart';

class Dua extends Equatable {
  final String category;
  final String arabic;
  final String? translation;
  final String? source;

  const Dua({
    required this.category,
    required this.arabic,
    this.translation,
    this.source,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      category: json['category'] ?? 'عام',
      arabic: json['arabic'] ?? '',
      translation: json['translation'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'arabic': arabic,
      'translation': translation,
      'source': source,
    };
  }

  @override
  List<Object?> get props => [category, arabic, translation, source];
}
