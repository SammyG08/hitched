import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/wedding_task.dart';
import 'task_controller.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({this.taskId, super.key});

  final int? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  WeddingTaskStatus _status = WeddingTaskStatus.todo;
  WeddingTaskPriority _priority = WeddingTaskPriority.medium;
  DateTime? _dueDate;
  int? _assigneeId;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    final task = widget.taskId == null
        ? null
        : ref
              .read(taskListProvider)
              .value
              ?.tasks
              .where((item) => item.id == widget.taskId)
              .firstOrNull;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _status = task?.status ?? WeddingTaskStatus.todo;
    _priority = task?.priority ?? WeddingTaskPriority.medium;
    _dueDate = task?.dueDate;
    _assigneeId = task?.assignee?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(taskListProvider.notifier)
        .saveTask(
          taskId: widget.taskId,
          draft: TaskDraft(
            title: _titleController.text,
            description: _descriptionController.text,
            status: _status,
            priority: _priority,
            dueDate: _dueDate,
            assigneeId: _assigneeId,
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) {
      final error = ref.read(taskListProvider).value?.actionError;
      final message = error is ApiException
          ? error.displayMessage
          : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider).value;
    final wedding = ref.watch(weddingWorkspaceProvider).value?.selectedWedding;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit task' : 'Create task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    prefixIcon: Icon(Icons.task_alt_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task title.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WeddingTaskStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: WeddingTaskStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) setState(() => _status = status);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WeddingTaskPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: WeddingTaskPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.label),
                        ),
                      )
                      .toList(),
                  onChanged: (priority) {
                    if (priority != null) setState(() => _priority = priority);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _assigneeId,
                  decoration: const InputDecoration(labelText: 'Assignee'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...?wedding?.members.map(
                      (member) => DropdownMenuItem<int?>(
                        value: member.id,
                        child: Text(member.user.displayName),
                      ),
                    ),
                  ],
                  onChanged: (assigneeId) {
                    setState(() => _assigneeId = assigneeId);
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _chooseDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due date',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      suffixIcon: _dueDate == null
                          ? null
                          : IconButton(
                              tooltip: 'Clear date',
                              onPressed: () => setState(() => _dueDate = null),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'No due date'
                          : _displayDate(_dueDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: _isEditing ? 'Save changes' : 'Create task',
                  isLoading: taskState?.isMutating ?? false,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
