import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details = const {},
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic> details;

  factory ApiException.fromDio(DioException error) {
    final body = error.response?.data;
    if (body is Map<String, dynamic>) {
      final errorBody = body['error'];
      if (errorBody is Map<String, dynamic>) {
        final rawDetails = errorBody['details'];
        return ApiException(
          message: errorBody['message']?.toString() ?? 'The request failed.',
          statusCode: error.response?.statusCode,
          code: errorBody['code']?.toString(),
          details: rawDetails is Map<String, dynamic> ? rawDetails : const {},
        );
      }
    }

    return ApiException(
      message: error.type == DioExceptionType.connectionError
          ? 'Could not connect to Hitched. Check that the API is running.'
          : 'Something went wrong. Please try again.',
      statusCode: error.response?.statusCode,
    );
  }

  String? messageFor(String field) {
    final value = details[field];
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value != null) return value.toString();
    return null;
  }

  String get displayMessage {
    for (final value in details.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value != null) return value.toString();
    }
    return message;
  }

  @override
  String toString() => displayMessage;
}
