import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/collaboration/domain/collaboration_models.dart';

void main() {
  test('parses invitation status, users and public preview', () {
    final invitation = WeddingInvitation.fromJson({
      'id': 3,
      'wedding': 7,
      'email': 'jamie@example.com',
      'token': '11111111-1111-1111-1111-111111111111',
      'status': 'accepted',
      'invited_by': {
        'id': 1,
        'email': 'alex@example.com',
        'first_name': 'Alex',
        'last_name': 'Morgan',
      },
      'accepted_by': {
        'id': 2,
        'email': 'jamie@example.com',
        'first_name': 'Jamie',
        'last_name': 'Taylor',
      },
      'expires_at': '2030-06-21T00:00:00Z',
      'accepted_at': '2030-06-15T10:00:00Z',
      'revoked_at': null,
      'created_at': '2030-06-14T10:00:00Z',
    });
    final preview = WeddingInvitationPreview.fromJson({
      'email': 'jamie@example.com',
      'wedding_id': 7,
      'wedding_name': 'Alex & Jamie',
      'wedding_date': '2030-06-14',
      'location': 'Accra',
      'status': 'pending',
      'expires_at': '2030-06-21T00:00:00Z',
    });

    expect(invitation.status, WeddingInvitationStatus.accepted);
    expect(invitation.acceptedBy?.displayName, 'Jamie Taylor');
    expect(preview.weddingName, 'Alex & Jamie');
    expect(preview.canAccept, isTrue);
  });
}
