import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final user = context.read<Map<String, dynamic>>();
  final coupleId = user['couple_id'];
  final conn = await db.connection;
  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
        'SELECT * FROM todos WHERE couple_id = :coupleId ORDER BY is_done, due_date',
        {'coupleId': coupleId});
    return Response.json(body: rows.rows.map((r) => r.assoc()).toList());
  }
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final title = body['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      return Response.json(
          statusCode: 400, body: {'error': 'title is required'});
    }
    final result = await conn.execute(
      'INSERT INTO todos (couple_id, title, owner_role, due_date) VALUES (:coupleId, :title, :ownerRole, :dueDate)',
      {
        'coupleId': coupleId,
        'title': title,
        'ownerRole': body['ownerRole'] ?? 'shared',
        'dueDate': body['dueDate']
      },
    );
    return Response.json(
        statusCode: 201, body: {'id': result.lastInsertID.toInt()});
  }
  return Response(statusCode: 405);
}
