import 'package:ramadan_assistant/core/persistence/document_store.dart';
import '../domain/planner_event.dart';
import '../domain/planner_ports.dart';

class DocumentPlannerRepository implements PlannerRepository {
  DocumentPlannerRepository(this.store);
  final DocumentStore store;
  static const namespace = 'planner.events';

  PlannerEvent _decode(StoredDocument document) {
    if (document.schemaVersion != 1) {
      throw const FormatException('Unsupported planner record');
    }
    final data = document.data;
    final event = PlannerEvent(
      id: document.id,
      title: data['title'] as String,
      startUtc: DateTime.parse(data['startUtc'] as String).toUtc(),
      endUtc: DateTime.parse(data['endUtc'] as String).toUtc(),
      notes: data['notes'] as String? ?? '',
      reminderMinutes: data['reminderMinutes'] as int?,
      ringUntilStopped: data['ringUntilStopped'] as bool? ?? false,
      meetUrl: data['meetUrl'] as String?,
      notificationId: data['notificationId'] as int,
      revision: document.revision,
      deviceCalendarId: data['deviceCalendarId'] as int?,
      deviceEventId: data['deviceEventId'] as int?,
    );
    event.validate();
    if (event.notificationId < 1000000000 ||
        event.notificationId >= 1500000000) {
      throw const FormatException('Invalid planner notification ID');
    }
    return event;
  }

  List<PlannerEvent> _decodeList(List<StoredDocument> documents) {
    final events = documents.map(_decode).toList();
    events.sort((a, b) => a.startUtc.compareTo(b.startUtc));
    return events;
  }

  @override
  Future<List<PlannerEvent>> list() async =>
      _decodeList(await store.list(namespace));

  @override
  Stream<List<PlannerEvent>> watch() => store.watch(namespace).map(_decodeList);

  @override
  Future<PlannerEvent> save(PlannerEvent event) async {
    event.validate();
    return store.transaction(() async {
      final existing = await store.get(namespace, event.id);
      if (existing != null && existing.isDeleted) {
        throw DocumentConflict(namespace, event.id);
      }
      var notificationId = existing?.data['notificationId'] as int? ?? 0;
      if (notificationId == 0) {
        // Persist an allocated ID so reminder replacements are stable across
        // restarts. Resolve hash collisions against all reserved document IDs.
        var hash = 2166136261;
        for (final unit in event.id.codeUnits) {
          hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
        }
        notificationId = 1000000000 + hash % 500000000;
        final used = (await store.list(
          namespace,
          includeDeleted: true,
        )).map((document) => document.data['notificationId']).toSet();
        while (used.contains(notificationId)) {
          notificationId =
              1000000000 + (notificationId - 1000000000 + 1) % 500000000;
        }
      }
      final document = await store.upsert(
        namespace,
        event.id,
        {
          'title': event.title.trim(),
          'startUtc': event.startUtc.toIso8601String(),
          'endUtc': event.endUtc.toIso8601String(),
          'notes': event.notes,
          'reminderMinutes': event.reminderMinutes,
          'ringUntilStopped': event.ringUntilStopped,
          'meetUrl': event.meetUrl?.trim().isEmpty == true
              ? null
              : event.meetUrl?.trim(),
          'notificationId': notificationId,
          'deviceCalendarId': event.deviceCalendarId,
          'deviceEventId': event.deviceEventId,
        },
        sortKey: event.startUtc.toIso8601String(),
        expectedRevision: event.revision,
      );
      return _decode(document);
    });
  }

  @override
  Future<void> delete(String id) => store.delete(namespace, id);
}
