import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/collaboration/domain/collaboration_models.dart';
import 'package:hitched/features/collaboration/presentation/collaboration_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import '../../support/collaboration_fixture.dart';

void main() {
  test('owner can create and revoke email invitations', () async {
    final repository = FakeCollaborationRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_AuthRepository()),
        weddingRepositoryProvider.overrideWithValue(_WeddingRepository()),
        weddingSelectionStorageProvider.overrideWithValue(_SelectionStorage()),
        collaborationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(weddingWorkspaceProvider.future);
    final initial = await container.read(collaborationProvider.future);
    expect(initial.members.single.user.displayName, 'Alex Morgan');

    expect(
      await container
          .read(collaborationProvider.notifier)
          .invite('new.partner@example.com'),
      isTrue,
    );
    final created = container.read(collaborationProvider).requireValue;
    expect(created.invitations, hasLength(2));

    expect(
      await container.read(collaborationProvider.notifier).revoke(2),
      isTrue,
    );
    expect(
      container
          .read(collaborationProvider)
          .requireValue
          .invitations
          .first
          .status,
      WeddingInvitationStatus.revoked,
    );
  });
}

class _AuthRepository implements AuthRepository {
  static const user = AppUser(
    id: 1,
    email: 'alex@example.com',
    firstName: 'Alex',
    lastName: 'Morgan',
  );

  @override
  Future<AppUser?> restoreSession() async => user;
  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async => user;
  @override
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async => user;
  @override
  Future<void> logout() async {}
}

class _WeddingRepository implements WeddingRepository {
  @override
  Future<List<Wedding>> fetchWeddings() async => const [
    Wedding(
      id: 1,
      name: 'Alex & Jamie',
      location: 'Accra',
      currentUserRole: 'owner',
      memberCount: 1,
      members: [
        WeddingMember(
          id: 1,
          user: WeddingMemberUser(
            id: 1,
            email: 'alex@example.com',
            firstName: 'Alex',
            lastName: 'Morgan',
          ),
          role: 'owner',
        ),
      ],
    ),
  ];
  @override
  Future<Wedding> createWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async => throw UnimplementedError();
}

class _SelectionStorage implements WeddingSelectionStorage {
  @override
  Future<void> clearSelectedWeddingId(int userId) async {}
  @override
  Future<int?> readSelectedWeddingId(int userId) async => 1;
  @override
  Future<void> saveSelectedWeddingId(int userId, int weddingId) async {}
}
