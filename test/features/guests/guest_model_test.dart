import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/guests/domain/guest_models.dart';

void main() {
  test('parses household summaries and plus-one guest relationships', () {
    final household = GuestHousehold.fromJson({
      'id': 2,
      'wedding': 1,
      'name': 'The Morgan Family',
      'contact_email': 'morgan@example.com',
      'contact_phone': '',
      'address': '',
      'invitation_status': 'sent',
      'invitation_sent_at': '2026-08-01T10:00:00Z',
      'guest_count': 2,
      'attending_count': 1,
      'guests': [
        {
          'id': 5,
          'full_name': 'Robin Morgan',
          'is_plus_one': false,
          'rsvp_status': 'attending',
        },
      ],
    });

    expect(household.invitationStatus, InvitationStatus.sent);
    expect(household.attendingCount, 1);
    expect(household.guests.single.fullName, 'Robin Morgan');
  });
}
