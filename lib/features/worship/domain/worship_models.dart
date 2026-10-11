enum ObligatoryPrayer { fajr, dhuhr, asr, maghrib, isha }

enum PrayerStatus { pending, completed, missed }

enum VoluntaryWorship { duha, witr, rawatib, nightPrayer, fasting }

enum LedgerKind { opening, payment, adjustment }

class WorshipValidationException implements Exception {
  const WorshipValidationException(this.code);
  final String code;
  @override
  String toString() => code;
}

String worshipDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

void validateWorshipDay(String day) {
  final parsed = DateTime.tryParse(day);
  if (parsed == null || worshipDay(parsed) != day) {
    throw const WorshipValidationException('worship_invalid_day');
  }
}

class WirdPlan {
  const WirdPlan({
    required this.dailyPages,
    required this.nextPage,
    this.reminderMinute,
    this.readerAppId,
  });
  final int dailyPages;
  final int nextPage;
  final int? reminderMinute;
  final String? readerAppId;
  int get endPage => ((nextPage - 1 + dailyPages - 1) % 604) + 1;
  WirdPlan advance() => WirdPlan(
    dailyPages: dailyPages,
    nextPage: ((nextPage - 1 + dailyPages) % 604) + 1,
    reminderMinute: reminderMinute,
    readerAppId: readerAppId,
  );
  void validate() {
    if (dailyPages < 1 ||
        dailyPages > 604 ||
        nextPage < 1 ||
        nextPage > 604 ||
        (reminderMinute != null &&
            (reminderMinute! < 0 || reminderMinute! >= 1440))) {
      throw const WorshipValidationException('worship_invalid_plan');
    }
  }
}

class WirdCompletion {
  const WirdCompletion({
    required this.day,
    required this.startPage,
    required this.pages,
    required this.completedAt,
  });
  final String day;
  final int startPage;
  final int pages;
  final DateTime completedAt;
  int get endPage => ((startPage - 1 + pages - 1) % 604) + 1;
}

class DailyPrayerRecord {
  const DailyPrayerRecord({
    required this.day,
    required this.prayer,
    required this.status,
  });
  final String day;
  final ObligatoryPrayer prayer;
  final PrayerStatus status;
}

class VoluntaryLog {
  const VoluntaryLog({
    required this.id,
    required this.day,
    required this.kind,
    required this.units,
    required this.createdAt,
    this.note = '',
  });
  final String id;
  final String day;
  final VoluntaryWorship kind;
  final int units;
  final DateTime createdAt;
  final String note;
}

class MissedPrayerEntry {
  const MissedPrayerEntry({
    required this.id,
    required this.prayer,
    required this.kind,
    required this.delta,
    required this.createdAt,
    this.note = '',
  });
  final String id;
  final ObligatoryPrayer prayer;
  final LedgerKind kind;
  final int delta;
  final DateTime createdAt;
  final String note;
}

class WorshipSnapshot {
  WorshipSnapshot({
    required this.day,
    this.plan,
    this.completion,
    required List<DailyPrayerRecord> prayers,
    required List<VoluntaryLog> voluntary,
    required List<MissedPrayerEntry> ledger,
  }) : prayers = List.unmodifiable(prayers),
       voluntary = List.unmodifiable(voluntary),
       ledger = List.unmodifiable(ledger);
  final String day;
  final WirdPlan? plan;
  final WirdCompletion? completion;
  final List<DailyPrayerRecord> prayers;
  final List<VoluntaryLog> voluntary;
  final List<MissedPrayerEntry> ledger;
  bool get ledgerInitialized => ObligatoryPrayer.values.every(
    (prayer) => ledger.any(
      (event) => event.prayer == prayer && event.kind == LedgerKind.opening,
    ),
  );
  int remaining(ObligatoryPrayer prayer) => ledger
      .where((event) => event.prayer == prayer)
      .fold(0, (total, event) => total + event.delta);
  int get totalRemaining => ObligatoryPrayer.values.fold(
    0,
    (total, prayer) => total + remaining(prayer),
  );
  PrayerStatus status(ObligatoryPrayer prayer) =>
      prayers.where((record) => record.prayer == prayer).firstOrNull?.status ??
      PrayerStatus.pending;
  int get completedPrayers =>
      prayers.where((record) => record.status == PrayerStatus.completed).length;
}
