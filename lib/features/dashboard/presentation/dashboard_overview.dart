import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/dashboard.dart';
import 'dashboard_controller.dart';

class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return dashboard.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _DashboardError(
        onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
      ),
      data: (data) => data == null
          ? const SizedBox.shrink()
          : _DashboardSections(dashboard: data),
    );
  }
}

class _DashboardSections extends StatelessWidget {
  const _DashboardSections({required this.dashboard});

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _MetricGrid(dashboard: dashboard),
        const SizedBox(height: 28),
        _UpcomingTasks(tasks: dashboard.upcomingTasks),
        const SizedBox(height: 20),
        _UpcomingPayments(
          payments: dashboard.upcomingPayments,
          currency: dashboard.budget.currency,
        ),
        const SizedBox(height: 20),
        _UpcomingSchedule(schedule: dashboard.schedule),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.dashboard});

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final taskProgress = dashboard.tasks.total == 0
        ? 0.0
        : dashboard.tasks.done / dashboard.tasks.total;
    final guestProgress = dashboard.guests.total == 0
        ? 0.0
        : dashboard.guests.attending / dashboard.guests.total;
    final budgetProgress = dashboard.budget.totalAmount <= 0
        ? 0.0
        : dashboard.budget.actualTotal / dashboard.budget.totalAmount;
    final vendorProgress = dashboard.vendors.total == 0
        ? 0.0
        : dashboard.vendors.booked / dashboard.vendors.total;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: cardWidth,
              icon: Icons.checklist_rounded,
              label: 'Tasks',
              value: '${dashboard.tasks.done}/${dashboard.tasks.total}',
              detail: dashboard.tasks.overdue == 0
                  ? '${dashboard.tasks.completionPercentage.toStringAsFixed(0)}% complete'
                  : '${dashboard.tasks.overdue} overdue',
              progress: taskProgress,
              onTap: () => context.push('/tasks'),
            ),
            _MetricCard(
              width: cardWidth,
              icon: Icons.groups_2_outlined,
              label: 'Guests',
              value: '${dashboard.guests.attending}/${dashboard.guests.total}',
              detail: '${dashboard.guests.pending} awaiting RSVP',
              progress: guestProgress,
              onTap: () => context.push('/guests'),
            ),
            _MetricCard(
              width: cardWidth,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Budget',
              value: dashboard.budget.configured
                  ? _money(
                      dashboard.budget.actualTotal,
                      dashboard.budget.currency,
                    )
                  : 'Not set',
              detail: dashboard.budget.configured
                  ? '${_money(dashboard.budget.remainingAmount, dashboard.budget.currency)} remaining'
                  : 'Create your budget',
              progress: budgetProgress,
            ),
            _MetricCard(
              width: cardWidth,
              icon: Icons.storefront_outlined,
              label: 'Vendors',
              value: '${dashboard.vendors.booked}/${dashboard.vendors.total}',
              detail: '${dashboard.vendors.contractsSigned} contracts signed',
              progress: vendorProgress,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.progress,
    this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress.clamp(0, 1).toDouble(),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingTasks extends StatelessWidget {
  const _UpcomingTasks({required this.tasks});

  final List<UpcomingTask> tasks;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Upcoming tasks',
      icon: Icons.check_circle_outline_rounded,
      emptyMessage: 'No upcoming tasks.',
      children: tasks
          .map(
            (task) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _PriorityDot(priority: task.priority),
              title: Text(task.title),
              subtitle: Text(
                [
                  if (task.dueDate != null) _shortDate(task.dueDate!),
                  if (task.assigneeName != null) task.assigneeName!,
                ].join(' · '),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _UpcomingPayments extends StatelessWidget {
  const _UpcomingPayments({required this.payments, required this.currency});

  final List<UpcomingPayment> payments;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Upcoming payments',
      icon: Icons.payments_outlined,
      emptyMessage: 'No upcoming payments.',
      children: payments
          .map(
            (payment) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.receipt_long_outlined),
              ),
              title: Text(payment.name),
              subtitle: Text(
                [
                  if (payment.vendorName != null) payment.vendorName!,
                  if (payment.dueDate != null) _shortDate(payment.dueDate!),
                ].join(' · '),
              ),
              trailing: Text(
                _money(payment.outstandingAmount, currency),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _UpcomingSchedule extends StatelessWidget {
  const _UpcomingSchedule({required this.schedule});

  final ScheduleSummary schedule;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Next on the schedule',
      icon: Icons.event_note_outlined,
      emptyMessage: 'No upcoming events.',
      children: schedule.nextEvents
          .map(
            (event) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(
                  event.startAt.day.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              title: Text(event.title),
              subtitle: Text(
                [
                  _shortDate(event.startAt),
                  if (event.location.isNotEmpty) event.location,
                ].join(' · '),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.icon,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final IconData icon;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(emptyMessage),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      'high' => Colors.red,
      'medium' => Colors.orange,
      _ => Colors.green,
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Dashboard data could not be loaded.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

String _money(double amount, String? currency) {
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix${amount.toStringAsFixed(2)}';
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
