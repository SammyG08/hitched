import 'guest_models.dart';

abstract interface class GuestRepository {
  Future<List<GuestHousehold>> fetchHouseholds(int weddingId);
  Future<List<WeddingGuest>> fetchGuests(int weddingId);

  Future<GuestHousehold> createHousehold(int weddingId, HouseholdDraft draft);
  Future<GuestHousehold> updateHousehold(
    int weddingId,
    int householdId,
    HouseholdDraft draft,
  );
  Future<void> deleteHousehold(int weddingId, int householdId);

  Future<WeddingGuest> createGuest(int weddingId, GuestDraft draft);
  Future<WeddingGuest> updateGuest(
    int weddingId,
    int guestId,
    GuestDraft draft,
  );
  Future<WeddingGuest> updateRsvp(
    int weddingId,
    int guestId,
    GuestRsvpStatus status,
  );
  Future<void> deleteGuest(int weddingId, int guestId);
}
