import '../../../core/persistence/document_store.dart';
import '../domain/worship_models.dart';
import '../domain/worship_data.dart';
import 'worship_codec.dart';

class WorshipRepository implements WorshipData {
  WorshipRepository(this.store, {AppClock? clock, RecordIdGenerator? ids})
    : clock = clock ?? DateTime.now,
      ids = ids ?? newRecordId;
  final DocumentStore store;
  @override
  final AppClock clock;
  final RecordIdGenerator ids;
  static const planNamespace = 'worship.plan';
  static const completionNamespace = 'worship.wird_completion';
  static const prayerNamespace = 'worship.daily_prayer';
  static const voluntaryNamespace = 'worship.voluntary';
  static const ledgerNamespace = 'worship.missed_ledger';

  @override
  Future<WorshipSnapshot> load({String? day}) async {
    final selected = day ?? worshipDay(clock());
    validateWorshipDay(selected);
    final plan = await store.get(planNamespace, 'current');
    final completion = await store.get(completionNamespace, selected);
    final prayers = await store.list(
      prayerNamespace,
      fromSortKey: selected,
      toSortKey: selected,
    );
    final voluntary = await store.list(
      voluntaryNamespace,
      fromSortKey: selected,
      toSortKey: selected,
    );
    final ledger = await store.list(ledgerNamespace);
    return WorshipSnapshot(
      day: selected,
      plan: plan == null || plan.isDeleted
          ? null
          : WorshipCodec.readPlan(plan.data),
      completion: completion == null || completion.isDeleted
          ? null
          : WorshipCodec.readCompletion(completion.data),
      prayers: prayers.map((doc) => WorshipCodec.readPrayer(doc.data)).toList(),
      voluntary: voluntary
          .map((doc) => WorshipCodec.readVoluntary(doc.id, doc.data))
          .toList(),
      ledger:
          ledger
              .map((doc) => WorshipCodec.readLedger(doc.id, doc.data))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<void> savePlan(WirdPlan plan) async {
    plan.validate();
    await store.transaction(() async {
      final current = await store.get(planNamespace, 'current');
      await store.upsert(
        planNamespace,
        'current',
        WorshipCodec.plan(plan),
        expectedRevision: current?.revision ?? 0,
      );
    });
  }

  @override
  Future<WirdCompletion> completeWird({String? day}) =>
      store.transaction(() async {
        final selected = day ?? worshipDay(clock());
        validateWorshipDay(selected);
        if (selected != worshipDay(clock())) {
          throw const WorshipValidationException('worship_today_only');
        }
        final existing = await store.get(completionNamespace, selected);
        if (existing != null && !existing.isDeleted) {
          return WorshipCodec.readCompletion(existing.data);
        }
        final planDocument = await store.get(planNamespace, 'current');
        if (planDocument == null || planDocument.isDeleted) {
          throw const WorshipValidationException('worship_plan_required');
        }
        final plan = WorshipCodec.readPlan(planDocument.data);
        final completion = WirdCompletion(
          day: selected,
          startPage: plan.nextPage,
          pages: plan.dailyPages,
          completedAt: clock(),
        );
        await store.upsert(
          completionNamespace,
          selected,
          WorshipCodec.completion(completion),
          sortKey: selected,
          expectedRevision: existing?.revision ?? 0,
        );
        await store.upsert(
          planNamespace,
          'current',
          WorshipCodec.plan(plan.advance()),
          expectedRevision: planDocument.revision,
        );
        return completion;
      });

  @override
  Future<void> recordPrayer(
    ObligatoryPrayer prayer,
    PrayerStatus status, {
    String? day,
  }) async {
    final selected = day ?? worshipDay(clock());
    validateWorshipDay(selected);
    if (selected.compareTo(worshipDay(clock())) > 0) {
      throw const WorshipValidationException('worship_future_day');
    }
    final id = '$selected:${prayer.name}';
    await store.transaction(() async {
      final current = await store.get(prayerNamespace, id);
      final value = DailyPrayerRecord(
        day: selected,
        prayer: prayer,
        status: status,
      );
      await store.upsert(
        prayerNamespace,
        id,
        WorshipCodec.prayer(value),
        sortKey: selected,
        expectedRevision: current?.revision ?? 0,
      );
    });
  }

  @override
  Future<void> addVoluntary(
    VoluntaryWorship kind,
    int units, {
    String note = '',
    String? day,
    String? requestId,
  }) async {
    final selected = day ?? worshipDay(clock());
    validateWorshipDay(selected);
    if (selected.compareTo(worshipDay(clock())) > 0) {
      throw const WorshipValidationException('worship_future_day');
    }
    if (units < 1 ||
        units > 1000 ||
        (kind == VoluntaryWorship.fasting && units != 1) ||
        note.length > 500) {
      throw const WorshipValidationException('worship_invalid_units');
    }
    final id = requestId ?? ids();
    await store.transaction(() async {
      final existing = await store.get(voluntaryNamespace, id);
      if (existing != null) {
        final value = WorshipCodec.readVoluntary(id, existing.data);
        if (value.kind != kind ||
            value.units != units ||
            value.day != selected ||
            value.note != note.trim()) {
          throw const WorshipValidationException('worship_duplicate_request');
        }
        return;
      }
      final value = VoluntaryLog(
        id: id,
        day: selected,
        kind: kind,
        units: units,
        note: note.trim(),
        createdAt: clock(),
      );
      await store.upsert(
        voluntaryNamespace,
        id,
        WorshipCodec.voluntary(value),
        sortKey: selected,
        expectedRevision: 0,
      );
    });
  }

  @override
  Future<void> initializeLedger(Map<ObligatoryPrayer, int> opening) =>
      store.transaction(() async {
        if (opening.length != 5 ||
            !ObligatoryPrayer.values.every(opening.containsKey) ||
            opening.values.any((count) => count < 0 || count > 1000000000)) {
          throw const WorshipValidationException('worship_invalid_count');
        }
        if ((await store.list(ledgerNamespace)).isNotEmpty) {
          throw const WorshipValidationException('worship_ledger_initialized');
        }
        for (final prayer in ObligatoryPrayer.values) {
          final value = MissedPrayerEntry(
            id: 'opening:${prayer.name}',
            prayer: prayer,
            kind: LedgerKind.opening,
            delta: opening[prayer]!,
            createdAt: clock(),
          );
          await store.upsert(
            ledgerNamespace,
            value.id,
            WorshipCodec.ledger(value),
            sortKey: value.createdAt.toUtc().toIso8601String(),
            expectedRevision: 0,
          );
        }
      });

  @override
  Future<void> payQada(
    ObligatoryPrayer prayer,
    int count, {
    String note = '',
    String? requestId,
  }) {
    if (count <= 0 || count > 1000000000) {
      throw const WorshipValidationException('worship_invalid_count');
    }
    return _appendLedger(
      prayer,
      LedgerKind.payment,
      -count,
      note,
      requestId ?? ids(),
    );
  }

  @override
  Future<void> adjustLedger(
    ObligatoryPrayer prayer,
    int delta, {
    required String note,
    String? requestId,
  }) {
    if (delta == 0 || delta.abs() > 1000000000 || note.trim().isEmpty) {
      throw const WorshipValidationException('worship_adjustment_reason');
    }
    return _appendLedger(
      prayer,
      LedgerKind.adjustment,
      delta,
      note,
      requestId ?? ids(),
    );
  }

  Future<void> _appendLedger(
    ObligatoryPrayer prayer,
    LedgerKind kind,
    int delta,
    String note,
    String id,
  ) => store.transaction(() async {
    if (note.length > 500) {
      throw const WorshipValidationException('worship_invalid_note');
    }
    final existing = await store.get(ledgerNamespace, id);
    if (existing != null) {
      final value = WorshipCodec.readLedger(id, existing.data);
      if (value.prayer != prayer ||
          value.kind != kind ||
          value.delta != delta ||
          value.note != note.trim()) {
        throw const WorshipValidationException('worship_duplicate_request');
      }
      return;
    }
    final values = (await store.list(
      ledgerNamespace,
    )).map((doc) => WorshipCodec.readLedger(doc.id, doc.data)).toList();
    if (!ObligatoryPrayer.values.every(
      (prayer) => values.any(
        (event) => event.prayer == prayer && event.kind == LedgerKind.opening,
      ),
    )) {
      throw const WorshipValidationException('worship_opening_required');
    }
    final remaining = values
        .where((value) => value.prayer == prayer)
        .fold(0, (total, value) => total + value.delta);
    if (remaining + delta < 0) {
      throw const WorshipValidationException('worship_exceeds_remaining');
    }
    final value = MissedPrayerEntry(
      id: id,
      prayer: prayer,
      kind: kind,
      delta: delta,
      note: note.trim(),
      createdAt: clock(),
    );
    await store.upsert(
      ledgerNamespace,
      id,
      WorshipCodec.ledger(value),
      sortKey: value.createdAt.toUtc().toIso8601String(),
      expectedRevision: 0,
    );
  });
}
