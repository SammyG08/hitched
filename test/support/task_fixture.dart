import 'package:hitched/features/tasks/domain/task_repository.dart';
import 'package:hitched/features/tasks/domain/wedding_task.dart';

WeddingTask taskFixture({
  int id = 1,
  int weddingId = 1,
  String title = 'Book venue',
  WeddingTaskStatus status = WeddingTaskStatus.todo,
  WeddingTaskPriority priority = WeddingTaskPriority.high,
}) {
  return WeddingTask(
    id: id,
    weddingId: weddingId,
    title: title,
    description: 'Review the venue shortlist.',
    status: status,
    priority: priority,
    dueDate: DateTime(2027, 2, 1),
    createdAt: DateTime(2026, 8, 1),
    updatedAt: DateTime(2026, 8, 1),
  );
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<WeddingTask>? tasks})
    : tasks = tasks ?? [taskFixture()];

  final List<WeddingTask> tasks;
  int _nextId = 50;

  @override
  Future<List<WeddingTask>> fetchTasks(int weddingId) async {
    return List.unmodifiable(
      tasks.where((task) => task.weddingId == weddingId),
    );
  }

  @override
  Future<WeddingTask> createTask(int weddingId, TaskDraft draft) async {
    final task = _fromDraft(_nextId++, weddingId, draft);
    tasks.add(task);
    return task;
  }

  @override
  Future<WeddingTask> updateTask(
    int weddingId,
    int taskId,
    TaskDraft draft,
  ) async {
    final task = _fromDraft(taskId, weddingId, draft);
    _replace(task);
    return task;
  }

  @override
  Future<WeddingTask> updateStatus(
    int weddingId,
    int taskId,
    WeddingTaskStatus status,
  ) async {
    final existing = tasks.firstWhere((task) => task.id == taskId);
    final updated = WeddingTask(
      id: existing.id,
      weddingId: existing.weddingId,
      title: existing.title,
      description: existing.description,
      status: status,
      priority: existing.priority,
      dueDate: existing.dueDate,
      assignee: existing.assignee,
      createdBy: existing.createdBy,
      completedAt: status == WeddingTaskStatus.done ? DateTime.now() : null,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<void> deleteTask(int weddingId, int taskId) async {
    tasks.removeWhere((task) => task.id == taskId);
  }

  WeddingTask _fromDraft(int id, int weddingId, TaskDraft draft) {
    return WeddingTask(
      id: id,
      weddingId: weddingId,
      title: draft.title,
      description: draft.description,
      status: draft.status,
      priority: draft.priority,
      dueDate: draft.dueDate,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime.now(),
    );
  }

  void _replace(WeddingTask replacement) {
    final index = tasks.indexWhere((task) => task.id == replacement.id);
    tasks[index] = replacement;
  }
}
