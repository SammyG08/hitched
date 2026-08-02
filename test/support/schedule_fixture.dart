import 'package:hitched/features/schedule/domain/schedule_models.dart';
import 'package:hitched/features/schedule/domain/schedule_repository.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';

ScheduleEvent scheduleEventFixture({
  int id = 1,
  String title = 'Ceremony rehearsal',
  ScheduleEventStatus status = ScheduleEventStatus.planned,
  bool isPast = false,
}) {
  return ScheduleEvent(
    id: id,
    weddingId: 1,
    title: title,
    eventType: ScheduleEventType.ceremony,
    startAt: DateTime(2030, 6, 14, 15),
    endAt: DateTime(2030, 6, 14, 16),
    durationMinutes: 60,
    location: 'Garden venue',
    status: status,
    responsibleMember: const WeddingMember(
      id: 1,
      user: WeddingMemberUser(
        id: 1,
        email: 'alex@example.com',
        firstName: 'Alex',
        lastName: 'Morgan',
      ),
      role: 'owner',
    ),
    vendor: const ScheduleVendorReference(
      id: 1,
      name: 'Golden Spoon',
      serviceCategory: 'catering',
    ),
    createdBy: const WeddingMemberUser(
      id: 1,
      email: 'alex@example.com',
      firstName: 'Alex',
      lastName: 'Morgan',
    ),
    isPast: isPast,
    notes: 'Walk through the processional.',
  );
}

class FakeScheduleRepository implements ScheduleRepository {
  final events = <ScheduleEvent>[scheduleEventFixture()];

  @override
  Future<List<ScheduleEvent>> fetchEvents(int weddingId) async =>
      List.unmodifiable(events);

  @override
  Future<List<ScheduleVendorReference>> fetchVendors(int weddingId) async =>
      const [
        ScheduleVendorReference(
          id: 1,
          name: 'Golden Spoon',
          serviceCategory: 'catering',
        ),
      ];

  @override
  Future<ScheduleEvent> createEvent(
    int weddingId,
    ScheduleEventDraft draft,
  ) async {
    final event = _fromDraft(events.length + 1, draft);
    events.add(event);
    return event;
  }

  @override
  Future<ScheduleEvent> updateEvent(
    int weddingId,
    int eventId,
    ScheduleEventDraft draft,
  ) async {
    final old = events.firstWhere((event) => event.id == eventId);
    final updated = _fromDraft(eventId, draft);
    events[events.indexOf(old)] = updated;
    return updated;
  }

  @override
  Future<ScheduleEvent> updateStatus(
    int weddingId,
    int eventId,
    ScheduleEventStatus status,
  ) async {
    final old = events.firstWhere((event) => event.id == eventId);
    final updated = scheduleEventFixture(
      id: old.id,
      title: old.title,
      status: status,
      isPast: old.isPast,
    );
    events[events.indexOf(old)] = updated;
    return updated;
  }

  @override
  Future<void> deleteEvent(int weddingId, int eventId) async {
    events.removeWhere((event) => event.id == eventId);
  }

  ScheduleEvent _fromDraft(int id, ScheduleEventDraft draft) {
    return ScheduleEvent(
      id: id,
      weddingId: 1,
      title: draft.title,
      eventType: draft.eventType,
      startAt: draft.startAt,
      endAt: draft.endAt,
      durationMinutes: draft.endAt.difference(draft.startAt).inMinutes,
      location: draft.location,
      status: draft.status,
      responsibleMember: null,
      vendor: null,
      createdBy: const WeddingMemberUser(
        id: 1,
        email: 'alex@example.com',
        firstName: 'Alex',
        lastName: 'Morgan',
      ),
      isPast: false,
      notes: draft.notes,
    );
  }
}
