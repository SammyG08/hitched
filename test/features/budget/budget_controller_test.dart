import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/budget/domain/budget_models.dart';
import 'package:hitched/features/budget/presentation/budget_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import '../../support/budget_fixture.dart';

void main() {
  test(
    'filters expenses and refreshes server-derived payment status',
    () async {
      final repository = FakeBudgetRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_AuthRepository()),
          weddingRepositoryProvider.overrideWithValue(_WeddingRepository()),
          weddingSelectionStorageProvider.overrideWithValue(
            _SelectionStorage(),
          ),
          budgetRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      await container.read(weddingWorkspaceProvider.future);
      final initial = await container.read(budgetProvider.future);
      expect(
        initial.expenses.single.paymentStatus,
        ExpensePaymentStatus.partiallyPaid,
      );

      container
          .read(budgetProvider.notifier)
          .setPaymentFilter(ExpensePaymentStatus.paid);
      expect(
        container.read(budgetProvider).requireValue.visibleExpenses,
        isEmpty,
      );

      expect(
        await container.read(budgetProvider.notifier).recordPayment(1, 9000),
        isTrue,
      );
      final updated = container.read(budgetProvider).requireValue;
      expect(
        updated.visibleExpenses.single.paymentStatus,
        ExpensePaymentStatus.paid,
      );
      expect(updated.visibleExpenses.single.outstandingAmount, 0);
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
