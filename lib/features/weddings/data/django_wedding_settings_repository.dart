import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/wedding.dart';
import '../domain/wedding_settings_repository.dart';

class DjangoWeddingSettingsRepository implements WeddingSettingsRepository {
  DjangoWeddingSettingsRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  @override
  Future<Wedding> updateWedding(
    int weddingId, {
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/weddings/$weddingId/',
        data: {
          'name': name.trim(),
          'location': location.trim(),
          'wedding_date': weddingDate == null ? null : _dateOnly(weddingDate),
        },
      );
      return Wedding.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> deleteWedding(int weddingId) async {
    try {
      await _dio.delete<void>('/weddings/$weddingId/');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
