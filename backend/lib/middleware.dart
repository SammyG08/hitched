import 'package:dart_frog/dart_frog.dart';
import 'package:hitched_backend/database.dart';

final _db = AppDatabase();

Handler databaseMiddleware(Handler handler) {
  return (context) {
    return handler(context.provide<AppDatabase>(() => _db));
  };
}
