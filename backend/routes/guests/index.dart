import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final method = context.request.method;

  if (method == HttpMethod.get) {
    final guests = await db.select(db.guests).get();
    return Response.json(
      body: guests
          .map((g) => {
                'id': g.id,
                'name': g.name,
                'email': g.email,
                'rsvpStatus': g.rsvpStatus,
                'dietaryNotes': g.dietaryNotes,
                'createdAt': g.createdAt.toIso8601String(),
              })
          .toList(),
    );
  } else if (method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final email = body['email'] as String?;
    final rsvpStatus = body['rsvpStatus'] as String? ?? 'pending';
    final dietaryNotes = body['dietaryNotes'] as String?;

    if (name == null || name.isEmpty) {
      return Response(
          statusCode: HttpStatus.badRequest, body: 'Name is required');
    }

    final id = await db.into(db.guests).insert(
          GuestsCompanion.insert(
            name: name,
            email: Value(email),
            rsvpStatus: Value(rsvpStatus),
            dietaryNotes: Value(dietaryNotes),
          ),
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id},
    );
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
