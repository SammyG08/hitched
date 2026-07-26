import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

final _db = AppDatabase.instance;

Handler databaseMiddleware(Handler handler) {
  return (context) async {
    await _db.migrate();
    return handler(context.provide<AppDatabase>(() => _db));
  };
}

Middleware authMiddleware({Set<String>? roles}) {
  return (handler) {
    return (context) async {
      final auth = context.request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return Response.json(
            statusCode: 401, body: {'error': 'Missing bearer token'});
      }
      final db = context.read<AppDatabase>();
      final user = await db.userByToken(auth.substring(7));
      if (user == null) {
        return Response.json(
            statusCode: 401, body: {'error': 'Invalid or expired token'});
      }
      if (roles != null && !roles.contains(user['role'])) {
        return Response.json(
            statusCode: 403, body: {'error': 'Role not allowed'});
      }
      return handler(context.provide<Map<String, dynamic>>(() => user));
    };
  };
}
