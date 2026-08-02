import 'package:hitched/features/dashboard/domain/dashboard.dart';
import 'package:hitched/features/dashboard/domain/dashboard_repository.dart';

Dashboard dashboardFixture({int weddingId = 1}) {
  return Dashboard(
    wedding: DashboardWedding(
      id: weddingId,
      name: 'Alex & Jamie',
      location: 'Accra',
      hasPassed: false,
      daysUntilWedding: 120,
    ),
    tasks: const TaskProgress(
      total: 3,
      todo: 1,
      inProgress: 1,
      done: 1,
      overdue: 0,
      completionPercentage: 33.3,
    ),
    guests: const GuestProgress(
      households: 2,
      invitationsSent: 1,
      total: 4,
      attending: 2,
      declined: 0,
      pending: 2,
      dietaryRequirements: 1,
    ),
    budget: const BudgetHealth(
      configured: true,
      currency: 'GHS',
      totalAmount: 10000,
      allocatedTotal: 7000,
      estimatedTotal: 5000,
      actualTotal: 4000,
      paidTotal: 2500,
      remainingAmount: 6000,
      outstandingAmount: 1500,
      overdueExpenses: 0,
    ),
    vendors: const VendorProgress(
      total: 4,
      researching: 1,
      contacted: 0,
      shortlisted: 1,
      booked: 2,
      rejected: 0,
      quotesReceived: 3,
      contractsSigned: 1,
    ),
    upcomingTasks: const [
      UpcomingTask(
        id: 1,
        title: 'Confirm photographer',
        status: 'in_progress',
        priority: 'high',
        assigneeName: 'Jamie Taylor',
      ),
    ],
    upcomingPayments: const [],
    schedule: const ScheduleSummary(upcomingCount: 0, nextEvents: []),
  );
}

class FakeDashboardRepository implements DashboardRepository {
  final requestedWeddingIds = <int>[];

  @override
  Future<Dashboard> fetchDashboard(int weddingId) async {
    requestedWeddingIds.add(weddingId);
    return dashboardFixture(weddingId: weddingId);
  }
}
