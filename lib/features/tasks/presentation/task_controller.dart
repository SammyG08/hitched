import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_task_repository.dart';
import '../domain/task_repository.dart';
import '../domain/wedding_task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return DjangoTaskRepository(ref.watch(apiClientProvider));
});

final taskListProvider = AsyncNotifierProvider<TaskController, TaskListState>(
  TaskController.new,
);

class TaskListState {
  const TaskListState({
    required this.tasks,
    this.statusFilter,
    this.query = '',
    this.isMutating = false,
    this.actionError,
  });

  const TaskListState.empty() : tasks = const [];

  final List<WeddingTask> tasks;
  final WeddingTaskStatus? statusFilter;
  final String query;
  final bool isMutating;
  final Object? actionError;

  List<WeddingTask> get visibleTasks {
    final normalizedQuery = query.trim().toLowerCase();
    return tasks.where((task) {
      final matchesStatus = statusFilter == null || task.status == statusFilter;
      final searchable = [
        task.title,
        task.description,
        task.assignee?.user.displayName ?? '',
      ].join(' ').toLowerCase();
      return matchesStatus &&
          (normalizedQuery.isEmpty || searchable.contains(normalizedQuery));
    }).toList(growable: false);
  }

  TaskListState copyWith({
    List<WeddingTask>? tasks,
    WeddingTaskStatus? statusFilter,
    String? query,
    bool? isMutating,
    Object? actionError,
    bool clearStatusFilter = false,
    bool clearActionError = false,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      statusFilter: clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      query: query ?? this.query,
      isMutating: isMutating ?? this.isMutating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class TaskController extends AsyncNotifier<TaskListState> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  int? get _weddingId => ref
      .read(weddingWorkspaceProvider)
      .value
      ?.selectedWedding
      ?.id;

  @override
  Future<TaskListState> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return const TaskListState.empty();
    final weddingId = workspace.requireValue.selectedWedding?.id;
    if (weddingId == null) return const TaskListState.empty();

    return TaskListState(tasks: await _repository.fetchTasks(weddingId));
  }

  Future<void> refresh() async {
    final weddingId = _weddingId;
    if (weddingId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => TaskListState(tasks: await _repository.fetchTasks(weddingId)),
    );
  }

  void setQuery(String query) {
    state = AsyncData(state.requireValue.copyWith(query: query));
  }

  void setStatusFilter(WeddingTaskStatus? status) {
    state = AsyncData(
      state.requireValue.copyWith(
        statusFilter: status,
        clearStatusFilter: status == null,
      ),
    );
  }

  WeddingTask? taskById(int taskId) {
    return state.value?.tasks.where((task) => task.id == taskId).firstOrNull;
  }

  Future<bool> saveTask({int? taskId, required TaskDraft draft}) async {
    final weddingId = _weddingId;
    if (weddingId == null) return false;
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(isMutating: true, clearActionError: true),
    );

    try {
      final saved = taskId == null
          ? await _repository.createTask(weddingId, draft)
          : await _repository.updateTask(weddingId, taskId, draft);
      final updated = taskId == null
          ? [...current.tasks, saved]
          : current.tasks
                .map((task) => task.id == saved.id ? saved : task)
                .toList(growable: false);
      state = AsyncData(current.copyWith(tasks: updated, isMutating: false));
      ref.invalidate(dashboardProvider);
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isMutating: false, actionError: error),
      );
      return false;
    }
  }

  Future<bool> toggleTask(WeddingTask task) async {
    final weddingId = _weddingId;
    if (weddingId == null) return false;
    final current = state.requireValue;
    final nextStatus = task.isDone
        ? WeddingTaskStatus.todo
        : WeddingTaskStatus.done;

    try {
      final updatedTask = await _repository.updateStatus(
        weddingId,
        task.id,
        nextStatus,
      );
      state = AsyncData(
        current.copyWith(
          tasks: current.tasks
              .map((item) => item.id == task.id ? updatedTask : item)
              .toList(growable: false),
          clearActionError: true,
        ),
      );
      ref.invalidate(dashboardProvider);
      return true;
    } catch (error) {
      state = AsyncData(current.copyWith(actionError: error));
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    final weddingId = _weddingId;
    if (weddingId == null) return false;
    final current = state.requireValue;

    try {
      await _repository.deleteTask(weddingId, taskId);
      state = AsyncData(
        current.copyWith(
          tasks: current.tasks
              .where((task) => task.id != taskId)
              .toList(growable: false),
          clearActionError: true,
        ),
      );
      ref.invalidate(dashboardProvider);
      return true;
    } catch (error) {
      state = AsyncData(current.copyWith(actionError: error));
      return false;
    }
  }
}
