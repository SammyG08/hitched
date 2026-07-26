import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final required = [
    'name',
    'email',
    'password',
    'serviceName',
    'category',
    'description',
    'priceCents',
    'imageUrl'
  ];
  for (final key in required) {
    if ('${body[key] ?? ''}'.trim().isEmpty) {
      return Response.json(
          statusCode: 400, body: {'error': '$key is required'});
    }
  }
  final db = context.read<AppDatabase>();
  final conn = await db.connection;
  try {
    await conn.execute('START TRANSACTION');
    final user = await conn.execute(
      'INSERT INTO users (name, email, password_hash, role) VALUES (:name, :email, SHA2(:password, 256), "vendor")',
      {
        'name': body['name'],
        'email': '${body['email']}'.toLowerCase(),
        'password': body['password']
      },
    );
    final ownerId = user.lastInsertID.toInt();
    final vendor = await conn.execute(
      'INSERT INTO vendors (owner_user_id, name, category, description, price_cents, image_url, remarks, approved) '
      'VALUES (:ownerId, :name, :category, :description, :price, :image, :remarks, TRUE)',
      {
        'ownerId': ownerId,
        'name': body['serviceName'],
        'category': body['category'],
        'description': body['description'],
        'price': body['priceCents'],
        'image': body['imageUrl'],
        'remarks': body['remarks'] ?? ''
      },
    );
    await conn.execute('COMMIT');
    final login = await db.login('${body['email']}', '${body['password']}');
    return Response.json(statusCode: 201, body: {
      'id': ownerId,
      'vendorId': vendor.lastInsertID.toInt(),
      'name': body['name'],
      'email': '${body['email']}'.toLowerCase(),
      'token': login?['token'],
      'role': 'vendor'
    });
  } catch (error) {
    await conn.execute('ROLLBACK');
    return Response.json(
        statusCode: 409,
        body: {'error': 'Vendor registration failed', 'detail': '$error'});
  }
}
