// ignore_for_file: file_names

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final user = context.read<Map<String, dynamic>>();
  final conn = await context.read<AppDatabase>().connection;
  final coupleId = user['couple_id'];

  if (context.request.method == HttpMethod.delete) {
    await conn.execute(
      'DELETE FROM guests WHERE id = :id AND couple_id = :coupleId',
      {'id': id, 'coupleId': coupleId},
    );
    return Response(statusCode: HttpStatus.noContent);
  }

  if (context.request.method == HttpMethod.put) {
    final body = await context.request.json() as Map<String, dynamic>;
    await conn.execute(
      'UPDATE guests SET name = COALESCE(:name, name), email = :email, rsvp_status = COALESCE(:status, rsvp_status), dietary_notes = :notes WHERE id = :id AND couple_id = :coupleId',
      {
        'id': id,
        'coupleId': coupleId,
        'name': body['name'],
        'email': body['email'],
        'status': body['rsvpStatus'],
        'notes': body['dietaryNotes'],
      },
    );
    return Response.json(body: {'saved': true});
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
