import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/launch_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/budget/presentation/budget_category_form_screen.dart';
import '../../features/budget/presentation/budget_expense_form_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/budget/presentation/budget_setup_screen.dart';
import '../../features/collaboration/presentation/collaboration_screen.dart';
import '../../features/collaboration/presentation/invitation_code_screen.dart';
import '../../features/collaboration/presentation/invitation_preview_screen.dart';
import '../../features/guests/presentation/guest_form_screen.dart';
import '../../features/guests/presentation/guest_list_screen.dart';
import '../../features/guests/presentation/household_form_screen.dart';
import '../../features/schedule/presentation/schedule_event_form_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';
import '../../features/tasks/presentation/task_form_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../features/vendors/presentation/vendor_form_screen.dart';
import '../../features/vendors/presentation/vendor_list_screen.dart';
import '../../features/weddings/presentation/create_wedding_screen.dart';
import '../../features/weddings/presentation/wedding_settings_screen.dart';
import '../../features/weddings/presentation/wedding_workspace_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/launch',
    routes: [
      GoRoute(path: '/launch', builder: (_, _) => const LaunchScreen()),
      GoRoute(
        path: '/login',
        builder: (_, state) =>
            LoginScreen(inviteToken: state.uri.queryParameters['invite']),
      ),
      GoRoute(
        path: '/register',
        builder: (_, state) =>
            RegisterScreen(inviteToken: state.uri.queryParameters['invite']),
      ),
      GoRoute(path: '/home', builder: (_, _) => const WeddingWorkspaceScreen()),
      GoRoute(
        path: '/weddings/new',
        builder: (_, _) => const CreateWeddingScreen(),
      ),
      GoRoute(
        path: '/weddings/settings',
        builder: (_, _) => const WeddingSettingsScreen(),
      ),
      GoRoute(path: '/tasks', builder: (_, _) => const TaskListScreen()),
      GoRoute(path: '/tasks/new', builder: (_, _) => const TaskFormScreen()),
      GoRoute(
        path: '/tasks/:taskId/edit',
        builder: (_, state) =>
            TaskFormScreen(taskId: int.parse(state.pathParameters['taskId']!)),
      ),
      GoRoute(path: '/guests', builder: (_, _) => const GuestListScreen()),
      GoRoute(
        path: '/guests/households/new',
        builder: (_, _) => const HouseholdFormScreen(),
      ),
      GoRoute(
        path: '/guests/households/:householdId/edit',
        builder: (_, state) => HouseholdFormScreen(
          householdId: int.parse(state.pathParameters['householdId']!),
        ),
      ),
      GoRoute(
        path: '/guests/new',
        builder: (_, state) => GuestFormScreen(
          initialHouseholdId: int.tryParse(
            state.uri.queryParameters['householdId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/guests/:guestId/edit',
        builder: (_, state) => GuestFormScreen(
          guestId: int.parse(state.pathParameters['guestId']!),
        ),
      ),
      GoRoute(path: '/budget', builder: (_, _) => const BudgetScreen()),
      GoRoute(
        path: '/budget/setup',
        builder: (_, _) => const BudgetSetupScreen(),
      ),
      GoRoute(
        path: '/budget/categories/new',
        builder: (_, _) => const BudgetCategoryFormScreen(),
      ),
      GoRoute(
        path: '/budget/categories/:categoryId/edit',
        builder: (_, state) => BudgetCategoryFormScreen(
          categoryId: int.parse(state.pathParameters['categoryId']!),
        ),
      ),
      GoRoute(
        path: '/budget/expenses/new',
        builder: (_, _) => const BudgetExpenseFormScreen(),
      ),
      GoRoute(
        path: '/budget/expenses/:expenseId/edit',
        builder: (_, state) => BudgetExpenseFormScreen(
          expenseId: int.parse(state.pathParameters['expenseId']!),
        ),
      ),
      GoRoute(path: '/vendors', builder: (_, _) => const VendorListScreen()),
      GoRoute(
        path: '/vendors/new',
        builder: (_, _) => const VendorFormScreen(),
      ),
      GoRoute(
        path: '/vendors/:vendorId/edit',
        builder: (_, state) => VendorFormScreen(
          vendorId: int.parse(state.pathParameters['vendorId']!),
        ),
      ),
      GoRoute(path: '/schedule', builder: (_, _) => const ScheduleScreen()),
      GoRoute(
        path: '/schedule/new',
        builder: (_, _) => const ScheduleEventFormScreen(),
      ),
      GoRoute(
        path: '/schedule/:eventId/edit',
        builder: (_, state) => ScheduleEventFormScreen(
          eventId: int.parse(state.pathParameters['eventId']!),
        ),
      ),
      GoRoute(
        path: '/collaboration',
        builder: (_, _) => const CollaborationScreen(),
      ),
      GoRoute(path: '/invite', builder: (_, _) => const InvitationCodeScreen()),
      GoRoute(
        path: '/invite/:token',
        builder: (_, state) =>
            InvitationPreviewScreen(token: state.pathParameters['token']!),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isInvitationRoute =
          location == '/invite' || location.startsWith('/invite/');

      if (authState.isLoading) {
        // Keep auth forms mounted so they can display request failures.
        return location == '/launch' || isAuthRoute || isInvitationRoute
            ? null
            : '/launch';
      }

      final isAuthenticated =
          authState.hasValue && authState.requireValue != null;
      if (!isAuthenticated) {
        return isAuthRoute || isInvitationRoute ? null : '/login';
      }
      if (isAuthRoute) {
        final inviteToken = state.uri.queryParameters['invite'];
        return inviteToken == null ? '/home' : '/invite/$inviteToken';
      }
      if (location == '/launch') return '/home';
      return null;
    },
  );

  // Refresh redirects without replacing the router and losing its location.
  ref.listen(authControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
