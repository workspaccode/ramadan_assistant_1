import '../domain/worship_models.dart';

class WorshipCodec {
  static Map<String, Object?> plan(WirdPlan value) => {
    'dailyPages': value.dailyPages,
    'nextPage': value.nextPage,
    'reminderMinute': value.reminderMinute,
    'readerAppId': value.readerAppId,
  };
  static WirdPlan readPlan(Map<String, Object?> data) {
    final value = WirdPlan(
      dailyPages: data['dailyPages'] as int,
      nextPage: data['nextPage'] as int,
      reminderMinute: data['reminderMinute'] as int?,
      readerAppId: data['readerAppId'] as String?,
    );
    value.validate();
    return value;
  }

  static Map<String, Object?> completion(WirdCompletion value) => {
    'day': value.day,
    'startPage': value.startPage,
    'pages': value.pages,
    'completedAt': value.completedAt.toUtc().toIso8601String(),
  };
  static WirdCompletion readCompletion(Map<String, Object?> data) {
    final value = WirdCompletion(
      day: data['day'] as String,
      startPage: data['startPage'] as int,
      pages: data['pages'] as int,
      completedAt: DateTime.parse(data['completedAt'] as String),
    );
    validateWorshipDay(value.day);
    WirdPlan(dailyPages: value.pages, nextPage: value.startPage).validate();
    return value;
  }

  static Map<String, Object?> prayer(DailyPrayerRecord value) => {
    'day': value.day,
    'prayer': value.prayer.name,
    'status': value.status.name,
  };
  static DailyPrayerRecord readPrayer(Map<String, Object?> data) {
    final value = DailyPrayerRecord(
      day: data['day'] as String,
      prayer: ObligatoryPrayer.values.byName(data['prayer'] as String),
      status: PrayerStatus.values.byName(data['status'] as String),
    );
    validateWorshipDay(value.day);
    return value;
  }

  static Map<String, Object?> voluntary(VoluntaryLog value) => {
    'day': value.day,
    'kind': value.kind.name,
    'units': value.units,
    'createdAt': value.createdAt.toUtc().toIso8601String(),
    'note': value.note,
  };
  static VoluntaryLog readVoluntary(String id, Map<String, Object?> data) {
    final value = VoluntaryLog(
      id: id,
      day: data['day'] as String,
      kind: VoluntaryWorship.values.byName(data['kind'] as String),
      units: data['units'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String),
      note: data['note'] as String? ?? '',
    );
    validateWorshipDay(value.day);
    if (value.units < 1 ||
        value.units > 1000 ||
        (value.kind == VoluntaryWorship.fasting && value.units != 1)) {
      throw const WorshipValidationException('worship_invalid_units');
    }
    return value;
  }

  static Map<String, Object?> ledger(MissedPrayerEntry value) => {
    'prayer': value.prayer.name,
    'kind': value.kind.name,
    'delta': value.delta,
    'createdAt': value.createdAt.toUtc().toIso8601String(),
    'note': value.note,
  };
  static MissedPrayerEntry readLedger(String id, Map<String, Object?> data) {
    final value = MissedPrayerEntry(
      id: id,
      prayer: ObligatoryPrayer.values.byName(data['prayer'] as String),
      kind: LedgerKind.values.byName(data['kind'] as String),
      delta: data['delta'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String),
      note: data['note'] as String? ?? '',
    );
    if (value.delta.abs() > 1000000000 ||
        (value.kind == LedgerKind.opening && value.delta < 0) ||
        (value.kind == LedgerKind.payment && value.delta >= 0) ||
        (value.kind == LedgerKind.adjustment &&
            (value.delta == 0 || value.note.trim().isEmpty))) {
      throw const WorshipValidationException('worship_invalid_count');
    }
    return value;
  }
}
