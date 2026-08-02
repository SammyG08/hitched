import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/django_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DjangoAuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(tokenStorageProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AppUser?> build() => _repository.restoreSession();

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.login(email: email, password: password),
    );
    return !state.hasError;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      ),
    );
    return !state.hasError;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await _repository.logout();
    state = const AsyncData(null);
  }
}
