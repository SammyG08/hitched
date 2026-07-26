import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) => Response.json(body: {
      'name': 'Hitched API',
      'database': 'mysql',
      'auth': 'bearer',
      'roles': ['bride', 'groom', 'vendor', 'admin']
    });
