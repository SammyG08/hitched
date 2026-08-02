import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/entrance_animation.dart';
import '../../../shared/widgets/hitched_illustration.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/wedding_task.dart';
import 'task_controller.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskListProvider);
    final weddingName = ref
        .watch(weddingWorkspaceProvider)
        .value
        ?.selectedWedding
        ?.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(weddingName == null ? 'Tasks' : '$weddingName tasks'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Task'),
      ),
      body: taskState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _TaskError(
          onRetry: () => ref.read(taskListProvider.notifier).refresh(),
        ),
        data: (data) => _TaskListBody(state: data),
      ),
    );
  }
}

class _TaskListBody extends ConsumerWidget {
  const _TaskListBody({required this.state});

  final TaskListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = state.visibleTasks;
    return RefreshIndicator(
      onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: ref.read(taskListProvider.notifier).setQuery,
                decoration: const InputDecoration(
                  hintText: 'Search tasks or assignees',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  _StatusChip(
                    label: 'All',
                    selected: state.statusFilter == null,
                    onSelected: () => ref
                        .read(taskListProvider.notifier)
                        .setStatusFilter(null),
                  ),
                  for (final status in WeddingTaskStatus.values) ...[
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: status.label,
                      selected: state.statusFilter == status,
                      onSelected: () => ref
                          .read(taskListProvider.notifier)
                          .setStatusFilter(status),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (tasks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyTasks(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) => EntranceAnimation(
                  delay: Duration(milliseconds: (index > 5 ? 5 : index) * 45),
                  child: _TaskCard(task: tasks[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final WeddingTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tasks/${task.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (_) async {
                  final succeeded = await ref
                      .read(taskListProvider.notifier)
                      .toggleTask(task);
                  if (!succeeded && context.mounted) {
                    _showTaskError(context, ref);
                  }
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _TaskBadge(
                            icon: Icons.flag_outlined,
                            label: task.priority.label,
                            color: _priorityColor(task.priority),
                          ),
                          if (task.dueDate != null)
                            _TaskBadge(
                              icon: Icons.calendar_today_outlined,
                              label: _shortDate(task.dueDate!),
                            ),
                          if (task.assignee != null)
                            _TaskBadge(
                              icon: Icons.person_outline_rounded,
                              label: task.assignee!.user.displayName,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    context.push('/tasks/${task.id}/edit');
                  } else if (action == 'delete') {
                    await _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be permanently removed.'),
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
        .read(taskListProvider.notifier)
        .deleteTask(task.id);
    if (!succeeded && context.mounted) _showTaskError(context, ref);
  }
}

class _TaskBadge extends StatelessWidget {
  const _TaskBadge({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

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
            Text('No tasks match this view.'),
          ],
        ),
      ),
    );
  }
}

class _TaskError extends StatelessWidget {
  const _TaskError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tasks could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

void _showTaskError(BuildContext context, WidgetRef ref) {
  final error = ref.read(taskListProvider).value?.actionError;
  final message = error is ApiException
      ? error.displayMessage
      : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Color _priorityColor(WeddingTaskPriority priority) {
  return switch (priority) {
    WeddingTaskPriority.high => AppColors.danger,
    WeddingTaskPriority.medium => AppColors.warning,
    WeddingTaskPriority.low => AppColors.success,
  };
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
