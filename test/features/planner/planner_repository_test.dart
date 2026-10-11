import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/features/planner/data/document_planner_repository.dart';
import 'package:ramadan_assistant/features/planner/domain/planner_event.dart';

PlannerEvent event(String id, {int revision = 0, int hour = 10}) =>
    PlannerEvent(
      id: id,
      title: 'Meeting',
      startUtc: DateTime.utc(2026, 10, 20, hour),
      endUtc: DateTime.utc(2026, 10, 20, hour + 1),
      reminderMinutes: 10,
      meetUrl: 'https://meet.google.com/abc-defg-hij',
      revision: revision,
    );

void main() {
  late AppDatabase database;
  late DriftDocumentStore store;
  late DocumentPlannerRepository repository;
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    store = DriftDocumentStore(database);
    repository = DocumentPlannerRepository(store);
  });
  tearDown(() => database.close());

  test(
    'Typed events round trip in time order and retain high reminder IDs',
    () async {
      final later = await repository.save(event('later', hour: 15));
      await repository.save(event('earlier'));
      final events = await repository.list();
      expect(events.map((event) => event.id), ['earlier', 'later']);
      expect(later.notificationId, inInclusiveRange(1000000000, 1499999999));
      final changed = await repository.save(
        event('later', revision: later.revision, hour: 16),
      );
      expect(changed.notificationId, later.notificationId);
      expect(changed.startUtc.isUtc, isTrue);
      expect(changed.meetUrl, 'https://meet.google.com/abc-defg-hij');
      expect(changed.revision, 2);
      expect(changed.reminderAt, DateTime.utc(2026, 10, 20, 15, 50));
    },
  );

  test(
    'Stale event edit conflicts and deletion remains pending for future sync',
    () async {
      final saved = await repository.save(event('event'));
      await repository.save(event('event', revision: saved.revision, hour: 11));
      await expectLater(
        repository.save(event('event', revision: saved.revision)),
        throwsA(isA<DocumentConflict>()),
      );
      await repository.delete('event');
      expect(await repository.list(), isEmpty);
      expect((await store.pendingSync()).single.isDeleted, isTrue);
      await expectLater(
        repository.save(event('event', revision: 3)),
        throwsA(isA<DocumentConflict>()),
      );
    },
  );

  test('Invalid date/link cannot mutate storage', () async {
    final invalid = PlannerEvent(
      id: 'bad',
      title: 'Invalid',
      startUtc: DateTime.utc(2026, 10, 20, 10),
      endUtc: DateTime.utc(2026, 10, 20, 9),
    );
    await expectLater(
      repository.save(invalid),
      throwsA(isA<PlannerValidationException>()),
    );
    expect(await repository.list(), isEmpty);
    expect(isGoogleMeetLink('https://meet.google.com/abc-defg-hij'), isTrue);
    for (final url in [
      'http://meet.google.com/abc-defg-hij',
      'https://meet.google.com.evil.test/abc-defg-hij',
      'https://evil.test/',
      'https://user@meet.google.com/abc-defg-hij',
      'https://meet.google.com:8080/abc-defg-hij',
    ]) {
      expect(isGoogleMeetLink(url), isFalse, reason: url);
    }
  });

  test(
    'Corrupt or future schema data produces recoverable load error',
    () async {
      await store.upsert(DocumentPlannerRepository.namespace, 'broken', {
        'title': 3,
      });
      await expectLater(repository.list(), throwsA(isA<TypeError>()));
    },
  );
}
