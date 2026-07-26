import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<Map<String, dynamic>>();
  final conn = await context.read<AppDatabase>().connection;
  final coupleId = user['couple_id'];
  final guestRows = await conn.execute(
      'SELECT rsvp_status, COUNT(*) AS total FROM guests WHERE couple_id = :coupleId GROUP BY rsvp_status',
      {'coupleId': coupleId});
  final todoRows = await conn.execute(
      'SELECT is_done, COUNT(*) AS total FROM todos WHERE couple_id = :coupleId GROUP BY is_done',
      {'coupleId': coupleId});
  final spendRows = await conn.execute(
    'SELECT COALESCE(SUM(v.price_cents), 0) AS spent FROM selections s JOIN vendors v ON v.id = s.vendor_id WHERE s.couple_id = :coupleId AND s.status = "booked"',
    {'coupleId': coupleId},
  );
  final couple = await conn.execute(
      'SELECT wedding_date, location, budget_cents FROM couples WHERE id = :coupleId',
      {'coupleId': coupleId});
  return Response.json(body: {
    'couple': couple.rows.isEmpty ? null : couple.rows.first.assoc(),
    'guests': guestRows.rows.map((r) => r.assoc()).toList(),
    'todos': todoRows.rows.map((r) => r.assoc()).toList(),
    'spentCents': spendRows.rows.first.assoc()['spent'],
    'showBudget': user['role'] == 'groom',
  });
}
