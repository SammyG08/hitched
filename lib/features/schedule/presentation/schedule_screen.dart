import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/hitched_illustration.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/schedule_models.dart';
import 'schedule_controller.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleProvider);
    final weddingName = ref
        .watch(weddingWorkspaceProvider)
        .value
        ?.selectedWedding
        ?.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(weddingName == null ? 'Schedule' : '$weddingName schedule'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/schedule/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Event'),
      ),
      body: scheduleState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ScheduleError(
          onRetry: () => ref.read(scheduleProvider.notifier).refresh(),
        ),
        data: (data) => _ScheduleBody(state: data),
      ),
    );
  }
}

class _ScheduleBody extends ConsumerWidget {
  const _ScheduleBody({required this.state});

  final ScheduleState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _groupEvents(state.visibleEvents);
    return RefreshIndicator(
      onRefresh: () => ref.read(scheduleProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ScheduleSummary(state: state)),
          SliverToBoxAdapter(child: _ScheduleFilters(state: state)),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptySchedule(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is _ScheduleDay) {
                    return _DayHeader(date: item.date);
                  }
                  return _TimelineEvent(event: item as ScheduleEvent);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleSummary extends StatelessWidget {
  const _ScheduleSummary({required this.state});

  final ScheduleState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: _SummaryValue(
                value: state.events.length.toString(),
                label: 'Events',
              ),
            ),
            Expanded(
              child: _SummaryValue(
                value: state.upcomingCount.toString(),
                label: 'Upcoming',
              ),
            ),
            Expanded(
              child: _SummaryValue(
                value: state.confirmedCount.toString(),
                label: 'Confirmed',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ScheduleFilters extends ConsumerWidget {
  const _ScheduleFilters({required this.state});

  final ScheduleState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            onChanged: ref.read(scheduleProvider.notifier).setQuery,
            decoration: const InputDecoration(
              hintText: 'Search events, locations, people or vendors',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ScheduleEventType?>(
                  initialValue: state.typeFilter,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    const DropdownMenuItem<ScheduleEventType?>(
                      value: null,
                      child: Text('All types'),
                    ),
                    ...ScheduleEventType.values.map(
                      (type) => DropdownMenuItem<ScheduleEventType?>(
                        value: type,
                        child: Text(type.label),
                      ),
                    ),
                  ],
                  onChanged: ref.read(scheduleProvider.notifier).setTypeFilter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<ScheduleEventStatus?>(
                  initialValue: state.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem<ScheduleEventStatus?>(
                      value: null,
                      child: Text('All statuses'),
                    ),
                    ...ScheduleEventStatus.values.map(
                      (status) => DropdownMenuItem<ScheduleEventStatus?>(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: ref
                      .read(scheduleProvider.notifier)
                      .setStatusFilter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<ScheduleTimeFilter>(
            segments: const [
              ButtonSegment(value: ScheduleTimeFilter.all, label: Text('All')),
              ButtonSegment(
                value: ScheduleTimeFilter.upcoming,
                label: Text('Upcoming'),
              ),
              ButtonSegment(
                value: ScheduleTimeFilter.past,
                label: Text('Past'),
              ),
            ],
            selected: {state.timeFilter},
            onSelectionChanged: (selection) => ref
                .read(scheduleProvider.notifier)
                .setTimeFilter(selection.single),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(
        _longDate(date),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _TimelineEvent extends ConsumerWidget {
  const _TimelineEvent({required this.event});

  final ScheduleEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(event.startAt));
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(child: Container(width: 2, color: Colors.black12)),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _statusColor(event.status),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.black12)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/schedule/${event.id}/edit'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration:
                                    event.status ==
                                        ScheduleEventStatus.cancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${event.eventType.label} • '
                              '${_duration(event.durationMinutes)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (event.location.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              _EventDetail(
                                icon: Icons.location_on_outlined,
                                label: event.location,
                              ),
                            ],
                            if (event.responsibleMember != null) ...[
                              const SizedBox(height: 5),
                              _EventDetail(
                                icon: Icons.person_outline_rounded,
                                label:
                                    event.responsibleMember!.user.displayName,
                              ),
                            ],
                            if (event.vendor != null) ...[
                              const SizedBox(height: 5),
                              _EventDetail(
                                icon: Icons.storefront_outlined,
                                label: event.vendor!.name,
                              ),
                            ],
                            const SizedBox(height: 9),
                            _StatusBadge(status: event.status),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) =>
                            _handleAction(context, ref, action),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          if (event.status == ScheduleEventStatus.planned)
                            const PopupMenuItem(
                              value: 'confirm',
                              child: Text('Mark confirmed'),
                            ),
                          if (event.status != ScheduleEventStatus.completed &&
                              event.status != ScheduleEventStatus.cancelled)
                            const PopupMenuItem(
                              value: 'complete',
                              child: Text('Mark completed'),
                            ),
                          if (event.status != ScheduleEventStatus.cancelled)
                            const PopupMenuItem(
                              value: 'cancel',
                              child: Text('Cancel event'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'edit') {
      context.push('/schedule/${event.id}/edit');
      return;
    }
    if (action == 'delete') {
      await _confirmDelete(context, ref);
      return;
    }
    final status = switch (action) {
      'confirm' => ScheduleEventStatus.confirmed,
      'complete' => ScheduleEventStatus.completed,
      _ => ScheduleEventStatus.cancelled,
    };
    final succeeded = await ref
        .read(scheduleProvider.notifier)
        .updateStatus(event.id, status);
    if (!succeeded && context.mounted) _showScheduleError(context, ref);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('${event.title} will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final succeeded = await ref
        .read(scheduleProvider.notifier)
        .deleteEvent(event.id);
    if (!succeeded && context.mounted) _showScheduleError(context, ref);
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ScheduleEventStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: _statusColor(status)),
        const SizedBox(width: 5),
        Text(status.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HitchedIllustration(
              asset: 'assets/illustrations/planning_board.svg',
              width: 250,
              height: 168,
              semanticLabel: 'Wedding planning board',
            ),
            SizedBox(height: 16),
            Text('No schedule events match this view.'),
          ],
        ),
      ),
    );
  }
}

class _ScheduleError extends StatelessWidget {
  const _ScheduleError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Schedule could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _ScheduleDay {
  const _ScheduleDay(this.date);
  final DateTime date;
}

List<Object> _groupEvents(List<ScheduleEvent> events) {
  final items = <Object>[];
  DateTime? previousDay;
  for (final event in events) {
    final day = DateTime(
      event.startAt.year,
      event.startAt.month,
      event.startAt.day,
    );
    if (previousDay == null || day != previousDay) {
      items.add(_ScheduleDay(day));
      previousDay = day;
    }
    items.add(event);
  }
  return items;
}

void _showScheduleError(BuildContext context, WidgetRef ref) {
  final error = ref.read(scheduleProvider).value?.actionError;
  final message = error is ApiException
      ? error.displayMessage
      : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _longDate(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} '
      '${date.day}, ${date.year}';
}

String _duration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return remainder == 0 ? '$hours hr' : '$hours hr $remainder min';
}

Color _statusColor(ScheduleEventStatus status) {
  return switch (status) {
    ScheduleEventStatus.planned => AppColors.muted,
    ScheduleEventStatus.confirmed => AppColors.info,
    ScheduleEventStatus.completed => AppColors.success,
    ScheduleEventStatus.cancelled => AppColors.danger,
  };
}
