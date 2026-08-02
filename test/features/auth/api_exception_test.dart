import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/core/errors/api_exception.dart';

void main() {
  test('reads the standard Django error envelope', () {
    final request = RequestOptions(path: '/auth/register/');
    final dioError = DioException(
      requestOptions: request,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 400,
        data: {
          'error': {
            'status': 400,
            'code': 'validation_error',
            'message': 'Request validation failed.',
            'details': {
              'email': ['A user with this email already exists.'],
            },
          },
        },
      ),
    );

    final exception = ApiException.fromDio(dioError);

    expect(exception.statusCode, 400);
    expect(exception.code, 'validation_error');
    expect(
      exception.messageFor('email'),
      'A user with this email already exists.',
    );
    expect(exception.displayMessage, 'A user with this email already exists.');
  });
}
