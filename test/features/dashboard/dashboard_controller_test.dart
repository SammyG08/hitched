import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/dashboard/presentation/dashboard_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import '../../support/dashboard_fixture.dart';

void main() {
  test('reloads dashboard data when the selected wedding changes', () async {
    final dashboardRepository = FakeDashboardRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_AuthenticatedRepository()),
        weddingRepositoryProvider.overrideWithValue(_WeddingRepository()),
        weddingSelectionStorageProvider.overrideWithValue(_SelectionStorage()),
        dashboardRepositoryProvider.overrideWithValue(dashboardRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    final workspace = await container.read(weddingWorkspaceProvider.future);
    final firstDashboard = await container.read(dashboardProvider.future);

    expect(firstDashboard?.wedding.id, 1);

    await container
        .read(weddingWorkspaceProvider.notifier)
        .selectWedding(workspace.weddings.last);
    final secondDashboard = await container.read(dashboardProvider.future);

    expect(secondDashboard?.wedding.id, 2);
    expect(dashboardRepository.requestedWeddingIds, [1, 2]);
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

class _WeddingRepository implements WeddingRepository {
  static const weddings = [
    Wedding(
      id: 1,
      name: 'First wedding',
      location: 'Accra',
      currentUserRole: 'owner',
      memberCount: 1,
    ),
    Wedding(
      id: 2,
      name: 'Second wedding',
      location: 'Kumasi',
      currentUserRole: 'partner',
      memberCount: 2,
    ),
  ];

  @override
  Future<List<Wedding>> fetchWeddings() async => weddings;

  @override
  Future<Wedding> createWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async => throw UnimplementedError();
}

class _SelectionStorage implements WeddingSelectionStorage {
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
