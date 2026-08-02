import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/task_repository.dart';
import '../domain/wedding_task.dart';

class DjangoTaskRepository implements TaskRepository {
  DjangoTaskRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  String _listPath(int weddingId) => '/weddings/$weddingId/tasks/';

  String _detailPath(int weddingId, int taskId) {
    return '/weddings/$weddingId/tasks/$taskId/';
  }

  @override
  Future<List<WeddingTask>> fetchTasks(int weddingId) async {
    try {
      final tasks = <WeddingTask>[];
      String? nextUrl = '${_listPath(weddingId)}?page_size=100';
      while (nextUrl != null) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final data = response.data!;
        final results = data['results'] as List<dynamic>;
        tasks.addAll(
          results.map(
            (item) =>
                WeddingTask.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
        nextUrl = data['next'] as String?;
      }
      return tasks;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingTask> createTask(int weddingId, TaskDraft draft) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _listPath(weddingId),
        data: draft.toJson(),
      );
      return WeddingTask.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingTask> updateTask(
    int weddingId,
    int taskId,
    TaskDraft draft,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        _detailPath(weddingId, taskId),
        data: draft.toJson(),
      );
      return WeddingTask.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingTask> updateStatus(
    int weddingId,
    int taskId,
    WeddingTaskStatus status,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        _detailPath(weddingId, taskId),
        data: {'status': status.apiValue},
      );
      return WeddingTask.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> deleteTask(int weddingId, int taskId) async {
    try {
      await _dio.delete<void>(_detailPath(weddingId, taskId));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
