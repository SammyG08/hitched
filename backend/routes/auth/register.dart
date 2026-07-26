import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final required = [
    'role',
    'name',
    'email',
    'password',
    'partnerName',
    'partnerEmail',
    'partnerPassword',
    'weddingDate',
    'location'
  ];
  for (final key in required) {
    if ('${body[key] ?? ''}'.trim().isEmpty) {
      return Response.json(
          statusCode: 400, body: {'error': '$key is required'});
    }
  }
  final role = body['role'] as String;
  if (role != 'bride' && role != 'groom') {
    return Response.json(
        statusCode: 400, body: {'error': 'role must be bride or groom'});
  }
  try {
    final db = context.read<AppDatabase>();
    final user = await db.createCoupleRegistration(
      registeringRole: role,
      name: body['name'] as String,
      email: body['email'] as String,
      password: body['password'] as String,
      partnerName: body['partnerName'] as String,
      partnerEmail: body['partnerEmail'] as String,
      partnerPassword: body['partnerPassword'] as String,
      weddingDate: body['weddingDate'] as String,
      location: body['location'] as String,
    );
    final login =
        await db.login(body['email'] as String, body['password'] as String);
    return Response.json(statusCode: 201, body: _safeUser(login ?? user));
  } catch (error) {
    return Response.json(statusCode: 409, body: {
      'error': 'Registration failed. Check for duplicate emails.',
      'detail': '$error'
    });
  }
}

Map<String, dynamic> _safeUser(Map<String, dynamic> user) => {
      'id': user['id'],
      'coupleId': user['couple_id'],
      'name': user['name'],
      'email': user['email'],
      'role': user['role'],
      'token': user['token'],
    };
