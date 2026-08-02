import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_dashboard_repository.dart';
import '../domain/dashboard.dart';
import '../domain/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DjangoDashboardRepository(ref.watch(apiClientProvider));
});

final dashboardProvider =
    AsyncNotifierProvider<DashboardController, Dashboard?>(
      DashboardController.new,
    );

class DashboardController extends AsyncNotifier<Dashboard?> {
  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  @override
  Future<Dashboard?> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return null;

    final weddingId = workspace.requireValue.selectedWedding?.id;
    if (weddingId == null) return null;
    return _repository.fetchDashboard(weddingId);
  }

  Future<void> refresh() async {
    final weddingId = ref
        .read(weddingWorkspaceProvider)
        .requireValue
        .selectedWedding
        ?.id;
    if (weddingId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchDashboard(weddingId));
  }
}
