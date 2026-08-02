import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_vendor_repository.dart';
import '../domain/vendor_models.dart';
import '../domain/vendor_repository.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return DjangoVendorRepository(ref.watch(apiClientProvider));
});

final vendorListProvider =
    AsyncNotifierProvider<VendorController, VendorListState>(
      VendorController.new,
    );

class VendorListState {
  const VendorListState({
    required this.vendors,
    this.query = '',
    this.categoryFilter,
    this.bookingFilter,
    this.contractFilter,
    this.isMutating = false,
    this.actionError,
  });

  const VendorListState.empty()
    : vendors = const [],
      query = '',
      categoryFilter = null,
      bookingFilter = null,
      contractFilter = null,
      isMutating = false,
      actionError = null;

  final List<WeddingVendor> vendors;
  final String query;
  final VendorServiceCategory? categoryFilter;
  final VendorBookingStatus? bookingFilter;
  final VendorContractStatus? contractFilter;
  final bool isMutating;
  final Object? actionError;

  List<WeddingVendor> get visibleVendors {
    final search = query.trim().toLowerCase();
    return vendors
        .where((vendor) {
          if (categoryFilter != null &&
              vendor.serviceCategory != categoryFilter) {
            return false;
          }
          if (bookingFilter != null && vendor.bookingStatus != bookingFilter) {
            return false;
          }
          if (contractFilter != null &&
              vendor.contractStatus != contractFilter) {
            return false;
          }
          if (search.isEmpty) return true;
          return [
            vendor.name,
            vendor.serviceCategory.label,
            vendor.contactPerson,
            vendor.email,
            vendor.phone,
            vendor.address,
            vendor.notes,
          ].join(' ').toLowerCase().contains(search);
        })
        .toList(growable: false);
  }

  int get bookedCount => vendors
      .where((vendor) => vendor.bookingStatus == VendorBookingStatus.booked)
      .length;
  int get signedCount => vendors
      .where((vendor) => vendor.contractStatus == VendorContractStatus.signed)
      .length;
  double get quotedTotal =>
      vendors.fold(0, (total, vendor) => total + (vendor.quoteAmount ?? 0));

  VendorListState copyWith({
    List<WeddingVendor>? vendors,
    String? query,
    VendorServiceCategory? categoryFilter,
    VendorBookingStatus? bookingFilter,
    VendorContractStatus? contractFilter,
    bool? isMutating,
    Object? actionError,
    bool clearCategoryFilter = false,
    bool clearBookingFilter = false,
    bool clearContractFilter = false,
    bool clearActionError = false,
  }) {
    return VendorListState(
      vendors: vendors ?? this.vendors,
      query: query ?? this.query,
      categoryFilter: clearCategoryFilter
          ? null
          : categoryFilter ?? this.categoryFilter,
      bookingFilter: clearBookingFilter
          ? null
          : bookingFilter ?? this.bookingFilter,
      contractFilter: clearContractFilter
          ? null
          : contractFilter ?? this.contractFilter,
      isMutating: isMutating ?? this.isMutating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class VendorController extends AsyncNotifier<VendorListState> {
  VendorRepository get _repository => ref.read(vendorRepositoryProvider);
  int? get _weddingId =>
      ref.read(weddingWorkspaceProvider).value?.selectedWedding?.id;

  @override
  Future<VendorListState> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return const VendorListState.empty();
    final weddingId = workspace.requireValue.selectedWedding?.id;
    if (weddingId == null) return const VendorListState.empty();
    return _fetch(weddingId);
  }

  Future<VendorListState> _fetch(
    int weddingId, [
    VendorListState? previous,
  ]) async {
    return VendorListState(
      vendors: await _repository.fetchVendors(weddingId),
      query: previous?.query ?? '',
      categoryFilter: previous?.categoryFilter,
      bookingFilter: previous?.bookingFilter,
      contractFilter: previous?.contractFilter,
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

  void setCategoryFilter(VendorServiceCategory? category) {
    state = AsyncData(
      state.requireValue.copyWith(
        categoryFilter: category,
        clearCategoryFilter: category == null,
      ),
    );
  }

  void setBookingFilter(VendorBookingStatus? status) {
    state = AsyncData(
      state.requireValue.copyWith(
        bookingFilter: status,
        clearBookingFilter: status == null,
      ),
    );
  }

  void setContractFilter(VendorContractStatus? status) {
    state = AsyncData(
      state.requireValue.copyWith(
        contractFilter: status,
        clearContractFilter: status == null,
      ),
    );
  }

  WeddingVendor? vendorById(int id) {
    return state.value?.vendors.where((vendor) => vendor.id == id).firstOrNull;
  }

  Future<bool> saveVendor({int? vendorId, required VendorDraft draft}) {
    return _mutate((weddingId) async {
      if (vendorId == null) {
        await _repository.createVendor(weddingId, draft);
      } else {
        await _repository.updateVendor(weddingId, vendorId, draft);
      }
    });
  }

  Future<bool> updateWorkflow(
    int vendorId, {
    VendorBookingStatus? bookingStatus,
    VendorQuoteStatus? quoteStatus,
    VendorContractStatus? contractStatus,
  }) {
    return _mutate(
      (weddingId) => _repository.updateWorkflow(
        weddingId,
        vendorId,
        bookingStatus: bookingStatus,
        quoteStatus: quoteStatus,
        contractStatus: contractStatus,
      ),
    );
  }

  Future<bool> deleteVendor(int vendorId) {
    return _mutate(
      (weddingId) => _repository.deleteVendor(weddingId, vendorId),
    );
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
