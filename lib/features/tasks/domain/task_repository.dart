import 'wedding_task.dart';

abstract interface class TaskRepository {
  Future<List<WeddingTask>> fetchTasks(int weddingId);

  Future<WeddingTask> createTask(int weddingId, TaskDraft draft);

  Future<WeddingTask> updateTask(
    int weddingId,
    int taskId,
    TaskDraft draft,
  );

  Future<WeddingTask> updateStatus(
    int weddingId,
    int taskId,
    WeddingTaskStatus status,
  );

  Future<void> deleteTask(int weddingId, int taskId);
}
