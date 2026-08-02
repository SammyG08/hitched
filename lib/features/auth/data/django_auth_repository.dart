import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class DjangoAuthRepository implements AuthRepository {
  DjangoAuthRepository({
    required ApiClient apiClient,
    required TokenStorage storage,
  }) : _dio = apiClient.dio,
       _storage = storage;

  final Dio _dio;
  final TokenStorage _storage;

  @override
  Future<AppUser?> restoreSession() async {
    if (await _storage.readAccessToken() == null &&
        await _storage.readRefreshToken() == null) {
      return null;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me/');
      return AppUser.fromJson(response.data!);
    } on DioException {
      await _storage.clearTokens();
      return null;
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login/',
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );
      final data = response.data!;
      await _storage.saveTokens(
        access: data['access'] as String,
        refresh: data['refresh'] as String,
      );
      return AppUser.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/register/',
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType, // Adds 'application/json'
        ),
      );
      return login(email: email, password: password);
    } on DioException catch (error) {
      // print(error.response?.data);
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    try {
      if (refreshToken != null) {
        await _dio.post<void>('/auth/logout/', data: {'refresh': refreshToken});
      }
    } on DioException {
      // Local logout must still succeed if the API is unavailable.
    } finally {
      await _storage.clearTokens();
    }
  }
}
