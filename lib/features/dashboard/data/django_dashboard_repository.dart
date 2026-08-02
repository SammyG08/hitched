import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/dashboard.dart';
import '../domain/dashboard_repository.dart';

class DjangoDashboardRepository implements DashboardRepository {
  DjangoDashboardRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  @override
  Future<Dashboard> fetchDashboard(int weddingId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/weddings/$weddingId/dashboard/',
      );
      return Dashboard.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
