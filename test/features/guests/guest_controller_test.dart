import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/guests/domain/guest_models.dart';
import 'package:hitched/features/guests/presentation/guest_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import '../../support/guest_fixture.dart';

void main() {
  test(
    'filters guests and keeps household totals fresh after RSVP changes',
    () async {
      final repository = FakeGuestRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_AuthRepository()),
          weddingRepositoryProvider.overrideWithValue(_WeddingRepository()),
          weddingSelectionStorageProvider.overrideWithValue(
            _SelectionStorage(),
          ),
          guestRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      await container.read(weddingWorkspaceProvider.future);
      final initial = await container.read(guestListProvider.future);
      expect(initial.guests, hasLength(1));

      container
          .read(guestListProvider.notifier)
          .setRsvpFilter(GuestRsvpStatus.pending);
      expect(
        container.read(guestListProvider).requireValue.visibleHouseholds,
        hasLength(1),
      );

      expect(
        await container
            .read(guestListProvider.notifier)
            .updateRsvp(1, GuestRsvpStatus.attending),
        isTrue,
      );
      final updated = container.read(guestListProvider).requireValue;
      expect(updated.households.single.attendingCount, 1);
      expect(updated.visibleHouseholds, isEmpty);
    },
  );
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
