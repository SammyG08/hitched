import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/vendor_models.dart';
import '../domain/vendor_repository.dart';

class DjangoVendorRepository implements VendorRepository {
  DjangoVendorRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  String _vendors(int weddingId) => '/weddings/$weddingId/vendors/';

  @override
  Future<List<WeddingVendor>> fetchVendors(int weddingId) async {
    try {
      final vendors = <WeddingVendor>[];
      String? nextUrl = '${_vendors(weddingId)}?page_size=100';
      while (nextUrl != null) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final data = response.data!;
        final results = data['results'] as List<dynamic>;
        vendors.addAll(
          results.map(
            (item) =>
                WeddingVendor.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
        nextUrl = data['next'] as String?;
      }
      return vendors;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingVendor> createVendor(int weddingId, VendorDraft draft) {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _vendors(weddingId),
        data: draft.toJson(),
      ),
    );
  }

  @override
  Future<WeddingVendor> updateVendor(
    int weddingId,
    int vendorId,
    VendorDraft draft,
  ) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_vendors(weddingId)}$vendorId/',
        data: draft.toJson(),
      ),
    );
  }

  @override
  Future<WeddingVendor> updateWorkflow(
    int weddingId,
    int vendorId, {
    VendorBookingStatus? bookingStatus,
    VendorQuoteStatus? quoteStatus,
    VendorContractStatus? contractStatus,
  }) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_vendors(weddingId)}$vendorId/',
        data: {
          if (bookingStatus != null) 'booking_status': bookingStatus.apiValue,
          if (quoteStatus != null) 'quote_status': quoteStatus.apiValue,
          if (contractStatus != null)
            'contract_status': contractStatus.apiValue,
        },
      ),
    );
  }

  @override
  Future<void> deleteVendor(int weddingId, int vendorId) async {
    try {
      await _dio.delete<void>('${_vendors(weddingId)}$vendorId/');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<WeddingVendor> _write(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return WeddingVendor.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
