import '../../weddings/domain/wedding.dart';
import 'collaboration_models.dart';

abstract interface class CollaborationRepository {
  Future<List<WeddingInvitation>> fetchMyPendingInvitations();
  Future<List<WeddingInvitation>> fetchInvitations(int weddingId);
  Future<WeddingInvitation> createInvitation(int weddingId, String email);
  Future<void> revokeInvitation(int weddingId, int invitationId);
  Future<WeddingInvitationPreview> previewInvitation(String token);
  Future<WeddingMember> acceptInvitation(String token);
}
