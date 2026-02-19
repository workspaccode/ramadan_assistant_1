import 'package:equatable/equatable.dart';

enum WirdType {
  khatma, // Target 1-10 Khatmas per month
  pagesPerPrayer, // 1-6 pages after each prayer
  juzPerDay, // 1-3 Juz per day
}

class WirdPlan extends Equatable {
  final WirdType type;
  final int value; // Number of khatmas, pages, or juz depending on type

  const WirdPlan({required this.type, required this.value});

  int get dailyTargetPages {
    switch (type) {
      case WirdType.khatma:
        // Total pages / 30 days * number of khatmas
        return (604 * value / 30).ceil();
      case WirdType.pagesPerPrayer:
        // pages * 5 prayers
        return value * 5;
      case WirdType.juzPerDay:
        // 1 Juz is ~20 pages
        return value * 20;
    }
  }

  int get totalTargetPages {
    switch (type) {
      case WirdType.khatma:
        return 604 * value;
      case WirdType.pagesPerPrayer:
        return value * 5 * 30;
      case WirdType.juzPerDay:
        return value * 20 * 30;
    }
  }

  @override
  List<Object?> get props => [type, value];
}
