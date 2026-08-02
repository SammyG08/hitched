import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/wedding.dart';
import '../domain/wedding_repository.dart';

class DjangoWeddingRepository implements WeddingRepository {
  DjangoWeddingRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  @override
  Future<List<Wedding>> fetchWeddings() async {
    try {
      final weddings = <Wedding>[];
      String? nextUrl = '/weddings/?page_size=100';

      while (nextUrl != null) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final data = response.data!;
        final results = data['results'] as List<dynamic>;
        weddings.addAll(
          results.map((item) => Wedding.fromJson(item as Map<String, dynamic>)),
        );
        nextUrl = data['next'] as String?;
      }

      return weddings;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<Wedding> createWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/weddings/',
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

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
