import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/schedule_models.dart';
import '../domain/schedule_repository.dart';

class DjangoScheduleRepository implements ScheduleRepository {
  DjangoScheduleRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  String _events(int weddingId) => '/weddings/$weddingId/schedule/';
  String _vendors(int weddingId) => '/weddings/$weddingId/vendors/';

  @override
  Future<List<ScheduleEvent>> fetchEvents(int weddingId) {
    return _fetchPages(
      '${_events(weddingId)}?page_size=100',
      ScheduleEvent.fromJson,
    );
  }

  @override
  Future<List<ScheduleVendorReference>> fetchVendors(int weddingId) {
    return _fetchPages(
      '${_vendors(weddingId)}?page_size=100',
      ScheduleVendorReference.fromJson,
    );
  }

  Future<List<T>> _fetchPages<T>(
    String firstUrl,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final items = <T>[];
      String? nextUrl = firstUrl;
      while (nextUrl != null) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final data = response.data!;
        final results = data['results'] as List<dynamic>;
        items.addAll(
          results.map(
            (item) => fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
        nextUrl = data['next'] as String?;
      }
      return items;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<ScheduleEvent> createEvent(int weddingId, ScheduleEventDraft draft) {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _events(weddingId),
        data: draft.toJson(),
      ),
    );
  }

  @override
  Future<ScheduleEvent> updateEvent(
    int weddingId,
    int eventId,
    ScheduleEventDraft draft,
  ) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_events(weddingId)}$eventId/',
        data: draft.toJson(),
      ),
    );
  }

  @override
  Future<ScheduleEvent> updateStatus(
    int weddingId,
    int eventId,
    ScheduleEventStatus status,
  ) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_events(weddingId)}$eventId/',
        data: {'status': status.apiValue},
      ),
    );
  }

  @override
  Future<void> deleteEvent(int weddingId, int eventId) async {
    try {
      await _dio.delete<void>('${_events(weddingId)}$eventId/');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ScheduleEvent> _write(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return ScheduleEvent.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
