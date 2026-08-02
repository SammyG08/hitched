import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/app/app.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

void main() {
  testWidgets('user can sign in and reach the authenticated home screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          weddingRepositoryProvider.overrideWithValue(_FakeWeddingRepository()),
          weddingSelectionStorageProvider.overrideWithValue(
            _FakeWeddingSelectionStorage(),
          ),
        ],
        child: const HitchedApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'alex@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'a-secure-test-password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Alex'), findsOneWidget);
    expect(find.text('Alex & Jamie'), findsWidgets);
    expect(find.text('Plan together'), findsOneWidget);
  });
}

class _FakeWeddingRepository implements WeddingRepository {
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
  }) async {
    return Wedding(
      id: 2,
      name: name,
      location: location,
      weddingDate: weddingDate,
      currentUserRole: 'owner',
      memberCount: 1,
    );
  }
}

class _FakeWeddingSelectionStorage implements WeddingSelectionStorage {
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

class _FakeAuthRepository implements AuthRepository {
  static const user = AppUser(
    id: 1,
    email: 'alex@example.com',
    firstName: 'Alex',
    lastName: 'Morgan',
  );

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    return user;
  }

  @override
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    return user;
  }

  @override
  Future<void> logout() async {}
}
