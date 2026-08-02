import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/launch_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/weddings/presentation/create_wedding_screen.dart';
import '../../features/weddings/presentation/wedding_workspace_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/launch',
    routes: [
      GoRoute(path: '/launch', builder: (_, _) => const LaunchScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, _) => const WeddingWorkspaceScreen()),
      GoRoute(
        path: '/weddings/new',
        builder: (_, _) => const CreateWeddingScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      if (authState.isLoading) {
        // Keep auth forms mounted so they can display request failures.
        return location == '/launch' || isAuthRoute ? null : '/launch';
      }

      final isAuthenticated =
          authState.hasValue && authState.requireValue != null;
      if (!isAuthenticated) return isAuthRoute ? null : '/login';
      if (isAuthRoute || location == '/launch') return '/home';
      return null;
    },
  );

  // Refresh redirects without replacing the router and losing its location.
  ref.listen(authControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
