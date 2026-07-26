import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: 405);
  }
  final user = context.read<Map<String, dynamic>>();
  final body = await context.request.json() as Map<String, dynamic>;
  final budgetCents = body['budgetCents'];
  if (budgetCents is! int || budgetCents < 0) {
    return Response.json(
        statusCode: 400,
        body: {'error': 'budgetCents must be a positive integer'});
  }
  final conn = await context.read<AppDatabase>().connection;
  await conn.execute(
      'UPDATE couples SET budget_cents = :budget WHERE id = :coupleId',
      {'budget': budgetCents, 'coupleId': user['couple_id']});
  return Response.json(body: {'saved': true});
}
