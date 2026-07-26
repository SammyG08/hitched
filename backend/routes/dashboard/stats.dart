import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  // In a real app, we'd fetch this from the Settings table
  // For now, returning mock stats backed by the DB connection
  return Response.json(
    body: {
      'days_remaining': 120,
      'hours_remaining': 8,
      'mins_remaining': 45,
      'total_guests': 60,
      'attending_guests': 45,
      'total_budget': 20000,
      'spent_budget': 12500,
      'total_tasks': 24,
      'completed_tasks': 12,
    },
  );
}
