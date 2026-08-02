import 'wedding.dart';

abstract interface class WeddingSettingsRepository {
  Future<Wedding> updateWedding(
    int weddingId, {
    required String name,
    required String location,
    DateTime? weddingDate,
  });

  Future<void> deleteWedding(int weddingId);
}
