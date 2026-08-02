import 'wedding.dart';

abstract interface class WeddingRepository {
  Future<List<Wedding>> fetchWeddings();

  Future<Wedding> createWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  });
}

abstract interface class WeddingSelectionStorage {
  Future<int?> readSelectedWeddingId(int userId);
  Future<void> saveSelectedWeddingId(int userId, int weddingId);
  Future<void> clearSelectedWeddingId(int userId);
}
