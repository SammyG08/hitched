import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../domain/budget_models.dart';
import '../domain/budget_repository.dart';

class DjangoBudgetRepository implements BudgetRepository {
  DjangoBudgetRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  String _budget(int weddingId) => '/weddings/$weddingId/budget/';
  String _categories(int weddingId) => '${_budget(weddingId)}categories/';
  String _expenses(int weddingId) => '${_budget(weddingId)}expenses/';
  String _vendors(int weddingId) => '/weddings/$weddingId/vendors/';

  @override
  Future<WeddingBudget?> fetchBudget(int weddingId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_budget(weddingId));
      return WeddingBudget.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<List<BudgetCategory>> fetchCategories(int weddingId) {
    return _fetchPages(
      '${_categories(weddingId)}?page_size=100',
      BudgetCategory.fromJson,
    );
  }

  @override
  Future<List<BudgetExpense>> fetchExpenses(int weddingId) {
    return _fetchPages(
      '${_expenses(weddingId)}?page_size=100',
      BudgetExpense.fromJson,
    );
  }

  @override
  Future<List<BudgetVendor>> fetchVendors(int weddingId) {
    return _fetchPages(
      '${_vendors(weddingId)}?page_size=100',
      BudgetVendor.fromJson,
    );
  }

  Future<List<T>> _fetchPages<T>(
    String firstUrl,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final items = <T>[];
      String? nextUrl = firstUrl;
      while (nextUrl != null) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final data = response.data!;
        final results = data['results'] as List<dynamic>;
        items.addAll(
          results.map(
            (item) => fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
        nextUrl = data['next'] as String?;
      }
      return items;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingBudget> createBudget(int weddingId, BudgetDraft draft) {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _budget(weddingId),
        data: draft.toJson(),
      ),
      WeddingBudget.fromJson,
    );
  }

  @override
  Future<WeddingBudget> updateBudget(int weddingId, BudgetDraft draft) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        _budget(weddingId),
        data: draft.toJson(),
      ),
      WeddingBudget.fromJson,
    );
  }

  @override
  Future<BudgetCategory> createCategory(
    int weddingId,
    BudgetCategoryDraft draft,
  ) {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _categories(weddingId),
        data: draft.toJson(),
      ),
      BudgetCategory.fromJson,
    );
  }

  @override
  Future<BudgetCategory> updateCategory(
    int weddingId,
    int categoryId,
    BudgetCategoryDraft draft,
  ) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_categories(weddingId)}$categoryId/',
        data: draft.toJson(),
      ),
      BudgetCategory.fromJson,
    );
  }

  @override
  Future<void> deleteCategory(int weddingId, int categoryId) {
    return _delete('${_categories(weddingId)}$categoryId/');
  }

  @override
  Future<BudgetExpense> createExpense(int weddingId, BudgetExpenseDraft draft) {
    return _write(
      () => _dio.post<Map<String, dynamic>>(
        _expenses(weddingId),
        data: draft.toJson(),
      ),
      BudgetExpense.fromJson,
    );
  }

  @override
  Future<BudgetExpense> updateExpense(
    int weddingId,
    int expenseId,
    BudgetExpenseDraft draft,
  ) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_expenses(weddingId)}$expenseId/',
        data: draft.toJson(),
      ),
      BudgetExpense.fromJson,
    );
  }

  @override
  Future<BudgetExpense> updateAmountPaid(
    int weddingId,
    int expenseId,
    double amountPaid,
  ) {
    return _write(
      () => _dio.patch<Map<String, dynamic>>(
        '${_expenses(weddingId)}$expenseId/',
        data: {'amount_paid': amountPaid.toStringAsFixed(2)},
      ),
      BudgetExpense.fromJson,
    );
  }

  @override
  Future<void> deleteExpense(int weddingId, int expenseId) {
    return _delete('${_expenses(weddingId)}$expenseId/');
  }

  Future<T> _write<T>(
    Future<Response<Map<String, dynamic>>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      return fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> _delete(String path) async {
    try {
      await _dio.delete<void>(path);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
