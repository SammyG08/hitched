import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/schedule/domain/schedule_models.dart';

void main() {
  test('parses assignments, duration and server-computed schedule fields', () {
    final event = ScheduleEvent.fromJson({
      'id': 6,
      'wedding': 2,
      'title': 'Wedding ceremony',
      'event_type': 'ceremony',
      'start_at': '2030-06-14T15:00:00Z',
      'end_at': '2030-06-14T16:00:00Z',
      'duration_minutes': 60,
      'location': 'Main venue',
      'status': 'confirmed',
      'responsible_member': {
        'id': 3,
        'user': {
          'id': 8,
          'email': 'jamie@example.com',
          'first_name': 'Jamie',
          'last_name': 'Taylor',
        },
        'role': 'partner',
        'joined_at': '2026-01-01T00:00:00Z',
      },
      'vendor': {
        'id': 4,
        'name': 'Example Studios',
        'service_category': 'photography',
      },
      'created_by': {
        'id': 7,
        'email': 'alex@example.com',
        'first_name': 'Alex',
        'last_name': 'Morgan',
      },
      'is_past': false,
      'notes': '',
    });

    expect(event.eventType, ScheduleEventType.ceremony);
    expect(event.status, ScheduleEventStatus.confirmed);
    expect(event.durationMinutes, 60);
    expect(event.responsibleMember?.user.displayName, 'Jamie Taylor');
    expect(event.vendor?.name, 'Example Studios');
    expect(event.isPast, isFalse);
  });
}
