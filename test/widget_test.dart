import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/app/app.dart';
import 'package:hitched/features/auth/domain/app_user.dart';
import 'package:hitched/features/auth/domain/auth_repository.dart';
import 'package:hitched/features/auth/presentation/auth_controller.dart';
import 'package:hitched/features/budget/presentation/budget_controller.dart';
import 'package:hitched/features/collaboration/presentation/collaboration_controller.dart';
import 'package:hitched/features/dashboard/presentation/dashboard_controller.dart';
import 'package:hitched/features/guests/presentation/guest_controller.dart';
import 'package:hitched/features/schedule/presentation/schedule_controller.dart';
import 'package:hitched/features/tasks/presentation/task_controller.dart';
import 'package:hitched/features/vendors/presentation/vendor_controller.dart';
import 'package:hitched/features/weddings/domain/wedding.dart';
import 'package:hitched/features/weddings/domain/wedding_repository.dart';
import 'package:hitched/features/weddings/presentation/wedding_workspace_controller.dart';

import 'support/dashboard_fixture.dart';
import 'support/budget_fixture.dart';
import 'support/collaboration_fixture.dart';
import 'support/guest_fixture.dart';
import 'support/schedule_fixture.dart';
import 'support/task_fixture.dart';
import 'support/vendor_fixture.dart';

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
          dashboardRepositoryProvider.overrideWithValue(
            FakeDashboardRepository(),
          ),
          taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
          guestRepositoryProvider.overrideWithValue(FakeGuestRepository()),
          budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository()),
          vendorRepositoryProvider.overrideWithValue(FakeVendorRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(),
          ),
          collaborationRepositoryProvider.overrideWithValue(
            FakeCollaborationRepository(),
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
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Confirm photographer'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Alex & Jamie tasks'), findsOneWidget);
    expect(find.text('Book venue'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guests'));
    await tester.pumpAndSettle();

    expect(find.text('The Morgan Family'), findsOneWidget);
    expect(find.text('Robin Morgan'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budget'));
    await tester.pumpAndSettle();

    expect(find.text('Alex & Jamie budget'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Venue deposit'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vendors'));
    await tester.pumpAndSettle();

    expect(find.text('Alex & Jamie vendors'), findsOneWidget);
    expect(find.text('Golden Spoon'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Open Next on the schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open Next on the schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Alex & Jamie schedule'), findsOneWidget);
    expect(find.text('Ceremony rehearsal'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('People and invitations'));
    await tester.pumpAndSettle();

    expect(find.text('People and invitations'), findsOneWidget);
    expect(find.text('jamie@example.com'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wedding settings'));
    await tester.pumpAndSettle();

    expect(find.text('Wedding settings'), findsOneWidget);
    expect(find.text('Save wedding'), findsOneWidget);
    expect(find.text('Delete wedding'), findsOneWidget);
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
