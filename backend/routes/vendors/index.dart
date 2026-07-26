import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';
import 'package:hitched_backend/middleware.dart';

Handler middleware(Handler handler) => handler.use(authMiddleware());

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final user = context.read<Map<String, dynamic>>();
  final conn = await db.connection;
  final role = '${user['role']}';
  final category = context.request.uri.queryParameters['category'];
  final params = <String, dynamic>{};
  var where = 'WHERE approved = TRUE';
  if (category != null && category.isNotEmpty) {
    where += ' AND category = :category';
    params['category'] = category;
  }
  if (role == 'bride') {
    where += ' AND (:budget IS NULL OR price_cents <= :budget)';
    params['budget'] = user['budget_cents'];
  } else if (role == 'vendor') {
    where = 'WHERE owner_user_id = :ownerId';
    params['ownerId'] = user['id'];
  }
  final rows = await conn.execute(
    'SELECT id, name, category, description, price_cents, image_url, remarks FROM vendors $where ORDER BY category, price_cents',
    params,
  );
  return Response.json(body: rows.rows.map((r) => r.assoc()).toList());
}
