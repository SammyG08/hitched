import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/models/wedding_models.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    return HitchedScaffold(
      title: 'Todo list',
      subtitle: 'Shared planning tasks',
      actions: [
        IconButton(
          onPressed: () => _showAddTask(context, ref),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Column(
        children: state.tasks
            .map(
              (task) => Card(
                child: CheckboxListTile(
                  value: task.isDone,
                  onChanged: (_) => controller.toggleTask(task.id),
                  title: Text(task.title),
                  subtitle: Text(task.ownerRole?.label ?? 'Shared'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showAddTask(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add task', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            HitchedTextField(
              controller: title,
              label: 'Task title',
              icon: Icons.checklist_outlined,
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(appControllerProvider.notifier).addTask(title.text);
                Navigator.pop(context);
              },
              child: const Text('Add task'),
            ),
          ],
        ),
      ),
    );
  }
}
