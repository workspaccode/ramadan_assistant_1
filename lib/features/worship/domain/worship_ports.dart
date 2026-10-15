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

class OverlayStatus {
  const OverlayStatus({this.canDraw = false, this.usageAccess = false});
  final bool canDraw;
  final bool usageAccess;
}

/// Already-localized text for the floating helper (the port never translates).
class ReaderOverlayRequest {
  const ReaderOverlayRequest({
    required this.packageName,
    required this.title,
    required this.body,
    required this.doneLabel,
    required this.closeLabel,
    this.autoHide = false,
    this.timeout = const Duration(minutes: 30),
  });
  final String packageName;
  final String title;
  final String body;
  final String doneLabel;
  final String closeLabel;
  final bool autoHide;
  final Duration timeout;
}

/// Optional bubble over the chosen reader. Showing it never asserts reading: its
/// Done button only asks the app to confirm; recording stays a user decision.
abstract interface class ReaderOverlayPort {
  Future<OverlayStatus> status();
  Future<void> openOverlaySettings();
  Future<void> openUsageSettings();
  Future<bool> show(ReaderOverlayRequest request);
  Future<void> hide();

  /// True once if the bubble's Done button asked for confirmation. The Done
  /// button reopens the worship screen, whose load() consumes this flag.
  Future<bool> takePendingDone();
}

class ReaderOverlayCopy {
  const ReaderOverlayCopy({
    required this.title,
    required this.body,
    required this.doneLabel,
    required this.closeLabel,
  });
  final String title;
  final String body;
  final String doneLabel;
  final String closeLabel;
}
