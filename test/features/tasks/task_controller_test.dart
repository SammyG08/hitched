import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/tasks/domain/wedding_task.dart';
import 'package:hitched/features/tasks/presentation/task_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import '../../support/task_fixture.dart';

void main() {
  test('filters, creates, completes, and deletes wedding tasks', () async {
    final repository = FakeTaskRepository(
      tasks: [
        taskFixture(id: 1, title: 'Book venue'),
        taskFixture(
          id: 2,
          title: 'Pay photographer',
          status: WeddingTaskStatus.done,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_AuthenticatedRepository()),
        weddingRepositoryProvider.overrideWithValue(_WeddingRepository()),
        weddingSelectionStorageProvider.overrideWithValue(_SelectionStorage()),
        taskRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container.read(weddingWorkspaceProvider.future);
    final initial = await container.read(taskListProvider.future);
    expect(initial.tasks, hasLength(2));

    container
        .read(taskListProvider.notifier)
        .setStatusFilter(WeddingTaskStatus.done);
    expect(
      container.read(taskListProvider).requireValue.visibleTasks,
      hasLength(1),
    );

    container.read(taskListProvider.notifier).setStatusFilter(null);
    final created = await container
        .read(taskListProvider.notifier)
        .saveTask(
          draft: const TaskDraft(
            title: 'Choose flowers',
            description: '',
            status: WeddingTaskStatus.todo,
            priority: WeddingTaskPriority.medium,
          ),
        );
    expect(created, isTrue);
    final newTask = container.read(taskListProvider).requireValue.tasks.last;

    expect(
      await container.read(taskListProvider.notifier).toggleTask(newTask),
      isTrue,
    );
    expect(
      container.read(taskListProvider.notifier).taskById(newTask.id)?.isDone,
      isTrue,
    );

    expect(
      await container.read(taskListProvider.notifier).deleteTask(newTask.id),
      isTrue,
    );
    expect(container.read(taskListProvider).requireValue.tasks, hasLength(2));
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
