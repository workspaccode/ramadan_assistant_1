import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/features/worship/data/worship_repository.dart';
import 'package:ramadan_assistant/features/worship/domain/worship_models.dart';
import 'package:ramadan_assistant/features/worship/domain/worship_ports.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_cubit.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_screen.dart';

class _FaultStore implements DocumentStore {
  _FaultStore(this.delegate);
  final DocumentStore delegate;
  String? failNamespace;
  int failWrite = 1;
  int writes = 0;
  bool failRead = false;
  bool failReadAfterWrite = false;
  @override
  Future<StoredDocument?> get(String namespace, String id) async {
    if (failRead) throw StateError('Disk unavailable');
    return delegate.get(namespace, id);
  }

  @override
  Future<List<StoredDocument>> list(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  }) => delegate.list(
    namespace,
    includeDeleted: includeDeleted,
    fromSortKey: fromSortKey,
    toSortKey: toSortKey,
    limit: limit,
  );
  @override
  Stream<List<StoredDocument>> watch(
    String namespace, {
    bool includeDeleted = false,
    String? fromSortKey,
    String? toSortKey,
    int? limit,
  }) => delegate.watch(
    namespace,
    includeDeleted: includeDeleted,
    fromSortKey: fromSortKey,
    toSortKey: toSortKey,
    limit: limit,
  );
  @override
  Future<StoredDocument> upsert(
    String namespace,
    String id,
    Map<String, Object?> data, {
    String? sortKey,
    int schemaVersion = 1,
    int? expectedRevision,
  }) {
    if (namespace == failNamespace && ++writes == failWrite) {
      throw StateError('Write failed');
    }
    final saved = delegate.upsert(
      namespace,
      id,
      data,
      sortKey: sortKey,
      schemaVersion: schemaVersion,
      expectedRevision: expectedRevision,
    );
    return saved.then((document) {
      if (failReadAfterWrite) failRead = true;
      return document;
    });
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      delegate.transaction(action);
  @override
  Future<void> delete(String namespace, String id) =>
      delegate.delete(namespace, id);
  @override
  Future<List<StoredDocument>> pendingSync({int? limit}) =>
      delegate.pendingSync(limit: limit);
  @override
  Future<bool> markSynced(String namespace, String id, int expectedRevision) =>
      delegate.markSynced(namespace, id, expectedRevision);
}

class _Reader implements QuranReaderPort {
  final opened = <int>[];
  @override
  Future<List<QuranReaderApp>> availableApps() async => [
    const QuranReaderApp(id: 'reader', label: 'Quran'),
  ];
  @override
  Future<bool> open({required String appId, required int page}) async {
    opened.add(page);
    return true;
  }
}

class _DeniedReminder implements WorshipReminderPort {
  @override
  Future<void> cancelDailyWird() async {}
  @override
  Future<bool> scheduleDailyWird({
    required int minuteOfDay,
    required String title,
    required String body,
  }) async => false;
}

void main() {
  late AppDatabase database;
  late _FaultStore store;
  late WorshipRepository repository;
  var now = DateTime(2026, 10, 11, 12);
  var sequence = 0;
  setUp(() {
    now = DateTime(2026, 10, 11, 12);
    sequence = 0;
    database = AppDatabase.forTesting(NativeDatabase.memory());
    store = _FaultStore(DriftDocumentStore(database));
    repository = WorshipRepository(
      store,
      clock: () => now,
      ids: () => 'entry-${++sequence}',
    );
  });
  tearDown(() => database.close());

  test(
    'Concurrent duplicate completion advances Quran plan exactly once',
    () async {
      await repository.savePlan(const WirdPlan(dailyPages: 3, nextPage: 603));
      await Future.wait([repository.completeWird(), repository.completeWird()]);
      final snapshot = await repository.load();
      expect(snapshot.completion!.startPage, 603);
      expect(snapshot.completion!.endPage, 1);
      expect(snapshot.plan!.nextPage, 2);
      expect(
        await store.list(WorshipRepository.completionNamespace),
        hasLength(1),
      );
      now = now.add(const Duration(days: 1));
      expect((await repository.load()).completion, isNull);
    },
  );

  test(
    'Completion and page advance rollback together on storage failure',
    () async {
      await repository.savePlan(const WirdPlan(dailyPages: 2, nextPage: 10));
      store.failNamespace = WorshipRepository.planNamespace;
      await expectLater(repository.completeWird(), throwsStateError);
      final snapshot = await repository.load();
      expect(snapshot.completion, isNull);
      expect(snapshot.plan!.nextPage, 10);
    },
  );

  test('Invalid plan and future manual records cannot write', () async {
    await expectLater(
      repository.savePlan(const WirdPlan(dailyPages: 0, nextPage: 1)),
      throwsA(isA<WorshipValidationException>()),
    );
    await expectLater(
      repository.recordPrayer(
        ObligatoryPrayer.fajr,
        PrayerStatus.completed,
        day: '2026-10-12',
      ),
      throwsA(isA<WorshipValidationException>()),
    );
    await expectLater(
      repository.recordPrayer(
        ObligatoryPrayer.fajr,
        PrayerStatus.completed,
        day: '2026-02-30',
      ),
      throwsA(isA<WorshipValidationException>()),
    );
    expect(await store.pendingSync(), isEmpty);
  });

  test('Daily missed records never fabricate historical debt', () async {
    await repository.recordPrayer(ObligatoryPrayer.fajr, PrayerStatus.missed);
    await repository.recordPrayer(
      ObligatoryPrayer.fajr,
      PrayerStatus.completed,
    );
    final snapshot = await repository.load();
    expect(snapshot.completedPrayers, 1);
    expect(snapshot.prayers, hasLength(1));
    expect(snapshot.ledger, isEmpty);
  });

  test(
    'Opening balances are per prayer and payment IDs are idempotent',
    () async {
      await repository.initializeLedger({
        for (final prayer in ObligatoryPrayer.values)
          prayer: prayer == ObligatoryPrayer.fajr ? 5 : 0,
      });
      await repository.payQada(ObligatoryPrayer.fajr, 2, requestId: 'payment');
      await repository.payQada(ObligatoryPrayer.fajr, 2, requestId: 'payment');
      final snapshot = await repository.load();
      expect(snapshot.remaining(ObligatoryPrayer.fajr), 3);
      expect(snapshot.remaining(ObligatoryPrayer.dhuhr), 0);
      expect(snapshot.ledger, hasLength(6));
      expect(
        snapshot.ledger.where((event) => event.kind == LedgerKind.payment),
        hasLength(1),
      );
      await expectLater(
        repository.payQada(ObligatoryPrayer.fajr, 4),
        throwsA(isA<WorshipValidationException>()),
      );
      expect((await repository.load()).remaining(ObligatoryPrayer.fajr), 3);
    },
  );

  test('Ledger opening is atomic and cannot be rewritten', () async {
    final counts = {for (final prayer in ObligatoryPrayer.values) prayer: 2};
    store.failNamespace = WorshipRepository.ledgerNamespace;
    store.failWrite = 3;
    await expectLater(repository.initializeLedger(counts), throwsStateError);
    expect((await repository.load()).ledger, isEmpty);
    store.failNamespace = null;
    await repository.initializeLedger(counts);
    await expectLater(
      repository.initializeLedger(counts),
      throwsA(isA<WorshipValidationException>()),
    );
    expect((await repository.load()).totalRemaining, 10);
  });

  test(
    'Payment failure preserves balances; adjustments require reason and nonnegative result',
    () async {
      await repository.initializeLedger({
        for (final prayer in ObligatoryPrayer.values) prayer: 2,
      });
      store.failNamespace = WorshipRepository.ledgerNamespace;
      await expectLater(
        repository.payQada(ObligatoryPrayer.fajr, 1),
        throwsStateError,
      );
      store.failNamespace = null;
      expect((await repository.load()).remaining(ObligatoryPrayer.fajr), 2);
      expect(
        () => repository.adjustLedger(ObligatoryPrayer.fajr, 1, note: ''),
        throwsA(isA<WorshipValidationException>()),
      );
      await expectLater(
        repository.adjustLedger(ObligatoryPrayer.fajr, -3, note: 'Correction'),
        throwsA(isA<WorshipValidationException>()),
      );
      await repository.adjustLedger(
        ObligatoryPrayer.fajr,
        -1,
        note: 'Corrected opening count',
      );
      expect((await repository.load()).remaining(ObligatoryPrayer.fajr), 1);
      expect(
        (await repository.load()).ledger.where(
          (event) => event.kind == LedgerKind.opening,
        ),
        hasLength(5),
      );
    },
  );

  test(
    'Voluntary prayer and fasting records persist with validated units',
    () async {
      await repository.addVoluntary(
        VoluntaryWorship.witr,
        3,
        requestId: 'witr',
      );
      await repository.addVoluntary(
        VoluntaryWorship.witr,
        3,
        requestId: 'witr',
      );
      await repository.addVoluntary(VoluntaryWorship.fasting, 1);
      await expectLater(
        repository.addVoluntary(VoluntaryWorship.fasting, 2),
        throwsA(isA<WorshipValidationException>()),
      );
      final reloaded = WorshipRepository(store, clock: () => now);
      expect((await reloaded.load()).voluntary, hasLength(2));
    },
  );

  test(
    'Reader launch is manual and reminder failure keeps saved plan visible',
    () async {
      final reader = _Reader();
      final cubit = WorshipCubit(
        repository,
        readers: reader,
        reminders: _DeniedReminder(),
      );
      addTearDown(cubit.close);
      await cubit.load();
      expect(
        await cubit.savePlan(
          const WirdPlan(
            dailyPages: 2,
            nextPage: 10,
            readerAppId: 'reader',
            reminderMinute: 1200,
          ),
          reminderTitle: 'Wird',
          reminderBody: 'Read',
        ),
        isTrue,
      );
      expect(cubit.state.noticeKey, 'worship_reminder_failed');
      expect(cubit.state.snapshot!.plan!.reminderMinute, 1200);
      expect(await cubit.openReader(), isTrue);
      expect(reader.opened, [10]);
      expect(cubit.state.snapshot!.completion, isNull);
    },
  );

  test(
    'Cubit catches initial and refresh failure without erasing the last snapshot',
    () async {
      final cubit = WorshipCubit(repository);
      addTearDown(cubit.close);
      store.failRead = true;
      await cubit.load();
      expect(cubit.state.errorKey, 'worship_load_failed');
      store.failRead = false;
      await cubit.load();
      final previous = cubit.state.snapshot;
      store.failRead = true;
      await cubit.load();
      expect(cubit.state.snapshot, same(previous));
      expect(cubit.state.busy, isFalse);
    },
  );

  test(
    'Date selection scopes manual prayers and rejects malformed or future dates',
    () async {
      final cubit = WorshipCubit(
        repository,
        initialDate: DateTime(2026, 10, 10),
      );
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.recordPrayer(ObligatoryPrayer.asr, PrayerStatus.completed);
      expect(cubit.state.snapshot!.day, '2026-10-10');
      expect(cubit.state.snapshot!.completedPrayers, 1);
      await cubit.load(day: '2026-02-30');
      expect(cubit.state.errorKey, 'worship_invalid_day');
      await cubit.load(day: '2026-10-12');
      expect(cubit.state.errorKey, 'worship_future_day');
      await cubit.load(day: '2026-10-11');
      expect(cubit.followsToday, isTrue);
      expect(cubit.state.snapshot!.completedPrayers, 0);
    },
  );

  test('Numeric forms understand Arabic and Urdu digits without rounding', () {
    expect(parseWorshipNumber('١٢٣'), 123);
    expect(parseWorshipNumber('−۱۲'), -12);
    expect(parseWorshipNumber('1.5'), isNull);
    expect(parseWorshipNumber(''), isNull);
  });

  test(
    'Post-commit reload failure reports saved and prevents a payment form retry',
    () async {
      await repository.initializeLedger({
        for (final prayer in ObligatoryPrayer.values) prayer: 2,
      });
      final cubit = WorshipCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      store.failReadAfterWrite = true;
      final saved = await cubit.payQada(ObligatoryPrayer.fajr, 1);
      expect(saved, isTrue);
      expect(cubit.state.errorKey, 'worship_refresh_failed');
      store.failReadAfterWrite = false;
      store.failRead = false;
      await cubit.load();
      expect(cubit.state.snapshot!.remaining(ObligatoryPrayer.fajr), 1);
      expect(
        cubit.state.snapshot!.ledger.where(
          (entry) => entry.kind == LedgerKind.payment,
        ),
        hasLength(1),
      );
    },
  );
}
