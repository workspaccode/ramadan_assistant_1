class QuranReaderApp {
  const QuranReaderApp({required this.id, required this.label});
  final String id;
  final String label;
}

/// Opening an app never asserts reading or completion; confirmation stays manual.
abstract interface class QuranReaderPort {
  Future<List<QuranReaderApp>> availableApps();
  Future<bool> open({required String appId, required int page});
}

abstract interface class WorshipReminderPort {
  Future<bool> scheduleDailyWird({
    required int minuteOfDay,
    required String title,
    required String body,
  });
  Future<void> cancelDailyWird();
}
