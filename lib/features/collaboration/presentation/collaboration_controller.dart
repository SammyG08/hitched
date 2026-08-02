import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../weddings/domain/wedding.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_collaboration_repository.dart';
import '../domain/collaboration_models.dart';
import '../domain/collaboration_repository.dart';

final collaborationRepositoryProvider = Provider<CollaborationRepository>((
  ref,
) {
  return DjangoCollaborationRepository(ref.watch(apiClientProvider));
});

final invitationPreviewProvider = FutureProvider.autoDispose
    .family<WeddingInvitationPreview, String>((ref, token) {
      return ref
          .watch(collaborationRepositoryProvider)
          .previewInvitation(token);
    });

final collaborationProvider =
    AsyncNotifierProvider<CollaborationController, CollaborationState>(
      CollaborationController.new,
    );

class CollaborationState {
  const CollaborationState({
    required this.members,
    required this.invitations,
    required this.isOwner,
    this.isMutating = false,
    this.actionError,
  });

  const CollaborationState.empty()
    : members = const [],
      invitations = const [],
      isOwner = false,
      isMutating = false,
      actionError = null;

  final List<WeddingMember> members;
  final List<WeddingInvitation> invitations;
  final bool isOwner;
  final bool isMutating;
  final Object? actionError;

  CollaborationState copyWith({
    List<WeddingMember>? members,
    List<WeddingInvitation>? invitations,
    bool? isOwner,
    bool? isMutating,
    Object? actionError,
    bool clearActionError = false,
  }) {
    return CollaborationState(
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      isOwner: isOwner ?? this.isOwner,
      isMutating: isMutating ?? this.isMutating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class CollaborationController extends AsyncNotifier<CollaborationState> {
  CollaborationRepository get _repository =>
      ref.read(collaborationRepositoryProvider);

  int? get _weddingId =>
      ref.read(weddingWorkspaceProvider).value?.selectedWedding?.id;

  @override
  Future<CollaborationState> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return const CollaborationState.empty();
    final wedding = workspace.requireValue.selectedWedding;
    if (wedding == null) return const CollaborationState.empty();
    return CollaborationState(
      members: wedding.members,
      invitations: wedding.isOwner
          ? await _repository.fetchInvitations(wedding.id)
          : const [],
      isOwner: wedding.isOwner,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<bool> invite(String email) {
    return _mutate(
      (weddingId) => _repository.createInvitation(weddingId, email),
    );
  }

  Future<bool> revoke(int invitationId) {
    return _mutate(
      (weddingId) => _repository.revokeInvitation(weddingId, invitationId),
    );
  }

  Future<bool> _mutate(Future<void> Function(int weddingId) operation) async {
    final weddingId = _weddingId;
    if (weddingId == null) return false;
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(isMutating: true, clearActionError: true),
    );
    try {
      await operation(weddingId);
      state = AsyncData(
        current.copyWith(
          invitations: await _repository.fetchInvitations(weddingId),
          isMutating: false,
          clearActionError: true,
        ),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isMutating: false, actionError: error),
      );
      return false;
    }
  }
}
