import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

void main() {
  test('restores a selection and selects a newly created wedding', () async {
    final repository = _FakeWeddingRepository();
    final selectionStorage = _FakeSelectionStorage()..selectedId = 2;
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_AuthenticatedRepository()),
        weddingRepositoryProvider.overrideWithValue(repository),
        weddingSelectionStorageProvider.overrideWithValue(selectionStorage),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    final initial = await container.read(weddingWorkspaceProvider.future);

    expect(initial.selectedWedding?.id, 2);

    final succeeded = await container
        .read(weddingWorkspaceProvider.notifier)
        .createWedding(
          name: 'Reception celebration',
          location: 'Kumasi',
          weddingDate: DateTime(2027, 6, 12),
        );
    final updated = container.read(weddingWorkspaceProvider).requireValue;

    expect(succeeded, isTrue);
    expect(updated.weddings, hasLength(3));
    expect(updated.selectedWedding?.name, 'Reception celebration');
    expect(selectionStorage.selectedId, 3);

    await container.read(weddingWorkspaceProvider.notifier).refresh();
    expect(
      container.read(weddingWorkspaceProvider).requireValue.selectedWedding?.id,
      3,
    );
  });
}

class _AuthenticatedRepository implements AuthRepository {
  static const user = AppUser(
    id: 7,
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

class _FakeWeddingRepository implements WeddingRepository {
  final weddings = <Wedding>[
    const Wedding(
      id: 1,
      name: 'Garden wedding',
      location: 'Accra',
      currentUserRole: 'owner',
      memberCount: 1,
    ),
    const Wedding(
      id: 2,
      name: 'Beach wedding',
      location: 'Cape Coast',
      currentUserRole: 'partner',
      memberCount: 2,
    ),
  ];

  @override
  Future<List<Wedding>> fetchWeddings() async => List.unmodifiable(weddings);

  @override
  Future<Wedding> createWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async {
    final wedding = Wedding(
      id: 3,
      name: name,
      location: location,
      weddingDate: weddingDate,
      currentUserRole: 'owner',
      memberCount: 1,
    );
    weddings.add(wedding);
    return wedding;
  }
}

class _FakeSelectionStorage implements WeddingSelectionStorage {
  int? selectedId;

  @override
  Future<void> clearSelectedWeddingId(int userId) async => selectedId = null;

  @override
  Future<int?> readSelectedWeddingId(int userId) async => selectedId;

  @override
  Future<void> saveSelectedWeddingId(int userId, int weddingId) async {
    selectedId = weddingId;
  }
}
