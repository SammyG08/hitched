import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final db = context.read<AppDatabase>();
  final guestId = int.tryParse(id);

  if (guestId == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'Invalid ID');
  }

  final method = context.request.method;

  if (method == HttpMethod.delete) {
    await (db.delete(db.guests)..where((t) => t.id.equals(guestId))).go();
    return Response(statusCode: HttpStatus.noContent);
  } else if (method == HttpMethod.patch) {
    final body = await context.request.json() as Map<String, dynamic>;
    final rsvpStatus = body['rsvpStatus'] as String?;

    await (db.update(db.guests)..where((t) => t.id.equals(guestId))).write(
      GuestsCompanion(
        rsvpStatus:
            rsvpStatus != null ? Value(rsvpStatus) : const Value.absent(),
      ),
    );
    return Response(statusCode: HttpStatus.noContent);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
