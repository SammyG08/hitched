import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_schedule_repository.dart';
import '../domain/schedule_models.dart';
import '../domain/schedule_repository.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return DjangoScheduleRepository(ref.watch(apiClientProvider));
});

final scheduleProvider =
    AsyncNotifierProvider<ScheduleController, ScheduleState>(
      ScheduleController.new,
    );

class ScheduleState {
  const ScheduleState({
    required this.events,
    required this.vendors,
    this.query = '',
    this.typeFilter,
    this.statusFilter,
    this.timeFilter = ScheduleTimeFilter.all,
    this.isMutating = false,
    this.actionError,
  });

  const ScheduleState.empty()
    : events = const [],
      vendors = const [],
      query = '',
      typeFilter = null,
      statusFilter = null,
      timeFilter = ScheduleTimeFilter.all,
      isMutating = false,
      actionError = null;

  final List<ScheduleEvent> events;
  final List<ScheduleVendorReference> vendors;
  final String query;
  final ScheduleEventType? typeFilter;
  final ScheduleEventStatus? statusFilter;
  final ScheduleTimeFilter timeFilter;
  final bool isMutating;
  final Object? actionError;

  List<ScheduleEvent> get visibleEvents {
    final search = query.trim().toLowerCase();
    return events
        .where((event) {
          if (typeFilter != null && event.eventType != typeFilter) {
            return false;
          }
          if (statusFilter != null && event.status != statusFilter) {
            return false;
          }
          if (timeFilter == ScheduleTimeFilter.upcoming && event.isPast) {
            return false;
          }
          if (timeFilter == ScheduleTimeFilter.past && !event.isPast) {
            return false;
          }
          if (search.isEmpty) {
            return true;
          }
          return [
            event.title,
            event.eventType.label,
            event.location,
            event.responsibleMember?.user.displayName ?? '',
            event.vendor?.name ?? '',
            event.notes,
          ].join(' ').toLowerCase().contains(search);
        })
        .toList(growable: false);
  }

  int get upcomingCount => events.where((event) => !event.isPast).length;
  int get confirmedCount => events
      .where((event) => event.status == ScheduleEventStatus.confirmed)
      .length;

  ScheduleState copyWith({
    List<ScheduleEvent>? events,
    List<ScheduleVendorReference>? vendors,
    String? query,
    ScheduleEventType? typeFilter,
    ScheduleEventStatus? statusFilter,
    ScheduleTimeFilter? timeFilter,
    bool? isMutating,
    Object? actionError,
    bool clearTypeFilter = false,
    bool clearStatusFilter = false,
    bool clearActionError = false,
  }) {
    return ScheduleState(
      events: events ?? this.events,
      vendors: vendors ?? this.vendors,
      query: query ?? this.query,
      typeFilter: clearTypeFilter ? null : typeFilter ?? this.typeFilter,
      statusFilter: clearStatusFilter
          ? null
          : statusFilter ?? this.statusFilter,
      timeFilter: timeFilter ?? this.timeFilter,
      isMutating: isMutating ?? this.isMutating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class ScheduleController extends AsyncNotifier<ScheduleState> {
  ScheduleRepository get _repository => ref.read(scheduleRepositoryProvider);
  int? get _weddingId =>
      ref.read(weddingWorkspaceProvider).value?.selectedWedding?.id;

  @override
  Future<ScheduleState> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return const ScheduleState.empty();
    final weddingId = workspace.requireValue.selectedWedding?.id;
    if (weddingId == null) return const ScheduleState.empty();
    return _fetch(weddingId);
  }

  Future<ScheduleState> _fetch(int weddingId, [ScheduleState? previous]) async {
    final results = await Future.wait([
      _repository.fetchEvents(weddingId),
      _repository.fetchVendors(weddingId),
    ]);
    return ScheduleState(
      events: results[0] as List<ScheduleEvent>,
      vendors: results[1] as List<ScheduleVendorReference>,
      query: previous?.query ?? '',
      typeFilter: previous?.typeFilter,
      statusFilter: previous?.statusFilter,
      timeFilter: previous?.timeFilter ?? ScheduleTimeFilter.all,
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

  void setTypeFilter(ScheduleEventType? type) {
    state = AsyncData(
      state.requireValue.copyWith(
        typeFilter: type,
        clearTypeFilter: type == null,
      ),
    );
  }

  void setStatusFilter(ScheduleEventStatus? status) {
    state = AsyncData(
      state.requireValue.copyWith(
        statusFilter: status,
        clearStatusFilter: status == null,
      ),
    );
  }

  void setTimeFilter(ScheduleTimeFilter filter) {
    state = AsyncData(state.requireValue.copyWith(timeFilter: filter));
  }

  ScheduleEvent? eventById(int id) {
    return state.value?.events.where((event) => event.id == id).firstOrNull;
  }

  Future<bool> saveEvent({int? eventId, required ScheduleEventDraft draft}) {
    return _mutate((weddingId) async {
      if (eventId == null) {
        await _repository.createEvent(weddingId, draft);
      } else {
        await _repository.updateEvent(weddingId, eventId, draft);
      }
    });
  }

  Future<bool> updateStatus(int eventId, ScheduleEventStatus status) {
    return _mutate(
      (weddingId) => _repository.updateStatus(weddingId, eventId, status),
    );
  }

  Future<bool> deleteEvent(int eventId) {
    return _mutate((weddingId) => _repository.deleteEvent(weddingId, eventId));
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
