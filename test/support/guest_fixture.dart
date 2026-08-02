import 'package:hitched/features/guests/domain/guest_models.dart';
import 'package:hitched/features/guests/domain/guest_repository.dart';

WeddingGuest guestFixture({
  int id = 1,
  int householdId = 1,
  String name = 'Robin Morgan',
  GuestRsvpStatus status = GuestRsvpStatus.pending,
}) {
  final names = name.split(' ');
  return WeddingGuest(
    id: id,
    householdId: householdId,
    householdName: 'The Morgan Family',
    firstName: names.first,
    lastName: names.skip(1).join(' '),
    fullName: name,
    email: '',
    phone: '',
    isPlusOne: false,
    rsvpStatus: status,
    dietaryRequirements: '',
    tableName: '',
    notes: '',
  );
}

class FakeGuestRepository implements GuestRepository {
  final guests = <WeddingGuest>[guestFixture()];

  @override
  Future<List<GuestHousehold>> fetchHouseholds(int weddingId) async => [
    GuestHousehold(
      id: 1,
      weddingId: weddingId,
      name: 'The Morgan Family',
      contactEmail: 'morgan@example.com',
      contactPhone: '',
      address: '',
      invitationStatus: InvitationStatus.sent,
      guestCount: guests.length,
      attendingCount: guests
          .where((guest) => guest.rsvpStatus == GuestRsvpStatus.attending)
          .length,
      guests: guests
          .map(
            (guest) => GuestSummary(
              id: guest.id,
              fullName: guest.fullName,
              isPlusOne: guest.isPlusOne,
              rsvpStatus: guest.rsvpStatus,
            ),
          )
          .toList(),
    ),
  ];

  @override
  Future<List<WeddingGuest>> fetchGuests(int weddingId) async =>
      List.unmodifiable(guests);

  @override
  Future<WeddingGuest> updateRsvp(
    int weddingId,
    int guestId,
    GuestRsvpStatus status,
  ) async {
    final old = guests.firstWhere((guest) => guest.id == guestId);
    final updated = guestFixture(
      id: old.id,
      householdId: old.householdId,
      name: old.fullName,
      status: status,
    );
    guests[guests.indexOf(old)] = updated;
    return updated;
  }

  @override
  Future<WeddingGuest> createGuest(int weddingId, GuestDraft draft) async {
    final guest = guestFixture(
      id: guests.length + 1,
      householdId: draft.householdId,
      name: '${draft.firstName} ${draft.lastName}'.trim(),
      status: draft.rsvpStatus,
    );
    guests.add(guest);
    return guest;
  }

  @override
  Future<void> deleteGuest(int weddingId, int guestId) async {
    guests.removeWhere((guest) => guest.id == guestId);
  }

  @override
  Future<WeddingGuest> updateGuest(
    int weddingId,
    int guestId,
    GuestDraft draft,
  ) async => createGuest(weddingId, draft);

  @override
  Future<GuestHousehold> createHousehold(
    int weddingId,
    HouseholdDraft draft,
  ) async => (await fetchHouseholds(weddingId)).first;

  @override
  Future<GuestHousehold> updateHousehold(
    int weddingId,
    int householdId,
    HouseholdDraft draft,
  ) async => (await fetchHouseholds(weddingId)).first;

  @override
  Future<void> deleteHousehold(int weddingId, int householdId) async {
    guests.clear();
  }
}
