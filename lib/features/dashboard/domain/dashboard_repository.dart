import 'dashboard.dart';

abstract interface class DashboardRepository {
  Future<Dashboard> fetchDashboard(int weddingId);
}
