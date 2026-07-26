import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/middleware.dart';

Handler middleware(Handler handler) =>
    handler.use(authMiddleware(roles: {'groom'}));
