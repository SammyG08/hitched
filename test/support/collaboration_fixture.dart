import 'package:hitched/features/collaboration/domain/collaboration_models.dart';
import 'package:hitched/features/collaboration/domain/collaboration_repository.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';

WeddingInvitation invitationFixture({
  int id = 1,
  String email = 'jamie@example.com',
  WeddingInvitationStatus status = WeddingInvitationStatus.pending,
}) {
  return WeddingInvitation(
    id: id,
    weddingId: 1,
    email: email,
    token: '11111111-1111-1111-1111-111111111111',
    status: status,
    invitedBy: const WeddingMemberUser(
      id: 1,
      email: 'alex@example.com',
      firstName: 'Alex',
      lastName: 'Morgan',
    ),
    expiresAt: DateTime(2030, 6, 21),
    createdAt: DateTime(2030, 6, 14),
  );
}

class FakeCollaborationRepository implements CollaborationRepository {
  List<WeddingInvitation> pendingInvitations = [];
  final invitations = <WeddingInvitation>[invitationFixture()];

  @override
  Future<List<WeddingInvitation>> fetchMyPendingInvitations() async =>
      pendingInvitations;

  @override
  Future<List<WeddingInvitation>> fetchInvitations(int weddingId) async =>
      List.unmodifiable(invitations);

  @override
  Future<WeddingInvitation> createInvitation(
    int weddingId,
    String email,
  ) async {
    final invitation = invitationFixture(
      id: invitations.length + 1,
      email: email.trim().toLowerCase(),
    );
    invitations.removeWhere(
      (item) => item.email.toLowerCase() == email.trim().toLowerCase(),
    );
    invitations.insert(0, invitation);
    return invitation;
  }

  @override
  Future<void> revokeInvitation(int weddingId, int invitationId) async {
    final old = invitations.firstWhere((item) => item.id == invitationId);
    invitations[invitations.indexOf(old)] = invitationFixture(
      id: old.id,
      email: old.email,
      status: WeddingInvitationStatus.revoked,
    );
  }

  @override
  Future<WeddingInvitationPreview> previewInvitation(String token) async {
    return WeddingInvitationPreview(
      email: 'jamie@example.com',
      weddingId: 1,
      weddingName: 'Alex & Jamie',
      weddingDate: DateTime(2030, 6, 14),
      location: 'Accra',
      status: WeddingInvitationStatus.pending,
      expiresAt: DateTime(2030, 6, 21),
    );
  }

  @override
  Future<WeddingMember> acceptInvitation(String token) async {
    return const WeddingMember(
      id: 2,
      user: WeddingMemberUser(
        id: 2,
        email: 'jamie@example.com',
        firstName: 'Jamie',
        lastName: 'Taylor',
      ),
      role: 'partner',
    );
  }
}
