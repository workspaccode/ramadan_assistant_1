import '../../../core/persistence/document_store.dart';
import 'worship_models.dart';

/// Typed application boundary; presentation never knows the storage engine.
abstract interface class WorshipData {
  AppClock get clock;
  Future<WorshipSnapshot> load({String? day});
  Future<void> savePlan(WirdPlan plan);
  Future<WirdCompletion> completeWird({String? day});
  Future<void> recordPrayer(
    ObligatoryPrayer prayer,
    PrayerStatus status, {
    String? day,
  });
  Future<void> addVoluntary(
    VoluntaryWorship kind,
    int units, {
    String note = '',
    String? day,
    String? requestId,
  });
  Future<void> initializeLedger(Map<ObligatoryPrayer, int> opening);
  Future<void> payQada(
    ObligatoryPrayer prayer,
    int count, {
    String note = '',
    String? requestId,
  });
  Future<void> adjustLedger(
    ObligatoryPrayer prayer,
    int delta, {
    required String note,
    String? requestId,
  });
}
