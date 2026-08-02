import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/django_wedding_repository.dart';
import '../data/django_wedding_settings_repository.dart';
import '../data/secure_wedding_selection_storage.dart';
import '../domain/wedding.dart';
import '../domain/wedding_repository.dart';
import '../domain/wedding_settings_repository.dart';

final weddingRepositoryProvider = Provider<WeddingRepository>((ref) {
  return DjangoWeddingRepository(ref.watch(apiClientProvider));
});

final weddingSettingsRepositoryProvider = Provider<WeddingSettingsRepository>((
  ref,
) {
  return DjangoWeddingSettingsRepository(ref.watch(apiClientProvider));
});

final weddingSelectionStorageProvider = Provider<WeddingSelectionStorage>((
  ref,
) {
  return SecureWeddingSelectionStorage();
});

final weddingWorkspaceProvider =
    AsyncNotifierProvider<WeddingWorkspaceController, WeddingWorkspaceState>(
      WeddingWorkspaceController.new,
    );

class WeddingWorkspaceState {
  const WeddingWorkspaceState({
    required this.weddings,
    this.selectedWedding,
    this.isCreating = false,
    this.actionError,
  });

  const WeddingWorkspaceState.empty()
    : weddings = const [],
      selectedWedding = null,
      isCreating = false,
      actionError = null;

  final List<Wedding> weddings;
  final Wedding? selectedWedding;
  final bool isCreating;
  final Object? actionError;

  WeddingWorkspaceState copyWith({
    List<Wedding>? weddings,
    Wedding? selectedWedding,
    bool? isCreating,
    Object? actionError,
    bool clearActionError = false,
  }) {
    return WeddingWorkspaceState(
      weddings: weddings ?? this.weddings,
      selectedWedding: selectedWedding ?? this.selectedWedding,
      isCreating: isCreating ?? this.isCreating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class WeddingWorkspaceController extends AsyncNotifier<WeddingWorkspaceState> {
  WeddingRepository get _repository => ref.read(weddingRepositoryProvider);
  WeddingSelectionStorage get _selectionStorage =>
      ref.read(weddingSelectionStorageProvider);
  WeddingSettingsRepository get _settingsRepository =>
      ref.read(weddingSettingsRepositoryProvider);

  int get _userId => ref.read(authControllerProvider).requireValue!.id;

  @override
  Future<WeddingWorkspaceState> build() async {
    final user = ref.watch(authControllerProvider).requireValue;
    if (user == null) return const WeddingWorkspaceState.empty();

    return _loadWorkspace(user.id);
  }

  Future<WeddingWorkspaceState> _loadWorkspace(int userId) async {
    final weddings = await _repository.fetchWeddings();
    if (weddings.isEmpty) {
      await _selectionStorage.clearSelectedWeddingId(userId);
      return const WeddingWorkspaceState.empty();
    }

    final storedId = await _selectionStorage.readSelectedWeddingId(userId);
    final selected =
        weddings.where((wedding) => wedding.id == storedId).firstOrNull ??
        weddings.first;
    await _selectionStorage.saveSelectedWeddingId(userId, selected.id);
    return WeddingWorkspaceState(weddings: weddings, selectedWedding: selected);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadWorkspace(_userId));
  }

  Future<void> selectWedding(Wedding wedding) async {
    final current = state.requireValue;
    if (!current.weddings.any((item) => item.id == wedding.id)) return;

    state = AsyncData(current.copyWith(selectedWedding: wedding));
    await _selectionStorage.saveSelectedWeddingId(_userId, wedding.id);
  }

  Future<bool> createWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(isCreating: true, clearActionError: true),
    );

    try {
      final wedding = await _repository.createWedding(
        name: name,
        location: location,
        weddingDate: weddingDate,
      );
      final updated = [...current.weddings, wedding];
      await _selectionStorage.saveSelectedWeddingId(_userId, wedding.id);
      state = AsyncData(
        WeddingWorkspaceState(weddings: updated, selectedWedding: wedding),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isCreating: false, actionError: error),
      );
      return false;
    }
  }

  Future<bool> updateSelectedWedding({
    required String name,
    required String location,
    DateTime? weddingDate,
  }) async {
    final current = state.requireValue;
    final selected = current.selectedWedding;
    if (selected == null) return false;
    state = AsyncData(
      current.copyWith(isCreating: true, clearActionError: true),
    );
    try {
      final updated = await _settingsRepository.updateWedding(
        selected.id,
        name: name,
        location: location,
        weddingDate: weddingDate,
      );
      final weddings = current.weddings
          .map((wedding) => wedding.id == updated.id ? updated : wedding)
          .toList(growable: false);
      state = AsyncData(
        WeddingWorkspaceState(weddings: weddings, selectedWedding: updated),
      );
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isCreating: false, actionError: error),
      );
      return false;
    }
  }

  Future<bool> deleteSelectedWedding() async {
    final current = state.requireValue;
    final selected = current.selectedWedding;
    if (selected == null || !selected.isOwner) return false;
    state = AsyncData(
      current.copyWith(isCreating: true, clearActionError: true),
    );
    try {
      await _settingsRepository.deleteWedding(selected.id);
      final weddings = current.weddings
          .where((wedding) => wedding.id != selected.id)
          .toList(growable: false);
      if (weddings.isEmpty) {
        await _selectionStorage.clearSelectedWeddingId(_userId);
        state = const AsyncData(WeddingWorkspaceState.empty());
      } else {
        final next = weddings.first;
        await _selectionStorage.saveSelectedWeddingId(_userId, next.id);
        state = AsyncData(
          WeddingWorkspaceState(weddings: weddings, selectedWedding: next),
        );
      }
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isCreating: false, actionError: error),
      );
      return false;
    }
  }
}
