import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    this.dio.interceptors.add(
      _AuthInterceptor(this.dio, tokenStorage, AppConfig.apiBaseUrl),
    );
  }

  final Dio dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio, this._tokenStorage, String baseUrl)
    : _refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final request = error.requestOptions;
    final canRefresh =
        error.response?.statusCode == 401 &&
        request.extra['tokenRetried'] != true &&
        !request.path.contains('/auth/refresh/');

    if (!canRefresh) {
      handler.next(error);
      return;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      handler.next(error);
      return;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
      );
      final data = response.data!;
      final access = data['access'] as String;
      final refresh = data['refresh'] as String? ?? refreshToken;
      await _tokenStorage.saveTokens(access: access, refresh: refresh);

      request.headers['Authorization'] = 'Bearer $access';
      request.extra['tokenRetried'] = true;
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException {
      await _tokenStorage.clearTokens();
      handler.next(error);
    }
  }
}
