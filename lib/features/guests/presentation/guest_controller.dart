import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_guest_repository.dart';
import '../domain/guest_models.dart';
import '../domain/guest_repository.dart';

final guestRepositoryProvider = Provider<GuestRepository>((ref) {
  return DjangoGuestRepository(ref.watch(apiClientProvider));
});

final guestListProvider =
    AsyncNotifierProvider<GuestController, GuestListState>(GuestController.new);

class GuestListState {
  const GuestListState({
    required this.households,
    required this.guests,
    this.query = '',
    this.invitationFilter,
    this.rsvpFilter,
    this.isMutating = false,
    this.actionError,
  });

  const GuestListState.empty()
    : households = const [],
      guests = const [],
      query = '',
      invitationFilter = null,
      rsvpFilter = null,
      isMutating = false,
      actionError = null;

  final List<GuestHousehold> households;
  final List<WeddingGuest> guests;
  final String query;
  final InvitationStatus? invitationFilter;
  final GuestRsvpStatus? rsvpFilter;
  final bool isMutating;
  final Object? actionError;

  List<GuestHousehold> get visibleHouseholds {
    final search = query.trim().toLowerCase();
    return households
        .where((household) {
          if (invitationFilter != null &&
              household.invitationStatus != invitationFilter) {
            return false;
          }
          final householdGuests = guestsFor(household.id);
          if (rsvpFilter != null && householdGuests.isEmpty) return false;
          if (search.isEmpty) return true;
          final householdText = [
            household.name,
            household.contactEmail,
            household.contactPhone,
            household.address,
          ].join(' ').toLowerCase();
          return householdText.contains(search) || householdGuests.isNotEmpty;
        })
        .toList(growable: false);
  }

  List<WeddingGuest> guestsFor(int householdId) {
    final search = query.trim().toLowerCase();
    return guests
        .where((guest) {
          if (guest.householdId != householdId) return false;
          if (rsvpFilter != null && guest.rsvpStatus != rsvpFilter) {
            return false;
          }
          if (search.isEmpty) return true;
          final text = [
            guest.fullName,
            guest.email,
            guest.phone,
            guest.dietaryRequirements,
            guest.tableName,
          ].join(' ').toLowerCase();
          return text.contains(search);
        })
        .toList(growable: false);
  }

  GuestListState copyWith({
    List<GuestHousehold>? households,
    List<WeddingGuest>? guests,
    String? query,
    InvitationStatus? invitationFilter,
    GuestRsvpStatus? rsvpFilter,
    bool? isMutating,
    Object? actionError,
    bool clearInvitationFilter = false,
    bool clearRsvpFilter = false,
    bool clearActionError = false,
  }) {
    return GuestListState(
      households: households ?? this.households,
      guests: guests ?? this.guests,
      query: query ?? this.query,
      invitationFilter: clearInvitationFilter
          ? null
          : invitationFilter ?? this.invitationFilter,
      rsvpFilter: clearRsvpFilter ? null : rsvpFilter ?? this.rsvpFilter,
      isMutating: isMutating ?? this.isMutating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class GuestController extends AsyncNotifier<GuestListState> {
  GuestRepository get _repository => ref.read(guestRepositoryProvider);

  int? get _weddingId =>
      ref.read(weddingWorkspaceProvider).value?.selectedWedding?.id;

  @override
  Future<GuestListState> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return const GuestListState.empty();
    final weddingId = workspace.requireValue.selectedWedding?.id;
    if (weddingId == null) return const GuestListState.empty();
    return _fetch(weddingId);
  }

  Future<GuestListState> _fetch(
    int weddingId, [
    GuestListState? previous,
  ]) async {
    final results = await Future.wait([
      _repository.fetchHouseholds(weddingId),
      _repository.fetchGuests(weddingId),
    ]);
    return GuestListState(
      households: results[0] as List<GuestHousehold>,
      guests: results[1] as List<WeddingGuest>,
      query: previous?.query ?? '',
      invitationFilter: previous?.invitationFilter,
      rsvpFilter: previous?.rsvpFilter,
    );
  }

  Future<void> refresh() async {
    final weddingId = _weddingId;
    if (weddingId == null) return;
    final previous = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(weddingId, previous));
  }

  void setQuery(String query) {
    state = AsyncData(state.requireValue.copyWith(query: query));
  }

  void setInvitationFilter(InvitationStatus? filter) {
    state = AsyncData(
      state.requireValue.copyWith(
        invitationFilter: filter,
        clearInvitationFilter: filter == null,
      ),
    );
  }

  void setRsvpFilter(GuestRsvpStatus? filter) {
    state = AsyncData(
      state.requireValue.copyWith(
        rsvpFilter: filter,
        clearRsvpFilter: filter == null,
      ),
    );
  }

  GuestHousehold? householdById(int id) {
    return state.value?.households
        .where((household) => household.id == id)
        .firstOrNull;
  }

  WeddingGuest? guestById(int id) {
    return state.value?.guests.where((guest) => guest.id == id).firstOrNull;
  }

  Future<bool> saveHousehold({
    int? householdId,
    required HouseholdDraft draft,
  }) {
    return _mutate((weddingId) async {
      if (householdId == null) {
        await _repository.createHousehold(weddingId, draft);
      } else {
        await _repository.updateHousehold(weddingId, householdId, draft);
      }
    });
  }

  Future<bool> deleteHousehold(int householdId) {
    return _mutate(
      (weddingId) => _repository.deleteHousehold(weddingId, householdId),
    );
  }

  Future<bool> saveGuest({int? guestId, required GuestDraft draft}) {
    return _mutate((weddingId) async {
      if (guestId == null) {
        await _repository.createGuest(weddingId, draft);
      } else {
        await _repository.updateGuest(weddingId, guestId, draft);
      }
    });
  }

  Future<bool> updateRsvp(int guestId, GuestRsvpStatus status) {
    return _mutate(
      (weddingId) => _repository.updateRsvp(weddingId, guestId, status),
    );
  }

  Future<bool> deleteGuest(int guestId) {
    return _mutate((weddingId) => _repository.deleteGuest(weddingId, guestId));
  }

  Future<bool> _mutate(Future<void> Function(int weddingId) operation) async {
    final weddingId = _weddingId;
    if (weddingId == null) return false;
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(isMutating: true, clearActionError: true),
    );
    try {
      await operation(weddingId);
      state = AsyncData(await _fetch(weddingId, current));
      ref.invalidate(dashboardProvider);
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isMutating: false, actionError: error),
      );
      return false;
    }
  }
}
