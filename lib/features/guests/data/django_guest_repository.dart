import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/guest_models.dart';
import '../domain/guest_repository.dart';

class DjangoGuestRepository implements GuestRepository {
  DjangoGuestRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  String _households(int weddingId) => '/weddings/$weddingId/households/';
  String _guests(int weddingId) => '/weddings/$weddingId/guests/';

  @override
  Future<List<GuestHousehold>> fetchHouseholds(int weddingId) {
    return _fetchPages(
      '${_households(weddingId)}?page_size=100',
      GuestHousehold.fromJson,
    );
  }

  @override
  Future<List<WeddingGuest>> fetchGuests(int weddingId) {
    return _fetchPages(
      '${_guests(weddingId)}?page_size=100',
      WeddingGuest.fromJson,
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
  Future<GuestHousehold> createHousehold(
    int weddingId,
    HouseholdDraft draft,
  ) async {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _households(weddingId),
        data: draft.toJson(),
      ),
      GuestHousehold.fromJson,
    );
  }

  @override
  Future<GuestHousehold> updateHousehold(
    int weddingId,
    int householdId,
    HouseholdDraft draft,
  ) async {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_households(weddingId)}$householdId/',
        data: draft.toJson(),
      ),
      GuestHousehold.fromJson,
    );
  }

  @override
  Future<void> deleteHousehold(int weddingId, int householdId) async {
    await _delete('${_households(weddingId)}$householdId/');
  }

  @override
  Future<WeddingGuest> createGuest(int weddingId, GuestDraft draft) async {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _guests(weddingId),
        data: draft.toJson(),
      ),
      WeddingGuest.fromJson,
    );
  }

  @override
  Future<WeddingGuest> updateGuest(
    int weddingId,
    int guestId,
    GuestDraft draft,
  ) async {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_guests(weddingId)}$guestId/',
        data: draft.toJson(),
      ),
      WeddingGuest.fromJson,
    );
  }

  @override
  Future<WeddingGuest> updateRsvp(
    int weddingId,
    int guestId,
    GuestRsvpStatus status,
  ) async {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_guests(weddingId)}$guestId/',
        data: {'rsvp_status': status.apiValue},
      ),
      WeddingGuest.fromJson,
    );
  }

  @override
  Future<void> deleteGuest(int weddingId, int guestId) async {
    await _delete('${_guests(weddingId)}$guestId/');
  }

  Future<T> _write<T>(
    Future<Response<Map<String, dynamic>>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      return fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> _delete(String path) async {
    try {
      await _dio.delete<void>(path);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
