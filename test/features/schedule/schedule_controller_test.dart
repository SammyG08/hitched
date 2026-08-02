import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/schedule/domain/schedule_models.dart';
import 'package:hitched/features/schedule/presentation/schedule_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import '../../support/schedule_fixture.dart';

void main() {
  test('filters timeline and reloads status changes from the server', () async {
    final repository = FakeScheduleRepository();
    repository.events.add(
      scheduleEventFixture(
        id: 2,
        title: 'Past planning session',
        status: ScheduleEventStatus.completed,
        isPast: true,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_AuthRepository()),
        weddingRepositoryProvider.overrideWithValue(_WeddingRepository()),
        weddingSelectionStorageProvider.overrideWithValue(_SelectionStorage()),
        scheduleRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(weddingWorkspaceProvider.future);
    await container.read(scheduleProvider.future);

    container
        .read(scheduleProvider.notifier)
        .setTimeFilter(ScheduleTimeFilter.upcoming);
    expect(
      container.read(scheduleProvider).requireValue.visibleEvents.single.title,
      'Ceremony rehearsal',
    );

    expect(
      await container
          .read(scheduleProvider.notifier)
          .updateStatus(1, ScheduleEventStatus.confirmed),
      isTrue,
    );
    final updated = container.read(scheduleProvider).requireValue;
    expect(updated.confirmedCount, 1);
    expect(updated.visibleEvents.single.status, ScheduleEventStatus.confirmed);
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
