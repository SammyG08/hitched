import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/wedding_repository.dart';

class SecureWeddingSelectionStorage implements WeddingSelectionStorage {
  SecureWeddingSelectionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(int userId) => 'hitched_selected_wedding_$userId';

  @override
  Future<int?> readSelectedWeddingId(int userId) async {
    final value = await _storage.read(key: _key(userId));
    return int.tryParse(value ?? '');
  }

  @override
  Future<void> saveSelectedWeddingId(int userId, int weddingId) {
    return _storage.write(key: _key(userId), value: weddingId.toString());
  }

  @override
  Future<void> clearSelectedWeddingId(int userId) {
    return _storage.delete(key: _key(userId));
  }
}
