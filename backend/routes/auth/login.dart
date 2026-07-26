import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;
  if (email == null || password == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'email and password are required'});
  }
  final user = await context.read<AppDatabase>().login(email, password);
  if (user == null) {
    return Response.json(
        statusCode: 401, body: {'error': 'Invalid credentials'});
  }
  return Response.json(body: {
    'id': user['id'],
    'coupleId': user['couple_id'],
    'name': user['name'],
    'email': user['email'],
    'role': user['role'],
    'token': user['token'],
  });
}
