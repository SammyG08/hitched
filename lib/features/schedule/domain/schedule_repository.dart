import 'schedule_models.dart';

abstract interface class ScheduleRepository {
  Future<List<ScheduleEvent>> fetchEvents(int weddingId);
  Future<List<ScheduleVendorReference>> fetchVendors(int weddingId);
  Future<ScheduleEvent> createEvent(int weddingId, ScheduleEventDraft draft);
  Future<ScheduleEvent> updateEvent(
    int weddingId,
    int eventId,
    ScheduleEventDraft draft,
  );
  Future<ScheduleEvent> updateStatus(
    int weddingId,
    int eventId,
    ScheduleEventStatus status,
  );
  Future<void> deleteEvent(int weddingId, int eventId);
}
